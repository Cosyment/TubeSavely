import 'package:get/get.dart';
import '../controllers/convert_controller.dart';

class ConvertBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ConvertController>(
      () => ConvertController(),
    );
  }
}
