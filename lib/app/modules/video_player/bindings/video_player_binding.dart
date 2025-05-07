import 'package:get/get.dart';
import '../controllers/video_player_controller.dart';

/// 视频播放页面绑定
class VideoPlayerBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<VideoPlayerController>(
      () => VideoPlayerController(),
    );
  }
}
