import 'dart:async';

import 'package:get/get.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:tubesavely/app/data/models/video_model.dart';
import 'package:tubesavely/app/data/repositories/video_player_repository.dart';
import 'package:tubesavely/app/services/video_player_service.dart';
import 'package:tubesavely/app/utils/logger.dart';
import 'package:tubesavely/app/utils/utils.dart';

/// 视频播放控制器
class VideoPlayerController extends GetxController {
  final VideoPlayerRepository _videoPlayerRepository = Get.find<VideoPlayerRepository>();

  // 视频控制器
  late final VideoController videoController;

  // 是否显示控制器
  final RxBool showControls = true.obs;

  // 控制器隐藏计时器
  Timer? _hideControlsTimer;

  // 是否拖动进度条
  final RxBool isDraggingProgress = false.obs;

  // 拖动进度值
  final RxDouble dragProgress = 0.0.obs;

  // 当前视频
  final Rx<VideoModel?> currentVideo = Rx<VideoModel?>(null);

  // 播放状态
  final Rx<PlayerStatus> status = Rx<PlayerStatus>(PlayerStatus.idle);

  // 播放进度
  final RxDouble position = 0.0.obs;

  // 视频总时长
  final RxDouble duration = 0.0.obs;

  // 音量
  final RxDouble volume = 1.0.obs;

  // 是否静音
  final RxBool isMuted = false.obs;

  // 是否全屏
  final RxBool isFullscreen = false.obs;

  @override
  void onInit() {
    super.onInit();
    Logger.d('VideoPlayerController initialized');

    // 创建视频控制器
    videoController = _videoPlayerRepository.createVideoController();

    // 获取传递的参数
    if (Get.arguments != null) {
      if (Get.arguments is VideoModel) {
        // 如果传递的是视频模型
        final video = Get.arguments as VideoModel;
        currentVideo.value = video;

        // 获取最高质量的视频URL
        String videoUrl = '';
        if (video.qualities.isNotEmpty) {
          videoUrl = video.qualities.first.url;
        } else if (video.formats.isNotEmpty) {
          videoUrl = video.formats.first.url;
        } else {
          videoUrl = video.url;
        }

        // 播放视频
        if (videoUrl.isNotEmpty) {
          playVideo(url: videoUrl, video: video);
        }
      } else if (Get.arguments is String) {
        // 如果传递的是URL字符串
        final url = Get.arguments as String;
        if (url.startsWith('http')) {
          // 网络视频
          playVideo(url: url);
        } else {
          // 本地视频
          playLocalFile(url);
        }
      }
    }

    // 定时更新状态
    Timer.periodic(const Duration(milliseconds: 500), (_) {
      // 更新播放状态
      status.value = _videoPlayerRepository.status;

      // 更新播放进度
      if (!isDraggingProgress.value) {
        position.value = _videoPlayerRepository.position;
      }

      // 更新视频总时长
      duration.value = _videoPlayerRepository.duration;

      // 更新音量
      volume.value = _videoPlayerRepository.volume;

      // 更新静音状态
      isMuted.value = _videoPlayerRepository.isMuted;

      // 更新全屏状态
      isFullscreen.value = _videoPlayerRepository.isFullscreen;
    });
  }

  @override
  void onClose() {
    _hideControlsTimer?.cancel();
    super.onClose();
  }

  /// 播放视频
  ///
  /// [url] 视频URL
  /// [video] 视频模型（可选）
  Future<void> playVideo({required String url, VideoModel? video}) async {
    try {
      await _videoPlayerRepository.playVideo(url: url, video: video);
      if (video != null) {
        currentVideo.value = video;
      }
      _resetControlsTimer();
    } catch (e) {
      Logger.e('Error playing video: $e');
      Utils.showSnackbar('错误', '播放视频时出错: $e', isError: true);
    }
  }

  /// 播放本地视频
  ///
  /// [filePath] 本地视频文件路径
  Future<void> playLocalFile(String filePath) async {
    try {
      await _videoPlayerRepository.playLocalFile(filePath);
      currentVideo.value = null;
      _resetControlsTimer();
    } catch (e) {
      Logger.e('Error playing local file: $e');
      Utils.showSnackbar('错误', '播放本地视频时出错: $e', isError: true);
    }
  }

  /// 暂停/继续播放
  void togglePlayPause() {
    if (status.value == PlayerStatus.playing) {
      _videoPlayerRepository.pauseVideo();
    } else if (status.value == PlayerStatus.paused || status.value == PlayerStatus.completed) {
      _videoPlayerRepository.resumeVideo();
    }
    _resetControlsTimer();
  }

  /// 停止播放
  void stopVideo() {
    _videoPlayerRepository.stopVideo();
    showControls.value = true;
    if (_hideControlsTimer != null) {
      _hideControlsTimer!.cancel();
      _hideControlsTimer = null;
    }
  }

  /// 跳转到指定位置
  ///
  /// [seconds] 秒数
  Future<void> seekTo(double seconds) async {
    await _videoPlayerRepository.seekTo(seconds);
    _resetControlsTimer();
  }

  /// 设置音量
  ///
  /// [value] 音量值，范围 0.0 - 1.0
  Future<void> setVolume(double value) async {
    await _videoPlayerRepository.setVolume(value);
    _resetControlsTimer();
  }

  /// 静音/取消静音
  Future<void> toggleMute() async {
    await _videoPlayerRepository.toggleMute();
    _resetControlsTimer();
  }

  /// 切换全屏状态
  void toggleFullscreen() {
    _videoPlayerRepository.toggleFullscreen();
    _resetControlsTimer();
  }

  /// 显示/隐藏控制器
  void toggleControls() {
    showControls.value = !showControls.value;
    _resetControlsTimer();
  }

  /// 开始拖动进度条
  void startDraggingProgress(double value) {
    isDraggingProgress.value = true;
    dragProgress.value = value;
  }

  /// 更新拖动进度
  void updateDragProgress(double value) {
    dragProgress.value = value;
  }

  /// 结束拖动进度条
  Future<void> endDraggingProgress() async {
    isDraggingProgress.value = false;
    await seekTo(dragProgress.value * duration.value);
  }

  /// 获取格式化的当前播放时间
  String getFormattedPosition() {
    return _videoPlayerRepository.getFormattedPosition();
  }

  /// 获取格式化的视频总时长
  String getFormattedDuration() {
    return _videoPlayerRepository.getFormattedDuration();
  }

  /// 重置控制器隐藏计时器
  void _resetControlsTimer() {
    _hideControlsTimer?.cancel();

    // 如果正在播放，则设置计时器自动隐藏控制器
    if (status.value == PlayerStatus.playing) {
      _hideControlsTimer = Timer(const Duration(seconds: 3), () {
        if (status.value == PlayerStatus.playing && !isDraggingProgress.value) {
          showControls.value = false;
        }
      });
    } else {
      // 如果不是播放状态，则始终显示控制器
      showControls.value = true;
    }
  }
}
