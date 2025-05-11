import 'package:get/get.dart';
import '../controllers/transaction_history_controller.dart';

class TransactionHistoryBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<TransactionHistoryController>(
      () => TransactionHistoryController(),
    );
  }
}
