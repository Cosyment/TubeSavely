import 'package:flutter_easyloading/flutter_easyloading.dart';

class ToastUtil {
  ToastUtil._() {
    // EasyLoading.init();
  }

  static success(String msg) {
    EasyLoading.showSuccess(msg, duration: const Duration(seconds: 1));
  }

  static error(String msg) {
    EasyLoading.showError(msg, duration: const Duration(milliseconds: 1500));
  }

  static loading({String msg = 'loading'}) {
    EasyLoading.show(status: 'loading...');
  }

  static dismiss() {
    EasyLoading.dismiss();
  }
}
