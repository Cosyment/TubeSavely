import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
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

class ThemeExit {
  static ThemeData get(isDarkMode) {
    return isDarkMode
        ? ThemeData(
            useMaterial3: true,
            brightness: Brightness.dark,
            primaryColor: const Color(0XFF202123),
            scaffoldBackgroundColor: const Color(0x3026242e),
            hintColor: Colors.white)
        : ThemeData(
            useMaterial3: true,
            brightness: Brightness.light,
            primaryColor: const Color(0xFF7776FF), //航栏颜色
            scaffoldBackgroundColor: const Color(0XFFFFFFFF), //背景颜色
          );
  }

  static Future<bool> isDark() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool("isDark") ?? false;
  }

  static setDark(b) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool("isDark", b);
  }
}
