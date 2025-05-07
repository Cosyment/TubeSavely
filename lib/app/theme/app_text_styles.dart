import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// 应用文本样式定义
class AppTextStyles {
  AppTextStyles._();

  // 标题样式
  static TextStyle get displayLarge => TextStyle(
        fontSize: 57.sp,
        fontWeight: FontWeight.w400,
        letterSpacing: -0.25,
        height: 1.12,
      );

  static TextStyle get displayMedium => TextStyle(
        fontSize: 45.sp,
        fontWeight: FontWeight.w400,
        letterSpacing: 0,
        height: 1.16,
      );

  static TextStyle get displaySmall => TextStyle(
        fontSize: 36.sp,
        fontWeight: FontWeight.w400,
        letterSpacing: 0,
        height: 1.22,
      );

  static TextStyle get headlineLarge => TextStyle(
        fontSize: 32.sp,
        fontWeight: FontWeight.w400,
        letterSpacing: 0,
        height: 1.25,
      );

  static TextStyle get headlineMedium => TextStyle(
        fontSize: 28.sp,
        fontWeight: FontWeight.w400,
        letterSpacing: 0,
        height: 1.29,
      );

  static TextStyle get headlineSmall => TextStyle(
        fontSize: 24.sp,
        fontWeight: FontWeight.w400,
        letterSpacing: 0,
        height: 1.33,
      );

  static TextStyle get titleLarge => TextStyle(
        fontSize: 22.sp,
        fontWeight: FontWeight.w500,
        letterSpacing: 0,
        height: 1.27,
      );

  static TextStyle get titleMedium => TextStyle(
        fontSize: 16.sp,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.15,
        height: 1.5,
      );

  static TextStyle get titleSmall => TextStyle(
        fontSize: 14.sp,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.1,
        height: 1.43,
      );

  static TextStyle get labelLarge => TextStyle(
        fontSize: 14.sp,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.1,
        height: 1.43,
      );

  static TextStyle get labelMedium => TextStyle(
        fontSize: 12.sp,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.5,
        height: 1.33,
      );

  static TextStyle get labelSmall => TextStyle(
        fontSize: 11.sp,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.5,
        height: 1.45,
      );

  static TextStyle get bodyLarge => TextStyle(
        fontSize: 16.sp,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.5,
        height: 1.5,
      );

  static TextStyle get bodyMedium => TextStyle(
        fontSize: 14.sp,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.25,
        height: 1.43,
      );

  static TextStyle get bodySmall => TextStyle(
        fontSize: 12.sp,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.4,
        height: 1.33,
      );
}
