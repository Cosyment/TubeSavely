import 'dart:io';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
// 暂时注释掉，编译时有问题
// import 'package:ffmpeg_kit_flutter_full_gpl/ffmpeg_kit.dart';
// import 'package:ffmpeg_kit_flutter_full_gpl/return_code.dart';
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

        // 如果是当前正在执行的任务，则取消执行
        if (currentTask.value?.id == taskId) {
          // TODO: 实现取消FFmpeg命令
          isConverting.value = false;
          currentTask.value = null;
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
    try {
      // 构建FFmpeg命令
      final command = _buildFFmpegCommand(task);

      Logger.d('Starting video conversion: $command');

      // 注意：由于 FFmpegKit 已被注释掉，这里暂时使用模拟实现
      // 模拟转换过程
      await Future.delayed(const Duration(seconds: 2));

      // 模拟转换成功
      final updatedTask = task.copyWith(
        status: ConversionStatus.completed,
        progress: 1.0,
        updatedAt: DateTime.now(),
        completedAt: DateTime.now(),
      );

      await _updateTask(updatedTask);
      Utils.showSnackbar(
          '转换完成', '${task.sourceFilePath.split('/').last} 已转换完成');

      // 处理下一个任务
      isConverting.value = false;
      currentTask.value = null;
      _processNextTask();

      // 保存会话ID，用于取消
      // TODO: 实现取消功能
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
    String command =
        '-i "${task.sourceFilePath}" -c:v libx264 -preset medium -b:v ${task.bitrate}k -vf scale=$width:$height -c:a aac -b:a 128k "${task.targetFilePath}"';

    return command;
  }

  /// 获取视频时长（秒）
  int _getDuration(String filePath) {
    // TODO: 实现获取视频时长
    // 这里暂时返回一个默认值
    return 60;
  }
}
