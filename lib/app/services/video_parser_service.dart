import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../data/models/video_model.dart';
import '../utils/constants.dart';
import '../utils/logger.dart';

/// 视频解析服务
///
/// 负责解析不同平台的视频链接，提取视频信息
class VideoParserService extends GetxService {
  /// 初始化服务
  Future<VideoParserService> init() async {
    Logger.d('VideoParserService initialized');
    return this;
  }

  /// 解析视频链接
  ///
  /// [url] 视频链接
  /// 返回解析后的视频模型，解析失败返回null
  Future<VideoModel?> parseVideo(String url) async {
    try {
      // 判断URL属于哪个平台
      final platform = _detectPlatform(url);
      
      if (platform == null) {
        Logger.w('Unsupported platform: $url');
        return null;
      }
      
      // 根据平台调用不同的解析方法
      switch (platform) {
        case 'YouTube':
          return await _parseYouTube(url);
        case 'Bilibili':
          return await _parseBilibili(url);
        case 'TikTok':
          return await _parseTikTok(url);
        case 'Instagram':
          return await _parseInstagram(url);
        default:
          // 使用通用API解析
          return await _parseGeneric(url);
      }
    } catch (e) {
      Logger.e('Error parsing video: $e');
      return null;
    }
  }

  /// 检测URL属于哪个平台
  ///
  /// [url] 视频链接
  /// 返回平台名称，未识别返回null
  String? _detectPlatform(String url) {
    for (final platform in Constants.SUPPORTED_PLATFORMS) {
      final regex = RegExp(platform['regex']);
      if (regex.hasMatch(url)) {
        return platform['name'];
      }
    }
    return null;
  }

  /// 解析YouTube视频
  ///
  /// [url] YouTube视频链接
  /// 返回解析后的视频模型
  Future<VideoModel?> _parseYouTube(String url) async {
    try {
      // 调用API解析
      return await _parseGeneric(url);
    } catch (e) {
      Logger.e('Error parsing YouTube video: $e');
      return null;
    }
  }

  /// 解析Bilibili视频
  ///
  /// [url] Bilibili视频链接
  /// 返回解析后的视频模型
  Future<VideoModel?> _parseBilibili(String url) async {
    try {
      // 调用API解析
      return await _parseGeneric(url);
    } catch (e) {
      Logger.e('Error parsing Bilibili video: $e');
      return null;
    }
  }

  /// 解析TikTok视频
  ///
  /// [url] TikTok视频链接
  /// 返回解析后的视频模型
  Future<VideoModel?> _parseTikTok(String url) async {
    try {
      // 调用API解析
      return await _parseGeneric(url);
    } catch (e) {
      Logger.e('Error parsing TikTok video: $e');
      return null;
    }
  }

  /// 解析Instagram视频
  ///
  /// [url] Instagram视频链接
  /// 返回解析后的视频模型
  Future<VideoModel?> _parseInstagram(String url) async {
    try {
      // 调用API解析
      return await _parseGeneric(url);
    } catch (e) {
      Logger.e('Error parsing Instagram video: $e');
      return null;
    }
  }

  /// 通用视频解析方法
  ///
  /// [url] 视频链接
  /// 返回解析后的视频模型
  Future<VideoModel?> _parseGeneric(String url) async {
    try {
      final apiUrl = '${Constants.API_BASE_URL}/parse?url=${Uri.encodeComponent(url)}';
      
      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {'Accept': 'application/json'},
      ).timeout(Duration(milliseconds: Constants.API_TIMEOUT));
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return VideoModel.fromJson(data);
      } else {
        Logger.e('API error: ${response.statusCode} ${response.body}');
        return null;
      }
    } catch (e) {
      Logger.e('Error in generic parser: $e');
      return null;
    }
  }
}
