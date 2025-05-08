import 'package:get/get.dart';
import 'package:background_downloader/background_downloader.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../data/models/download_task_model.dart';
import '../data/models/video_model.dart';
import '../data/providers/storage_provider.dart';
import '../utils/logger.dart';
import '../utils/constants.dart';
import '../utils/utils.dart';

/// 下载服务
///
/// 负责管理视频下载任务，包括创建、暂停、恢复、取消和删除任务
class DownloadService extends GetxService {
  final StorageProvider _storageProvider = Get.find<StorageProvider>();
  final FileDownloader _downloader = FileDownloader();

  // 当前下载任务列表
  final RxList<DownloadTaskModel> downloadTasks = <DownloadTaskModel>[].obs;

  // 注意：这些字段已经不再使用，因为我们现在使用事件监听器
  // 下载状态监听器
  // final _taskStatusListeners = <String, Function>{};
  // final _taskProgressListeners = <String, Function>{};

  /// 初始化服务
  Future<DownloadService> init() async {
    Logger.d('DownloadService initialized');

    // 加载已有的下载任务
    downloadTasks.value = _storageProvider.getDownloadTasks();

    // 注册事件监听器
    _downloader.updates.listen((update) {
      switch (update) {
        case TaskStatusUpdate():
          _onTaskStatusChanged(update.task.taskId, update.status);
        case TaskProgressUpdate():
          _onTaskProgressChanged(update.task.taskId, update.progress);
      }
    });

    // 配置下载器
    await configureDownloader();

    // 启动下载器，激活数据库并确保在挂起/终止后正确重启
    await _downloader.start();

    // 在数据库中跟踪任务
    await _downloader.trackTasks();

    // 恢复未完成的下载任务
    _resumeUnfinishedTasks();

    return this;
  }

  /// 创建下载任务
  ///
  /// [video] 视频模型
  /// [quality] 视频质量
  /// [format] 视频格式
  /// [savePath] 保存路径，为空则使用默认路径
  /// 返回创建的下载任务
  Future<DownloadTaskModel?> createDownloadTask(
    VideoModel video, {
    required String quality,
    required String format,
    String? savePath,
  }) async {
    try {
      // 创建唯一ID
      final String taskId = DateTime.now().millisecondsSinceEpoch.toString();

      // 获取下载URL
      String downloadUrl = '';

      // 根据选择的质量获取URL
      if (video.qualities.isNotEmpty) {
        final selectedQuality = video.qualities.firstWhere(
          (q) => q.label == quality,
          orElse: () => video.qualities.first,
        );
        downloadUrl = selectedQuality.url;
      }

      // 如果没有找到质量URL，则根据格式获取URL
      if (downloadUrl.isEmpty && video.formats.isNotEmpty) {
        final selectedFormat = video.formats.firstWhere(
          (f) => f.label == format,
          orElse: () => video.formats.first,
        );
        downloadUrl = selectedFormat.url;
      }

      // 如果仍然没有URL，则使用视频的原始URL
      if (downloadUrl.isEmpty) {
        downloadUrl = video.url;
      }

      // 创建文件名
      final String fileName =
          '${video.title.replaceAll(RegExp(r'[^\w\s.-]'), '_')}_$quality.$format';

      // 获取保存路径
      final String downloadPath = await _getDownloadPath(savePath);

      // 创建下载任务模型
      final DownloadTaskModel task = DownloadTaskModel(
        id: taskId,
        videoId: video.id ?? '',
        title: video.title,
        url: downloadUrl,
        thumbnail: video.thumbnail,
        platform: video.platform,
        quality: quality,
        format: format,
        savePath: downloadPath,
        status: DownloadStatus.pending,
        createdAt: DateTime.now(),
      );

      // 保存任务到本地存储
      await _addTask(task);

      // 创建后台下载任务
      final DownloadTask bgTask = DownloadTask(
        url: downloadUrl,
        filename: fileName,
        directory: downloadPath,
        baseDirectory: BaseDirectory.applicationDocuments,
        updates: Updates.statusAndProgress,
        requiresWiFi:
            _storageProvider.getSetting('wifi_only', defaultValue: true) ??
                false,
        retries: 5, // 增加重试次数
        allowPause: true,
        metaData: taskId,
        priority: 5, // 正常优先级
        group: 'downloads', // 分组管理
      );

      // 获取文件大小
      try {
        final expectedSize = await bgTask.expectedFileSize();
        if (expectedSize > 0) {
          final updatedTask = task.copyWith(
            totalBytes: expectedSize,
          );
          await _updateTask(updatedTask);
        }
      } catch (e) {
        Logger.e('Error getting expected file size: $e');
      }

      // 如果启用了通知，配置下载通知
      if (_storageProvider.getSetting('show_notification', defaultValue: true) == true) {
        _downloader.configureNotification(
          running: TaskNotification('正在下载', '文件: $fileName'),
          complete: TaskNotification('下载完成', '文件: $fileName'),
          error: TaskNotification('下载失败', '文件: $fileName'),
          paused: TaskNotification('下载暂停', '文件: $fileName'),
          progressBar: true,
          tapOpensFile: true,
        );
      }

      // 开始下载
      await _downloader.enqueue(bgTask);

      return task;
    } catch (e) {
      Logger.e('Error creating download task: $e');
      Utils.showSnackbar('下载失败', '创建下载任务时出错: $e', isError: true);
      return null;
    }
  }

  /// 暂停下载任务
  ///
  /// [taskId] 任务ID
  /// 返回是否成功
  Future<bool> pauseTask(String taskId) async {
    try {
      final taskIndex = downloadTasks.indexWhere((task) => task.id == taskId);

      if (taskIndex != -1) {
        final task = downloadTasks[taskIndex];

        // 创建下载任务
        final fileName = '${task.title.replaceAll(RegExp(r'[^\w\s.-]'), '_')}_${task.quality ?? 'default'}.${task.format ?? 'mp4'}';
        final downloadPath = task.savePath ?? getDefaultDownloadPath();

        final bgTask = DownloadTask(
          url: task.url,
          filename: fileName,
          directory: downloadPath,
          baseDirectory: BaseDirectory.applicationDocuments,
          metaData: taskId,
        );

        // 暂停任务
        final result = await _downloader.pause(bgTask);

        if (result) {
          // 更新任务状态
          final updatedTask = task.copyWith(
            status: DownloadStatus.paused,
            updatedAt: DateTime.now(),
          );

          await _updateTask(updatedTask);

          // 显示通知
          if (_storageProvider.getSetting('show_notification', defaultValue: true) == true) {
            _downloader.configureNotification(
              paused: TaskNotification('下载暂停', '文件: ${task.title}'),
            );
          }

          return true;
        }
      }

      return false;
    } catch (e) {
      Logger.e('Error pausing task: $e');
      return false;
    }
  }

  /// 恢复下载任务
  ///
  /// [taskId] 任务ID
  /// 返回是否成功
  Future<bool> resumeTask(String taskId) async {
    try {
      final taskIndex = downloadTasks.indexWhere((task) => task.id == taskId);

      if (taskIndex != -1) {
        final task = downloadTasks[taskIndex];

        // 创建下载任务
        final fileName = '${task.title.replaceAll(RegExp(r'[^\w\s.-]'), '_')}_${task.quality ?? 'default'}.${task.format ?? 'mp4'}';
        final downloadPath = task.savePath ?? getDefaultDownloadPath();

        final bgTask = DownloadTask(
          url: task.url,
          filename: fileName,
          directory: downloadPath,
          baseDirectory: BaseDirectory.applicationDocuments,
          updates: Updates.statusAndProgress,
          requiresWiFi: _storageProvider.getSetting('wifi_only', defaultValue: true) ?? false,
          retries: 3,
          allowPause: true,
          metaData: taskId,
        );

        // 检查是否可以恢复
        bool canResume = false;
        try {
          canResume = await _downloader.taskCanResume(bgTask);
        } catch (e) {
          Logger.e('Error checking if task can resume: $e');
        }

        bool result = false;
        if (canResume) {
          // 如果可以恢复，则恢复下载
          result = await _downloader.resume(bgTask);
          Logger.d('Resumed task: ${task.id}');
        } else {
          // 如果不能恢复，则重新开始下载
          result = await _downloader.enqueue(bgTask);
          Logger.d('Restarted task: ${task.id}');
        }

        if (result) {
          // 更新任务状态
          final updatedTask = task.copyWith(
            status: DownloadStatus.downloading,
            updatedAt: DateTime.now(),
          );

          await _updateTask(updatedTask);

          // 显示通知
          if (_storageProvider.getSetting('show_notification', defaultValue: true) == true) {
            _downloader.configureNotification(
              running: TaskNotification('正在下载', '文件: ${task.title}'),
            );
          }

          return true;
        }
      }

      return false;
    } catch (e) {
      Logger.e('Error resuming task: $e');
      return false;
    }
  }

  /// 取消下载任务
  ///
  /// [taskId] 任务ID
  /// 返回是否成功
  Future<bool> cancelTask(String taskId) async {
    try {
      final taskIndex = downloadTasks.indexWhere((task) => task.id == taskId);

      if (taskIndex != -1) {
        final task = downloadTasks[taskIndex];

        // 取消任务
        await _downloader.cancelTasksWithIds([taskId]);

        // 更新任务状态
        final updatedTask = task.copyWith(
          status: DownloadStatus.canceled,
          updatedAt: DateTime.now(),
        );

        await _updateTask(updatedTask);

        // 显示通知
        if (_storageProvider.getSetting('show_notification', defaultValue: true) == true) {
          _downloader.configureNotification(
            error: TaskNotification('下载取消', '文件: ${task.title}'),
          );
        }

        return true;
      }

      return false;
    } catch (e) {
      Logger.e('Error canceling task: $e');
      return false;
    }
  }

  /// 删除下载任务
  ///
  /// [taskId] 任务ID
  /// [deleteFile] 是否同时删除文件
  /// 返回是否成功
  Future<bool> deleteTask(String taskId, {bool deleteFile = false}) async {
    try {
      final taskIndex = downloadTasks.indexWhere((task) => task.id == taskId);

      if (taskIndex != -1) {
        final task = downloadTasks[taskIndex];

        // 先取消任务
        await cancelTask(taskId);

        // 如果需要删除文件
        if (deleteFile && task.savePath != null) {
          final file = File('${task.savePath}/${task.title}');
          if (await file.exists()) {
            await file.delete();
          }
        }

        // 从存储中删除任务
        await _removeTask(taskId);

        return true;
      }

      return false;
    } catch (e) {
      Logger.e('Error deleting task: $e');
      return false;
    }
  }

  /// 获取下载任务列表
  List<DownloadTaskModel> getTasks() {
    return downloadTasks;
  }

  /// 获取下载任务
  ///
  /// [taskId] 任务ID
  /// 返回下载任务，未找到返回null
  DownloadTaskModel? getTask(String taskId) {
    final index = downloadTasks.indexWhere((task) => task.id == taskId);
    if (index != -1) {
      return downloadTasks[index];
    }
    return null;
  }

  /// 添加任务到列表和存储
  Future<void> _addTask(DownloadTaskModel task) async {
    downloadTasks.add(task);
    await _storageProvider.addDownloadTask(task);
  }

  /// 更新任务
  Future<void> _updateTask(DownloadTaskModel task) async {
    final index = downloadTasks.indexWhere((t) => t.id == task.id);
    if (index != -1) {
      downloadTasks[index] = task;
      await _storageProvider.updateDownloadTask(task);
    }
  }

  /// 从列表和存储中移除任务
  Future<void> _removeTask(String taskId) async {
    downloadTasks.removeWhere((task) => task.id == taskId);
    await _storageProvider.removeDownloadTask(taskId);
  }

  /// 获取默认下载路径
  String getDefaultDownloadPath() {
    // 获取默认设置的下载路径
    final defaultPath = _storageProvider.getSetting(
      'download_path',
      defaultValue: Constants.DEFAULT_DOWNLOAD_PATH,
    );

    if (defaultPath != null && defaultPath.isNotEmpty) {
      return defaultPath;
    }

    // 如果没有设置，则返回默认路径
    return Constants.DEFAULT_DOWNLOAD_PATH;
  }

  /// 获取下载路径
  Future<String> _getDownloadPath(String? customPath) async {
    if (customPath != null && customPath.isNotEmpty) {
      return customPath;
    }

    // 获取默认设置的下载路径
    final defaultPath = _storageProvider.getSetting(
      'download_path',
      defaultValue: Constants.DEFAULT_DOWNLOAD_PATH,
    );

    if (defaultPath != null && defaultPath.isNotEmpty) {
      return defaultPath;
    }

    // 如果没有设置，则使用应用文档目录
    final appDir = await getApplicationDocumentsDirectory();
    final downloadDir = Directory('${appDir.path}/downloads');

    // 确保目录存在
    if (!await downloadDir.exists()) {
      await downloadDir.create(recursive: true);
    }

    return downloadDir.path;
  }

  // 注意：这个方法已经不再使用，因为我们现在使用事件监听器
  // 保留以便兼容旧代码
  /*
  /// 注册任务回调
  void _registerTaskCallbacks(String taskId) {
    // 注册状态回调
    _taskStatusListeners[taskId] = (id, status) {
      _onTaskStatusChanged(id, status);
    };

    // 注册进度回调
    _taskProgressListeners[taskId] = (id, progress) {
      _onTaskProgressChanged(id, progress);
    };
  }
  */

  /// 任务状态变化回调
  void _onTaskStatusChanged(String taskId, TaskStatus status) async {
    try {
      final taskIndex = downloadTasks.indexWhere((task) => task.id == taskId);
      if (taskIndex == -1) return;

      final task = downloadTasks[taskIndex];
      DownloadStatus newStatus;

      // 根据 TaskStatus 设置对应的 DownloadStatus
      switch (status) {
        case TaskStatus.enqueued:
          newStatus = DownloadStatus.pending;
        case TaskStatus.running:
          newStatus = DownloadStatus.downloading;
        case TaskStatus.complete:
          newStatus = DownloadStatus.completed;
          // 获取文件大小
          final file = File(task.savePath ?? '');
          if (await file.exists()) {
            final fileSize = await file.length();
            final updatedTask = task.copyWith(
              status: newStatus,
              totalBytes: fileSize,
              downloadedBytes: fileSize,
              updatedAt: DateTime.now(),
              completedAt: DateTime.now(),
            );
            await _updateTask(updatedTask);
            // 显示通知
            Utils.showSnackbar('下载完成', '文件 ${task.title} 已下载完成');
            return;
          }
        case TaskStatus.failed:
          newStatus = DownloadStatus.failed;
        case TaskStatus.canceled:
          newStatus = DownloadStatus.canceled;
        case TaskStatus.paused:
          newStatus = DownloadStatus.paused;
        default:
          newStatus = DownloadStatus.downloading;
      }

      final updatedTask = task.copyWith(
        status: newStatus,
        updatedAt: DateTime.now(),
        completedAt: status == TaskStatus.complete ? DateTime.now() : null,
      );

      await _updateTask(updatedTask);
    } catch (e) {
      Logger.e('Error in task status callback: $e');
    }
  }

  /// 任务进度变化回调
  void _onTaskProgressChanged(String taskId, double progress) async {
    try {
      final taskIndex = downloadTasks.indexWhere((task) => task.id == taskId);
      if (taskIndex == -1) return;

      final task = downloadTasks[taskIndex];

      // 如果是负数，表示特殊状态（失败、取消等）
      if (progress < 0) {
        return; // 这些状态已经在 _onTaskStatusChanged 中处理
      }

      // 获取任务的预期文件大小
      final DownloadTask downloadTask = DownloadTask(
        url: task.url,
        filename: task.title,
        metaData: task.id,
      );

      int totalBytes = task.totalBytes;
      if (totalBytes == 0) {
        try {
          final expectedSize = await downloadTask.expectedFileSize();
          totalBytes = expectedSize > 0 ? expectedSize : 1024 * 1024;
        } catch (e) {
          totalBytes = 1024 * 1024; // 默认使用 1MB
        }
      }

      final downloadedBytes = (totalBytes * progress).toInt();

      final updatedTask = task.copyWith(
        totalBytes: totalBytes,
        downloadedBytes: downloadedBytes,
        updatedAt: DateTime.now(),
      );

      await _updateTask(updatedTask);

      // 显示通知（如果启用了通知）
      if (_storageProvider.getSetting('show_notification', defaultValue: true) == true) {
        // 每 10% 显示一次通知，避免通知过多
        final progressPercent = (progress * 100).toInt();
        if (progressPercent % 10 == 0 && progressPercent > 0) {
          _showProgressNotification(task, progress);
        }
      }
    } catch (e) {
      Logger.e('Error in task progress callback: $e');
    }
  }

  /// 显示进度通知
  void _showProgressNotification(DownloadTaskModel task, double progress) {
    // 使用 background_downloader 的通知功能
    _downloader.configureNotification(
      running: TaskNotification('正在下载', '文件: ${task.title} - ${(progress * 100).toInt()}%'),
      complete: TaskNotification('下载完成', '文件: ${task.title}'),
      error: TaskNotification('下载失败', '文件: ${task.title}'),
      paused: TaskNotification('下载暂停', '文件: ${task.title}'),
      progressBar: true,
      tapOpensFile: true,
    );
  }

  /// 配置下载器
  Future<void> configureDownloader() async {
    // 配置持有队列，限制并发下载数量
    // maxConcurrent: 最大并发任务数
    // maxConcurrentByHost: 每个主机的最大并发任务数
    // maxConcurrentByGroup: 每个组的最大并发任务数
    await _downloader.configure(
      globalConfig: (Config.holdingQueue, (3, 2, 1)),
    );

    // 配置超时时间
    await _downloader.configure(
      globalConfig: (Config.requestTimeout, 60), // 60秒超时
    );

    // 检查可用空间
    await _downloader.configure(
      globalConfig: (Config.checkAvailableSpace, true),
    );
  }

  /// 初始化通知
  Future<void> initNotifications() async {
    if (_storageProvider.getSetting('show_notification', defaultValue: true) == true) {
      // 配置全局通知
      _downloader.configureNotification(
        running: TaskNotification('正在下载', '文件: {filename}'),
        complete: TaskNotification('下载完成', '文件: {filename}'),
        error: TaskNotification('下载失败', '文件: {filename}'),
        paused: TaskNotification('下载暂停', '文件: {filename}'),
        progressBar: true,
        tapOpensFile: true,
      );
    }
  }

  /// 恢复未完成的下载任务
  Future<void> _resumeUnfinishedTasks() async {
    try {
      // 初始化通知
      await initNotifications();

      // 恢复从后台
      await _downloader.resumeFromBackground();

      final unfinishedTasks = downloadTasks
          .where((task) =>
              task.status == DownloadStatus.downloading ||
              task.status == DownloadStatus.pending ||
              task.status == DownloadStatus.paused)
          .toList();

      if (unfinishedTasks.isEmpty) {
        Logger.d('No unfinished tasks to resume');
        return;
      }

      Logger.d('Resuming ${unfinishedTasks.length} unfinished tasks');

      for (final task in unfinishedTasks) {
        // 创建后台下载任务
        final fileName =
            '${task.title.replaceAll(RegExp(r'[^\w\s.-]'), '_')}_${task.quality ?? 'default'}.${task.format ?? 'mp4'}';

        // 获取下载路径
        final downloadPath = task.savePath ?? getDefaultDownloadPath();

        final bgTask = DownloadTask(
          url: task.url,
          filename: fileName,
          directory: downloadPath,
          baseDirectory: BaseDirectory.applicationDocuments,
          updates: Updates.statusAndProgress,
          requiresWiFi:
              _storageProvider.getSetting('wifi_only', defaultValue: true) ??
                  false,
          retries: 3,
          allowPause: true,
          metaData: task.id,
        );

        // 检查是否可以恢复
        bool canResume = false;
        try {
          canResume = await _downloader.taskCanResume(bgTask);
        } catch (e) {
          Logger.e('Error checking if task can resume: $e');
        }

        if (canResume) {
          // 如果可以恢复，则恢复下载
          await _downloader.resume(bgTask);
          Logger.d('Resumed unfinished task: ${task.id}');
        } else {
          // 如果不能恢复，则重新开始下载
          await _downloader.enqueue(bgTask);
          Logger.d('Restarted unfinished task: ${task.id}');
        }
      }

      // 重新调度被终止的任务
      Future.delayed(const Duration(seconds: 5), () {
        _downloader.rescheduleKilledTasks();
      });
    } catch (e) {
      Logger.e('Error resuming unfinished tasks: $e');
    }
  }
}
