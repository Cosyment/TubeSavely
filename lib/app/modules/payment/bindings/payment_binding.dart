import 'package:get/get.dart';
import 'package:tubesavely/app/data/repositories/payment_repository.dart';
import '../controllers/payment_controller.dart';

class PaymentBinding extends Bindings {
  @override
  void dependencies() {
    // 注册支付仓库
    Get.lazyPut<PaymentRepository>(
      () => PaymentRepository(),
    );
    
    // 注册支付控制器
    Get.lazyPut<PaymentController>(
      () => PaymentController(),
    );
  }
}
