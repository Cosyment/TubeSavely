import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'pub_method.dart';

class ToastExit {
  static show(msg) {
    Fluttertoast.showToast(
        msg: msg,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        timeInSecForIosWeb: 1,
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
            hintColor: Color(0XFF202123),
            highlightColor: Colors.grey,
            scaffoldBackgroundColor: const Color(0x3026242e)) //背景颜色
        : ThemeData(
            useMaterial3: true,
            brightness: Brightness.light,
            primaryColor: const Color(0xFF7776FF),
            hintColor: Colors.grey,
            highlightColor: const Color(0xFF7776FF),
            scaffoldBackgroundColor: const Color(0XFFFFFFFF));
  }

  static Future<bool> isDark() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool("isDark") ?? true;
  }

  static setDark(b) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool("isDark", b);
  }
}
