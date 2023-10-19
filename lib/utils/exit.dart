

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../constants/colors.dart';
import 'pub_method.dart';

class ToastExit {
  static show(msg) {
    Fluttertoast.showToast(
        msg: msg,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        timeInSecForIosWeb: 1,
        backgroundColor: primaryColor,
        textColor: Colors.white,
        fontSize: 28.sp);
  }
}

class UserExit {
  static Future<String?> isLogin() async {
    return await PubMethodUtils.getSharedPreferences("userId");
  }
}
