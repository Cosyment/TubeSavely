import 'package:flutter_easyloading/flutter_easyloading.dart';

class ToastUtil {
  ToastUtil._() {
    // EasyLoading.init();
  }

  static success(String msg) {
    EasyLoading.showSuccess(msg);
  }

  static error(String msg) {
    EasyLoading.showError(msg);
  }

  static loading({String msg = 'loading'}) {
    EasyLoading.show(status: 'loading...');
  }

  static dismiss() {
    EasyLoading.dismiss();
  }
}
