import 'package:get/get.dart';
import '../../services/video_converter_service.dart';
import '../../utils/logger.dart';

/// 视频转换仓库
///
/// 负责管理视频转换任务，是业务逻辑层与视频转换服务之间的桥梁
class VideoConverterRepository {
  final VideoConverterService _videoConverterService = Get.find<VideoConverterService>();

  /// 获取转换任务列表
  List<ConversionTask> getConversionTasks() {
    return _videoConverterService.getTasks();
  }

  /// 获取转换任务
  ConversionTask? getConversionTask(String taskId) {
    return _videoConverterService.getTask(taskId);
  }

  /// 创建视频转换任务
  ///
  /// [sourceFilePath] 源文件路径
  /// [format] 目标格式
  /// [resolution] 分辨率
  /// [bitrate] 比特率
  /// 返回创建的转换任务
  Future<ConversionTask?> createConversionTask({
    required String sourceFilePath,
    required String format,
    String resolution = '720p',
    int bitrate = 1500,
  }) async {
    try {
      Logger.d('Creating conversion task for video: $sourceFilePath');
      return await _videoConverterService.createTask(
        sourceFilePath: sourceFilePath,
        format: format,
        resolution: resolution,
        bitrate: bitrate,
      );
    } catch (e) {
      Logger.e('Error creating conversion task: $e');
      return null;
    }
  }

  /// 取消转换任务
  ///
  /// [taskId] 任务ID
  /// 返回是否成功
  Future<bool> cancelConversionTask(String taskId) async {
    try {
      Logger.d('Canceling conversion task: $taskId');
      return await _videoConverterService.cancelTask(taskId);
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
  Future<bool> deleteConversionTask(String taskId, {bool deleteFile = false}) async {
    try {
      Logger.d('Deleting conversion task: $taskId, deleteFile: $deleteFile');
      return await _videoConverterService.deleteTask(taskId, deleteFile: deleteFile);
    } catch (e) {
      Logger.e('Error deleting conversion task: $e');
      return false;
    }
  }
}
