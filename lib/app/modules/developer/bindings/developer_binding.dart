import 'package:get/get.dart';
import '../controllers/developer_controller.dart';

/// 开发者测试页面绑定
class DeveloperBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DeveloperController>(
      () => DeveloperController(),
    );
  }
}
