import 'package:get/get.dart';
import '../models/video_model.dart';
import '../providers/api_provider.dart';
import '../providers/storage_provider.dart';

class VideoRepository {
  final ApiProvider _apiProvider = Get.find<ApiProvider>();
  final StorageProvider _storageProvider = Get.find<StorageProvider>();

  // 解析视频链接
  Future<VideoModel?> parseVideo(String url) async {
    try {
      final response = await _apiProvider.parseVideo(url);
      if (response.status.isOk) {
        return VideoModel.fromJson(response.body);
      }
      return null;
    } catch (e) {
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
