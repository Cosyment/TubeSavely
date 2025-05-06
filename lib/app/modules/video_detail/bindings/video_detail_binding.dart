import 'package:get/get.dart';
import '../controllers/video_detail_controller.dart';

class VideoDetailBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<VideoDetailController>(
      () => VideoDetailController(),
    );
  }
}
