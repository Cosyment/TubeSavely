import 'dart:io';
import 'dart:async';
import 'dart:math';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
// 暂时注释掉，编译时有问题
// import 'package:ffmpeg_kit_flutter_full_gpl/ffmpeg_kit.dart';
// import 'package:ffmpeg_kit_flutter_full_gpl/return_code.dart';
// import 'package:ffmpeg_kit_flutter_full_gpl/ffmpeg_session.dart';
// import 'package:ffmpeg_kit_flutter_full_gpl/ffprobe_kit.dart';
// import 'package:ffmpeg_kit_flutter_full_gpl/media_information.dart';
// import 'package:ffmpeg_kit_flutter_full_gpl/media_information_session.dart';
import '../data/models/download_task_model.dart';
import '../data/providers/storage_provider.dart';
import '../utils/logger.dart';
import '../utils/utils.dart';

/// 视频转换任务状态
enum ConversionStatus {
  pending, // 等待中
  converting, // 转换中
  completed, // 已完成
  failed, // 失败
  canceled // 已取消
}

/// 视频转换任务模型
class ConversionTask {
  final String id;
  final String sourceFilePath;
  final String targetFilePath;
  final String format;
  final String resolution;
  final int bitrate;
  final ConversionStatus status;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final DateTime? completedAt;
  final double progress;
  final String? errorMessage;

  ConversionTask({
    required this.id,
    required this.sourceFilePath,
    required this.targetFilePath,
    required this.format,
    required this.resolution,
    required this.bitrate,
    this.status = ConversionStatus.pending,
    required this.createdAt,
    this.updatedAt,
    this.completedAt,
    this.progress = 0.0,
    this.errorMessage,
  });

  ConversionTask copyWith({
    String? id,
    String? sourceFilePath,
    String? targetFilePath,
    String? format,
    String? resolution,
    int? bitrate,
    ConversionStatus? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? completedAt,
    double? progress,
    String? errorMessage,
  }) {
    return ConversionTask(
      id: id ?? this.id,
      sourceFilePath: sourceFilePath ?? this.sourceFilePath,
      targetFilePath: targetFilePath ?? this.targetFilePath,
      format: format ?? this.format,
      resolution: resolution ?? this.resolution,
      bitrate: bitrate ?? this.bitrate,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      completedAt: completedAt ?? this.completedAt,
      progress: progress ?? this.progress,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'sourceFilePath': sourceFilePath,
      'targetFilePath': targetFilePath,
      'format': format,
      'resolution': resolution,
      'bitrate': bitrate,
      'status': status.index,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'updatedAt': updatedAt?.millisecondsSinceEpoch,
      'completedAt': completedAt?.millisecondsSinceEpoch,
      'progress': progress,
      'errorMessage': errorMessage,
    };
  }

  factory ConversionTask.fromJson(Map<String, dynamic> json) {
    return ConversionTask(
      id: json['id'],
      sourceFilePath: json['sourceFilePath'],
      targetFilePath: json['targetFilePath'],
      format: json['format'],
      resolution: json['resolution'],
      bitrate: json['bitrate'],
      status: ConversionStatus.values[json['status']],
      createdAt: DateTime.fromMillisecondsSinceEpoch(json['createdAt']),
      updatedAt: json['updatedAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(json['updatedAt'])
          : null,
      completedAt: json['completedAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(json['completedAt'])
          : null,
      progress: json['progress'],
      errorMessage: json['errorMessage'],
    );
  }
}

/// 视频转换服务
///
/// 负责管理视频转换任务，包括创建、取消和删除任务
class VideoConverterService extends GetxService {
  final StorageProvider _storageProvider = Get.find<StorageProvider>();

  // 当前转换任务列表
  final RxList<ConversionTask> conversionTasks = <ConversionTask>[].obs;

  // 当前正在执行的任务
  final Rx<ConversionTask?> currentTask = Rx<ConversionTask?>(null);

  // 是否正在转换
  final RxBool isConverting = false.obs;

  // 转换会话管理，用于取消转换
  final Map<String, FFmpegSession> _conversionSessions = {};

  /// 初始化服务
  Future<VideoConverterService> init() async {
    Logger.d('VideoConverterService initialized');

    // 加载已有的转换任务
    _loadTasks();

    return this;
  }

  /// 创建视频转换任务
  ///
  /// [sourceFilePath] 源文件路径
  /// [format] 目标格式
  /// [resolution] 分辨率
  /// [bitrate] 比特率
  /// 返回创建的转换任务
  Future<ConversionTask?> createTask({
    required String sourceFilePath,
    required String format,
    String resolution = '720p',
    int bitrate = 1500,
  }) async {
    try {
      // 检查源文件是否存在
      final sourceFile = File(sourceFilePath);
      if (!await sourceFile.exists()) {
        throw Exception('Source file does not exist: $sourceFilePath');
      }

      // 创建唯一ID
      final String taskId = DateTime.now().millisecondsSinceEpoch.toString();

      // 创建目标文件路径
      final targetFilePath = await _getTargetFilePath(sourceFilePath, format);

      // 创建转换任务
      final ConversionTask task = ConversionTask(
        id: taskId,
        sourceFilePath: sourceFilePath,
        targetFilePath: targetFilePath,
        format: format,
        resolution: resolution,
        bitrate: bitrate,
        status: ConversionStatus.pending,
        createdAt: DateTime.now(),
      );

      // 保存任务
      await _addTask(task);

      // 如果当前没有正在执行的任务，则开始执行
      if (!isConverting.value) {
        _processNextTask();
      }

      return task;
    } catch (e) {
      Logger.e('Error creating conversion task: $e');
      Utils.showSnackbar('转换失败', '创建转换任务时出错: $e', isError: true);
      return null;
    }
  }

  /// 取消转换任务
  ///
  /// [taskId] 任务ID
  /// 返回是否成功
  Future<bool> cancelTask(String taskId) async {
    try {
      final taskIndex = conversionTasks.indexWhere((task) => task.id == taskId);

      if (taskIndex != -1) {
        final task = conversionTasks[taskIndex];

        // 只有等待中或转换中的任务才能取消
        if (task.status != ConversionStatus.pending &&
            task.status != ConversionStatus.converting) {
          return false;
        }

        // 如果是正在转换的任务，取消FFmpeg会话
        if (task.status == ConversionStatus.converting) {
          final session = _conversionSessions[taskId];
          if (session != null) {
            await session.cancel();
            _conversionSessions.remove(taskId);
          }

          // 重置状态
          isConverting.value = false;
          currentTask.value = null;

          // 处理下一个任务
          _processNextTask();
        }

        // 更新任务状态
        final updatedTask = task.copyWith(
          status: ConversionStatus.canceled,
          updatedAt: DateTime.now(),
        );

        await _updateTask(updatedTask);

        return true;
      }

      return false;
    } catch (e) {
      Logger.e('Error canceling conversion task: $e');
      return false;
    }
  }

  /// 删除转换任务
  ///
  /// [taskId] 任务ID
  /// [deleteFile] 是否同时删除文件
  /// 返回是否成功
  Future<bool> deleteTask(String taskId, {bool deleteFile = false}) async {
    try {
      final taskIndex = conversionTasks.indexWhere((task) => task.id == taskId);

      if (taskIndex != -1) {
        final task = conversionTasks[taskIndex];

        // 如果是当前正在执行的任务，则先取消
        if (currentTask.value?.id == taskId) {
          await cancelTask(taskId);
        }

        // 如果需要删除文件
        if (deleteFile && task.targetFilePath.isNotEmpty) {
          final file = File(task.targetFilePath);
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
      Logger.e('Error deleting conversion task: $e');
      return false;
    }
  }

  /// 获取转换任务列表
  List<ConversionTask> getTasks() {
    return conversionTasks;
  }

  /// 获取转换任务
  ///
  /// [taskId] 任务ID
  /// 返回转换任务，未找到返回null
  ConversionTask? getTask(String taskId) {
    final index = conversionTasks.indexWhere((task) => task.id == taskId);
    if (index != -1) {
      return conversionTasks[index];
    }
    return null;
  }

  /// 加载任务列表
  void _loadTasks() {
    try {
      final tasks = _storageProvider.getConversionTasks();
      conversionTasks.assignAll(tasks);

      // 检查是否有未完成的任务
      final pendingTasks = tasks
          .where((task) =>
              task.status == ConversionStatus.pending ||
              task.status == ConversionStatus.converting)
          .toList();

      if (pendingTasks.isNotEmpty) {
        // 将所有未完成任务重置为等待状态
        for (final task in pendingTasks) {
          final updatedTask = task.copyWith(
            status: ConversionStatus.pending,
            updatedAt: DateTime.now(),
          );
          _updateTask(updatedTask);
        }

        // 开始处理下一个任务
        _processNextTask();
      }
    } catch (e) {
      Logger.e('Error loading conversion tasks: $e');
    }
  }

  /// 添加任务到列表和存储
  Future<void> _addTask(ConversionTask task) async {
    conversionTasks.add(task);
    await _storageProvider.addConversionTask(task);
  }

  /// 更新任务
  Future<void> _updateTask(ConversionTask task) async {
    final index = conversionTasks.indexWhere((t) => t.id == task.id);
    if (index != -1) {
      conversionTasks[index] = task;
      await _storageProvider.updateConversionTask(task);
    }
  }

  /// 从列表和存储中移除任务
  Future<void> _removeTask(String taskId) async {
    conversionTasks.removeWhere((task) => task.id == taskId);
    await _storageProvider.removeConversionTask(taskId);
  }

  /// 获取目标文件路径
  Future<String> _getTargetFilePath(
      String sourceFilePath, String format) async {
    final sourceFile = File(sourceFilePath);
    final sourceFileName = sourceFile.path.split('/').last;
    final sourceFileNameWithoutExt = sourceFileName.split('.').first;

    // 获取应用文档目录
    final appDir = await getApplicationDocumentsDirectory();
    final convertDir = Directory('${appDir.path}/converted');

    // 确保目录存在
    if (!await convertDir.exists()) {
      await convertDir.create(recursive: true);
    }

    return '${convertDir.path}/${sourceFileNameWithoutExt}_converted.$format';
  }

  /// 处理下一个任务
  Future<void> _processNextTask() async {
    try {
      // 检查是否有等待中的任务
      final pendingTasks = conversionTasks
          .where((task) => task.status == ConversionStatus.pending)
          .toList();

      if (pendingTasks.isEmpty) {
        isConverting.value = false;
        currentTask.value = null;
        return;
      }

      // 获取第一个等待中的任务
      final task = pendingTasks.first;

      // 更新任务状态
      final updatedTask = task.copyWith(
        status: ConversionStatus.converting,
        updatedAt: DateTime.now(),
      );

      await _updateTask(updatedTask);

      // 设置当前任务
      currentTask.value = updatedTask;
      isConverting.value = true;

      // 开始转换
      await _convertVideo(updatedTask);
    } catch (e) {
      Logger.e('Error processing next task: $e');
      isConverting.value = false;
      currentTask.value = null;
    }
  }

  /// 转换视频
  Future<void> _convertVideo(ConversionTask task) async {
    FFmpegSession? session;
    try {
      // 检查源文件是否存在
      final sourceFile = File(task.sourceFilePath);
      if (!await sourceFile.exists()) {
        throw Exception('Source file does not exist: ${task.sourceFilePath}');
      }

      // 获取视频信息
      final duration = await _getVideoDuration(task.sourceFilePath);

      // 构建FFmpeg命令
      final command = _buildFFmpegCommand(task);
      Logger.d('Starting video conversion: $command');

      // 创建目标文件目录
      final targetFile = File(task.targetFilePath);
      final targetDir = targetFile.parent;
      if (!await targetDir.exists()) {
        await targetDir.create(recursive: true);
      }

      // 更新任务状态为转换中
      var updatedTask = task.copyWith(
        status: ConversionStatus.converting,
        progress: 0.0,
        updatedAt: DateTime.now(),
      );
      await _updateTask(updatedTask);

      // 执行FFmpeg命令
      session = await FFmpegKit.executeAsync(
        command,
        (session) async {
          // 完成回调
          final returnCode = await session.getReturnCode();

          if (ReturnCode.isSuccess(returnCode)) {
            // 转换成功
            final completedTask = updatedTask.copyWith(
              status: ConversionStatus.completed,
              progress: 1.0,
              updatedAt: DateTime.now(),
              completedAt: DateTime.now(),
            );
            await _updateTask(completedTask);

            Utils.showSnackbar('转换完成', '${task.sourceFilePath.split('/').last} 已转换完成');
          } else if (ReturnCode.isCancel(returnCode)) {
            // 转换被取消
            final canceledTask = updatedTask.copyWith(
              status: ConversionStatus.canceled,
              updatedAt: DateTime.now(),
            );
            await _updateTask(canceledTask);
          } else {
            // 转换失败
            final returnCode = await session.getReturnCode();
            final errorMessage = await session.getAllLogsAsString() ?? 'Unknown error';
            final errorSummary = errorMessage.length > 200 ? errorMessage.substring(0, 200) + '...' : errorMessage;

            final failedTask = updatedTask.copyWith(
              status: ConversionStatus.failed,
              errorMessage: 'Error code: ${returnCode?.getValue() ?? 'unknown'}, Message: $errorSummary',
              updatedAt: DateTime.now(),
            );
            await _updateTask(failedTask);

            Logger.e('Conversion failed with code ${returnCode?.getValue() ?? 'unknown'}: $errorSummary');
            Utils.showSnackbar('转换失败', '视频转换失败，请检查源文件格式', isError: true);
          }

          // 处理下一个任务
          isConverting.value = false;
          currentTask.value = null;
          _processNextTask();
        },
        (log) {
          // 日志回调
          Logger.d('FFmpeg log: ${log.getMessage()}');
        },
        (statistics) {
          // 进度回调
          if (duration > 0) {
            final timeInMs = statistics.getTime();
            final progress = timeInMs / (duration * 1000);

            // 更新进度
            updatedTask = updatedTask.copyWith(
              progress: progress.clamp(0.0, 1.0),
              updatedAt: DateTime.now(),
            );
            _updateTask(updatedTask);

            // 打印转换进度
            final percent = (progress * 100).toStringAsFixed(1);
            Logger.d('Conversion progress: $percent% for task ${task.id}');
          }
        },
      );

      // 保存会话ID，用于取消
      _conversionSessions[task.id] = session;

    } catch (e) {
      Logger.e('Error converting video: $e');

      // 更新任务状态
      final updatedTask = task.copyWith(
        status: ConversionStatus.failed,
        errorMessage: e.toString(),
        updatedAt: DateTime.now(),
      );

      await _updateTask(updatedTask);

      // 处理下一个任务
      isConverting.value = false;
      currentTask.value = null;
      _processNextTask();
    }
  }

  /// 构建FFmpeg命令
  String _buildFFmpegCommand(ConversionTask task) {
    // 解析分辨率
    int width, height;
    switch (task.resolution) {
      case '480p':
        width = 854;
        height = 480;
        break;
      case '720p':
        width = 1280;
        height = 720;
        break;
      case '1080p':
        width = 1920;
        height = 1080;
        break;
      case '2K':
        width = 2560;
        height = 1440;
        break;
      case '4K':
        width = 3840;
        height = 2160;
        break;
      default:
        width = 1280;
        height = 720;
    }

    // 构建命令
    String command;

    // 根据格式选择不同的编码参数
    if (task.format == 'mp3') {
      // 如果是 MP3 格式，只提取音频
      command = '-i "${task.sourceFilePath}" -vn -c:a libmp3lame -q:a 2 "${task.targetFilePath}"';
    } else if (task.format == 'mp4') {
      // MP4 格式使用 H.264 编码
      command = '-i "${task.sourceFilePath}" -c:v libx264 -preset medium -b:v ${task.bitrate}k '
          '-vf scale=$width:$height -c:a aac -b:a 128k -movflags +faststart "${task.targetFilePath}"';
    } else if (task.format == 'webm') {
      // WebM 格式使用 VP9 编码
      command = '-i "${task.sourceFilePath}" -c:v libvpx-vp9 -b:v ${task.bitrate}k '
          '-vf scale=$width:$height -c:a libopus -b:a 128k "${task.targetFilePath}"';
    } else {
      // 其他格式使用通用的 H.264 编码
      command = '-i "${task.sourceFilePath}" -c:v libx264 -preset medium -b:v ${task.bitrate}k '
          '-vf scale=$width:$height -c:a aac -b:a 128k "${task.targetFilePath}"';
    }

    // 添加错误检测和容错参数
    command = '-hide_banner -err_detect ignore_err ' + command;

    Logger.d('FFmpeg command: $command');
    return command;
  }

  /// 获取视频时长（秒）
  Future<double> _getVideoDuration(String filePath) async {
    try {
      // 使用FFprobe获取视频信息
      MediaInformationSession session = await FFprobeKit.getMediaInformation(filePath);
      MediaInformation? mediaInformation = session.getMediaInformation();

      if (mediaInformation != null) {
        String? durationStr = mediaInformation.getDuration();
        if (durationStr != null && durationStr.isNotEmpty) {
          return double.parse(durationStr);
        }
      }

      // 如果无法获取时长，返回默认值
      return 60.0;
    } catch (e) {
      Logger.e('Error getting video duration: $e');
      return 60.0;
    }
  }
}
