import 'package:get/get.dart';
import '../controllers/profile_controller.dart';

/// 用户信息页面绑定
class ProfileBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ProfileController>(
      () => ProfileController(),
    );
  }
}
