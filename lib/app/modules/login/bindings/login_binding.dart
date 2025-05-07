import 'package:get/get.dart';
import '../controllers/login_controller.dart';

/// 登录页面绑定
class LoginBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<LoginController>(
      () => LoginController(),
    );
  }
}
