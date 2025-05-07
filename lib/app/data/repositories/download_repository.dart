import 'package:get/get.dart';
import 'package:background_downloader/background_downloader.dart';
import '../models/download_task_model.dart';
import '../models/video_model.dart';
import '../providers/storage_provider.dart';
import '../../services/download_service.dart';
import '../../utils/logger.dart';
import '../../utils/utils.dart';

class DownloadRepository {
  final DownloadService _downloadService = Get.find<DownloadService>();
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
      final String fileName =
          '${video.title.replaceAll(RegExp(r'[^\w\s.-]'), '_')}_$quality.$format';

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
      final downloadDirectory =
          savePath ?? _downloadService.getDefaultDownloadPath();
      final DownloadTask bgTask = DownloadTask(
        url: downloadUrl,
        filename: fileName,
        directory: downloadDirectory,
        baseDirectory: BaseDirectory.applicationDocuments,
        updates: Updates.statusAndProgress,
        requiresWiFi:
            _storageProvider.getSetting('wifi_only', defaultValue: true) ??
                false,
        retries: 3,
        allowPause: true,
        metaData: taskId,
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
      return await _downloadService.pauseTask(taskId);
    } catch (e) {
      Utils.showSnackbar('暂停失败', '暂停下载任务时出错: $e', isError: true);
      return false;
    }
  }

  // 恢复下载任务
  Future<bool> resumeDownloadTask(String taskId) async {
    try {
      return await _downloadService.resumeTask(taskId);
    } catch (e) {
      Utils.showSnackbar('恢复失败', '恢复下载任务时出错: $e', isError: true);
      return false;
    }
  }

  // 取消下载任务
  Future<bool> cancelDownloadTask(String taskId) async {
    try {
      return await _downloadService.cancelTask(taskId);
    } catch (e) {
      Utils.showSnackbar('取消失败', '取消下载任务时出错: $e', isError: true);
      return false;
    }
  }

  // 删除下载任务
  Future<bool> deleteDownloadTask(String taskId) async {
    try {
      return await _downloadService.deleteTask(taskId);
    } catch (e) {
      Utils.showSnackbar('删除失败', '删除下载任务时出错: $e', isError: true);
      return false;
    }
  }
}
