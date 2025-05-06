import 'package:get/get.dart';
import 'package:background_downloader/background_downloader.dart';
import '../models/download_task_model.dart';
import '../models/video_model.dart';
import '../providers/storage_provider.dart';
import '../../utils/utils.dart';

class DownloadRepository {
  final StorageProvider _storageProvider = Get.find<StorageProvider>();
  final FileDownloader _downloader = FileDownloader();

  // 获取下载任务列表
  List<DownloadTaskModel> getDownloadTasks() {
    return _storageProvider.getDownloadTasks();
  }

  // 添加下载任务
  Future<DownloadTaskModel?> addDownloadTask(
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
      final String fileName = '${video.title.replaceAll(RegExp(r'[^\w\s.-]'), '_')}_$quality.$format';
      
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
        savePath: savePath,
        status: DownloadStatus.pending,
        createdAt: DateTime.now(),
      );
      
      // 保存任务到本地存储
      await _storageProvider.addDownloadTask(task);
      
      // 创建后台下载任务
      final Task bgTask = DownloadTask(
        url: downloadUrl,
        filename: fileName,
        directory: savePath,
        baseDirectory: BaseDirectory.applicationDocuments,
        updates: Updates.statusAndProgress,
        requiresWiFi: _storageProvider.getSetting('wifi_only', defaultValue: true),
        retries: 3,
        allowPause: true,
      );
      
      // 注册任务状态回调
      _downloader.registerCallbacks(
        taskId: bgTask.taskId,
        onStatus: (id, status) {
          _updateTaskStatus(taskId, status);
        },
        onProgress: (id, progress) {
          _updateTaskProgress(taskId, progress);
        },
      );
      
      // 开始下载
      await _downloader.enqueue(bgTask);
      
      return task;
    } catch (e) {
      Utils.showSnackbar('下载失败', '创建下载任务时出错: $e', isError: true);
      return null;
    }
  }

  // 暂停下载任务
  Future<bool> pauseDownloadTask(String taskId) async {
    try {
      final tasks = _storageProvider.getDownloadTasks();
      final taskIndex = tasks.indexWhere((task) => task.id == taskId);
      
      if (taskIndex != -1) {
        final task = tasks[taskIndex];
        
        // 暂停后台下载任务
        final bgTask = TaskRecord(taskId: taskId, url: task.url, filename: '');
        final result = await _downloader.pause(bgTask);
        
        if (result) {
          // 更新任务状态
          final updatedTask = task.copyWith(
            status: DownloadStatus.paused,
            updatedAt: DateTime.now(),
          );
          
          tasks[taskIndex] = updatedTask;
          await _storageProvider.saveDownloadTasks(tasks);
        }
        
        return result;
      }
      
      return false;
    } catch (e) {
      return false;
    }
  }

  // 恢复下载任务
  Future<bool> resumeDownloadTask(String taskId) async {
    try {
      final tasks = _storageProvider.getDownloadTasks();
      final taskIndex = tasks.indexWhere((task) => task.id == taskId);
      
      if (taskIndex != -1) {
        final task = tasks[taskIndex];
        
        // 恢复后台下载任务
        final bgTask = TaskRecord(taskId: taskId, url: task.url, filename: '');
        final result = await _downloader.resume(bgTask);
        
        if (result) {
          // 更新任务状态
          final updatedTask = task.copyWith(
            status: DownloadStatus.downloading,
            updatedAt: DateTime.now(),
          );
          
          tasks[taskIndex] = updatedTask;
          await _storageProvider.saveDownloadTasks(tasks);
        }
        
        return result;
      }
      
      return false;
    } catch (e) {
      return false;
    }
  }

  // 取消下载任务
  Future<bool> cancelDownloadTask(String taskId) async {
    try {
      final tasks = _storageProvider.getDownloadTasks();
      final taskIndex = tasks.indexWhere((task) => task.id == taskId);
      
      if (taskIndex != -1) {
        final task = tasks[taskIndex];
        
        // 取消后台下载任务
        final bgTask = TaskRecord(taskId: taskId, url: task.url, filename: '');
        final result = await _downloader.cancel(bgTask);
        
        if (result) {
          // 更新任务状态
          final updatedTask = task.copyWith(
            status: DownloadStatus.canceled,
            updatedAt: DateTime.now(),
          );
          
          tasks[taskIndex] = updatedTask;
          await _storageProvider.saveDownloadTasks(tasks);
        }
        
        return result;
      }
      
      return false;
    } catch (e) {
      return false;
    }
  }

  // 删除下载任务
  Future<bool> deleteDownloadTask(String taskId) async {
    try {
      // 先取消任务
      await cancelDownloadTask(taskId);
      
      // 从存储中删除任务
      await _storageProvider.removeDownloadTask(taskId);
      
      return true;
    } catch (e) {
      return false;
    }
  }

  // 更新任务状态
  Future<void> _updateTaskStatus(String taskId, TaskStatus status) async {
    final tasks = _storageProvider.getDownloadTasks();
    final taskIndex = tasks.indexWhere((task) => task.id == taskId);
    
    if (taskIndex != -1) {
      final task = tasks[taskIndex];
      DownloadStatus newStatus;
      
      switch (status) {
        case TaskStatus.enqueued:
        case TaskStatus.running:
          newStatus = DownloadStatus.downloading;
          break;
        case TaskStatus.paused:
          newStatus = DownloadStatus.paused;
          break;
        case TaskStatus.complete:
          newStatus = DownloadStatus.completed;
          break;
        case TaskStatus.notFound:
        case TaskStatus.failed:
          newStatus = DownloadStatus.failed;
          break;
        case TaskStatus.canceled:
          newStatus = DownloadStatus.canceled;
          break;
      }
      
      final updatedTask = task.copyWith(
        status: newStatus,
        updatedAt: DateTime.now(),
        completedAt: newStatus == DownloadStatus.completed ? DateTime.now() : task.completedAt,
      );
      
      tasks[taskIndex] = updatedTask;
      await _storageProvider.saveDownloadTasks(tasks);
    }
  }

  // 更新任务进度
  Future<void> _updateTaskProgress(String taskId, double progress) async {
    final tasks = _storageProvider.getDownloadTasks();
    final taskIndex = tasks.indexWhere((task) => task.id == taskId);
    
    if (taskIndex != -1) {
      final task = tasks[taskIndex];
      
      // 计算已下载字节数
      final downloadedBytes = (task.totalBytes * progress).toInt();
      
      final updatedTask = task.copyWith(
        downloadedBytes: downloadedBytes,
        updatedAt: DateTime.now(),
      );
      
      tasks[taskIndex] = updatedTask;
      await _storageProvider.saveDownloadTasks(tasks);
    }
  }
}
