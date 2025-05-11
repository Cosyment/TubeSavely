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

  // 获取热门视频
  Future<List<VideoModel>> getTrendingVideos() async {
    try {
      final response = await _apiProvider.getTrendingVideos();
      if (response.status.isOk) {
        return (response.body as List)
            .map((item) => VideoModel.fromJson(item))
            .toList();
      }

      // 如果API调用失败，返回模拟数据
      return _getMockTrendingVideos();
    } catch (e) {
      Logger.e('Error getting trending videos: $e');
      // 返回模拟数据
      return _getMockTrendingVideos();
    }
  }

  // 获取模拟热门视频数据
  List<VideoModel> _getMockTrendingVideos() {
    return [
      VideoModel(
        id: '1',
        title: '如何使用Flutter构建跨平台应用',
        url: 'https://www.youtube.com/watch?v=example1',
        platform: 'YouTube',
        thumbnail: 'https://i.ytimg.com/vi/example1/maxresdefault.jpg',
        author: 'Flutter官方',
        duration: 1245, // 20:45
        qualities: [],
        formats: [],
      ),
      VideoModel(
        id: '2',
        title: '2023年最受欢迎的10款手机评测',
        url: 'https://www.youtube.com/watch?v=example2',
        platform: 'YouTube',
        thumbnail: 'https://i.ytimg.com/vi/example2/maxresdefault.jpg',
        author: '数码评测',
        duration: 1532, // 25:32
        qualities: [],
        formats: [],
      ),
      VideoModel(
        id: '3',
        title: '学习Dart语言的完整指南 - 从入门到精通',
        url: 'https://www.bilibili.com/video/example3',
        platform: 'Bilibili',
        thumbnail: 'https://i0.hdslb.com/bfs/archive/example3.jpg',
        author: '编程学习',
        duration: 3600, // 60:00
        qualities: [],
        formats: [],
      ),
      VideoModel(
        id: '4',
        title: '如何提高工作效率 - 时间管理技巧分享',
        url: 'https://www.youtube.com/watch?v=example4',
        platform: 'YouTube',
        thumbnail: 'https://i.ytimg.com/vi/example4/maxresdefault.jpg',
        author: '个人成长',
        duration: 845, // 14:05
        qualities: [],
        formats: [],
      ),
      VideoModel(
        id: '5',
        title: '2023年最佳旅游目的地推荐',
        url: 'https://www.bilibili.com/video/example5',
        platform: 'Bilibili',
        thumbnail: 'https://i0.hdslb.com/bfs/archive/example5.jpg',
        author: '旅行日记',
        duration: 1120, // 18:40
        qualities: [],
        formats: [],
      ),
    ];
  }
}
