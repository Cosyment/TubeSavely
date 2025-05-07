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
      // 提取视频ID
      String? videoId = _extractYouTubeVideoId(url);

      if (videoId == null) {
        Logger.w('Invalid YouTube URL: $url');
        return null;
      }

      Logger.d('Extracted YouTube video ID: $videoId');

      // 构建API请求URL
      final apiUrl =
          'https://www.googleapis.com/youtube/v3/videos?id=$videoId&part=snippet,contentDetails&key=${Constants.YOUTUBE_API_KEY}';

      // 如果没有配置YouTube API密钥，则回退到通用解析方法
      if (Constants.YOUTUBE_API_KEY.isEmpty) {
        Logger.w(
            'YouTube API key not configured, falling back to generic parser');
        return await _parseGeneric(url);
      }

      // 发送请求
      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {'Accept': 'application/json'},
      ).timeout(const Duration(milliseconds: Constants.API_TIMEOUT));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // 检查是否有结果
        if (data['items'] == null || data['items'].isEmpty) {
          Logger.w('No video found with ID: $videoId');
          return null;
        }

        final item = data['items'][0];
        final snippet = item['snippet'];
        final contentDetails = item['contentDetails'];

        // 解析时长
        int? duration;
        if (contentDetails != null && contentDetails['duration'] != null) {
          duration = _parseDuration(contentDetails['duration']);
        }

        // 构建视频模型
        return VideoModel(
          id: videoId,
          title: snippet['title'] ?? 'Unknown Title',
          url: url,
          thumbnail: snippet['thumbnails']?['high']?['url'] ??
              snippet['thumbnails']?['default']?['url'],
          platform: 'YouTube',
          author: snippet['channelTitle'],
          authorUrl: 'https://www.youtube.com/channel/${snippet['channelId']}',
          duration: duration,
          qualities: _generateYouTubeQualities(videoId),
          formats: _generateYouTubeFormats(videoId),
          createdAt: DateTime.now(),
        );
      } else {
        Logger.e('YouTube API error: ${response.statusCode} ${response.body}');
        // 回退到通用解析方法
        return await _parseGeneric(url);
      }
    } catch (e) {
      Logger.e('Error parsing YouTube video: $e');
      // 回退到通用解析方法
      return await _parseGeneric(url);
    }
  }

  /// 提取YouTube视频ID
  ///
  /// [url] YouTube视频链接
  /// 返回视频ID，如果无法提取则返回null
  String? _extractYouTubeVideoId(String url) {
    // 标准YouTube URL格式: https://www.youtube.com/watch?v=VIDEO_ID
    RegExp regExp1 = RegExp(r'youtube\.com/watch\?v=([^&]+)');

    // 短链接格式: https://youtu.be/VIDEO_ID
    RegExp regExp2 = RegExp(r'youtu\.be/([^?]+)');

    // 嵌入格式: https://www.youtube.com/embed/VIDEO_ID
    RegExp regExp3 = RegExp(r'youtube\.com/embed/([^?]+)');

    // 尝试匹配各种格式
    Match? match = regExp1.firstMatch(url);
    if (match != null && match.groupCount >= 1) {
      return match.group(1);
    }

    match = regExp2.firstMatch(url);
    if (match != null && match.groupCount >= 1) {
      return match.group(1);
    }

    match = regExp3.firstMatch(url);
    if (match != null && match.groupCount >= 1) {
      return match.group(1);
    }

    return null;
  }

  /// 解析ISO 8601时长格式
  ///
  /// [isoDuration] ISO 8601格式的时长字符串，例如 "PT1H30M15S"
  /// 返回总秒数
  int _parseDuration(String isoDuration) {
    // 匹配小时、分钟和秒
    RegExp hourRegExp = RegExp(r'(\d+)H');
    RegExp minuteRegExp = RegExp(r'(\d+)M');
    RegExp secondRegExp = RegExp(r'(\d+)S');

    int hours = 0;
    int minutes = 0;
    int seconds = 0;

    // 提取小时
    Match? hourMatch = hourRegExp.firstMatch(isoDuration);
    if (hourMatch != null && hourMatch.groupCount >= 1) {
      hours = int.parse(hourMatch.group(1)!);
    }

    // 提取分钟
    Match? minuteMatch = minuteRegExp.firstMatch(isoDuration);
    if (minuteMatch != null && minuteMatch.groupCount >= 1) {
      minutes = int.parse(minuteMatch.group(1)!);
    }

    // 提取秒
    Match? secondMatch = secondRegExp.firstMatch(isoDuration);
    if (secondMatch != null && secondMatch.groupCount >= 1) {
      seconds = int.parse(secondMatch.group(1)!);
    }

    // 计算总秒数
    return hours * 3600 + minutes * 60 + seconds;
  }

  /// 生成YouTube视频质量选项
  ///
  /// [videoId] YouTube视频ID
  /// 返回质量选项列表
  List<VideoQuality> _generateYouTubeQualities(String videoId) {
    // 这里我们生成常见的YouTube质量选项
    // 实际应用中，可能需要通过其他API或库获取真实的质量选项
    return [
      VideoQuality(
        label: '1080P',
        height: 1080,
        width: 1920,
        bitrate: 8000000,
        url: 'https://www.youtube.com/watch?v=$videoId&quality=hd1080',
      ),
      VideoQuality(
        label: '720P',
        height: 720,
        width: 1280,
        bitrate: 5000000,
        url: 'https://www.youtube.com/watch?v=$videoId&quality=hd720',
      ),
      VideoQuality(
        label: '480P',
        height: 480,
        width: 854,
        bitrate: 2500000,
        url: 'https://www.youtube.com/watch?v=$videoId&quality=large',
      ),
      VideoQuality(
        label: '360P',
        height: 360,
        width: 640,
        bitrate: 1000000,
        url: 'https://www.youtube.com/watch?v=$videoId&quality=medium',
      ),
    ];
  }

  /// 生成YouTube视频格式选项
  ///
  /// [videoId] YouTube视频ID
  /// 返回格式选项列表
  List<VideoFormat> _generateYouTubeFormats(String videoId) {
    // 这里我们生成常见的YouTube格式选项
    // 实际应用中，可能需要通过其他API或库获取真实的格式选项
    return [
      VideoFormat(
        label: 'MP4',
        mimeType: 'video/mp4',
        url: 'https://www.youtube.com/watch?v=$videoId&fmt=18',
      ),
      VideoFormat(
        label: 'WebM',
        mimeType: 'video/webm',
        url: 'https://www.youtube.com/watch?v=$videoId&fmt=43',
      ),
      VideoFormat(
        label: 'MP3',
        mimeType: 'audio/mp3',
        url: 'https://www.youtube.com/watch?v=$videoId&fmt=140',
      ),
    ];
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
      final apiUrl =
          '${Constants.API_BASE_URL}/parse?url=${Uri.encodeComponent(url)}';

      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {'Accept': 'application/json'},
      ).timeout(const Duration(milliseconds: Constants.API_TIMEOUT));

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
