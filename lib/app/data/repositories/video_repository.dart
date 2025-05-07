import 'package:get/get.dart';
import '../models/video_model.dart';
import '../providers/api_provider.dart';
import '../providers/storage_provider.dart';
import '../../services/video_parser_service.dart';
import '../../utils/logger.dart';
import '../../utils/constants.dart';

class VideoRepository {
  final ApiProvider _apiProvider = Get.find<ApiProvider>();
  final StorageProvider _storageProvider = Get.find<StorageProvider>();
  final VideoParserService _videoParserService = Get.find<VideoParserService>();

  // 解析视频链接
  Future<VideoModel?> parseVideo(String url) async {
    try {
      // 首先尝试使用视频解析服务解析
      final videoModel = await _videoParserService.parseVideo(url);
      if (videoModel != null) {
        Logger.d('Video parsed successfully using VideoParserService');
        return videoModel;
      }

      // 如果解析服务失败，尝试使用API解析
      Logger.d('Falling back to API for video parsing');
      final response = await _apiProvider.parseVideo(url);
      if (response.status.isOk) {
        return VideoModel.fromJson(response.body);
      }

      Logger.w('Failed to parse video: $url');
      return null;
    } catch (e) {
      Logger.e('Error parsing video: $e');
      return null;
    }
  }

  // 获取下载历史
  List<VideoModel> getDownloadHistory() {
    return _storageProvider.getDownloadHistory();
  }

  // 添加到下载历史
  Future<void> addToDownloadHistory(VideoModel video) async {
    await _storageProvider.addToDownloadHistory(video);
  }

  // 清除下载历史
  Future<void> clearDownloadHistory() async {
    await _storageProvider.clearDownloadHistory();
  }

  // 获取支持的平台
  Future<List<Map<String, dynamic>>> getSupportedPlatforms() async {
    try {
      final response = await _apiProvider.getSupportedPlatforms();
      if (response.status.isOk) {
        return List<Map<String, dynamic>>.from(response.body);
      }
      return Constants.SUPPORTED_PLATFORMS;
    } catch (e) {
      return Constants.SUPPORTED_PLATFORMS;
    }
  }
}
