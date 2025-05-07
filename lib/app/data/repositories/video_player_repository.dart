import 'package:get/get.dart';
import 'package:media_kit_video/media_kit_video.dart';
import '../../services/video_player_service.dart';
import '../models/video_model.dart';
import '../../utils/logger.dart';

/// 视频播放仓库
///
/// 负责管理视频播放，是业务逻辑层与视频播放服务之间的桥梁
class VideoPlayerRepository {
  final VideoPlayerService _videoPlayerService = Get.find<VideoPlayerService>();

  /// 获取当前播放状态
  PlayerStatus get status => _videoPlayerService.status.value;

  /// 获取当前播放视频
  VideoModel? get currentVideo => _videoPlayerService.currentVideo.value;

  /// 获取当前播放URL
  String get currentUrl => _videoPlayerService.currentUrl.value;

  /// 获取当前播放进度（秒）
  double get position => _videoPlayerService.position.value;

  /// 获取视频总时长（秒）
  double get duration => _videoPlayerService.duration.value;

  /// 获取音量
  double get volume => _videoPlayerService.volume.value;

  /// 是否静音
  bool get isMuted => _videoPlayerService.isMuted.value;

  /// 是否全屏
  bool get isFullscreen => _videoPlayerService.isFullscreen.value;

  /// 创建视频控制器
  ///
  /// 用于在UI中显示视频
  VideoController createVideoController() {
    try {
      Logger.d('Creating video controller');
      return _videoPlayerService.createVideoController();
    } catch (e) {
      Logger.e('Error creating video controller: $e');
      rethrow;
    }
  }

  /// 播放视频
  ///
  /// [url] 视频URL
  /// [video] 视频模型（可选）
  Future<void> playVideo({required String url, VideoModel? video}) async {
    try {
      Logger.d('Playing video: $url');
      await _videoPlayerService.play(url: url, video: video);
    } catch (e) {
      Logger.e('Error playing video: $e');
      rethrow;
    }
  }

  /// 播放本地视频
  ///
  /// [filePath] 本地视频文件路径
  Future<void> playLocalFile(String filePath) async {
    try {
      Logger.d('Playing local file: $filePath');
      await _videoPlayerService.playLocalFile(filePath);
    } catch (e) {
      Logger.e('Error playing local file: $e');
      rethrow;
    }
  }

  /// 暂停播放
  void pauseVideo() {
    try {
      Logger.d('Pausing video');
      _videoPlayerService.pause();
    } catch (e) {
      Logger.e('Error pausing video: $e');
    }
  }

  /// 继续播放
  void resumeVideo() {
    try {
      Logger.d('Resuming video');
      _videoPlayerService.resume();
    } catch (e) {
      Logger.e('Error resuming video: $e');
    }
  }

  /// 停止播放
  void stopVideo() {
    try {
      Logger.d('Stopping video');
      _videoPlayerService.stop();
    } catch (e) {
      Logger.e('Error stopping video: $e');
    }
  }

  /// 跳转到指定位置
  ///
  /// [seconds] 秒数
  Future<void> seekTo(double seconds) async {
    try {
      Logger.d('Seeking to: $seconds seconds');
      await _videoPlayerService.seekTo(seconds);
    } catch (e) {
      Logger.e('Error seeking video: $e');
    }
  }

  /// 设置音量
  ///
  /// [value] 音量值，范围 0.0 - 1.0
  Future<void> setVolume(double value) async {
    try {
      Logger.d('Setting volume: $value');
      await _videoPlayerService.setVolume(value);
    } catch (e) {
      Logger.e('Error setting volume: $e');
    }
  }

  /// 静音/取消静音
  Future<void> toggleMute() async {
    try {
      Logger.d('Toggling mute');
      await _videoPlayerService.toggleMute();
    } catch (e) {
      Logger.e('Error toggling mute: $e');
    }
  }

  /// 切换全屏状态
  void toggleFullscreen() {
    try {
      Logger.d('Toggling fullscreen');
      _videoPlayerService.toggleFullscreen();
    } catch (e) {
      Logger.e('Error toggling fullscreen: $e');
    }
  }

  /// 获取格式化的当前播放时间
  String getFormattedPosition() {
    final pos = position.toInt();
    final minutes = (pos / 60).floor();
    final seconds = pos % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  /// 获取格式化的视频总时长
  String getFormattedDuration() {
    final dur = duration.toInt();
    final minutes = (dur / 60).floor();
    final seconds = dur % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }
}
