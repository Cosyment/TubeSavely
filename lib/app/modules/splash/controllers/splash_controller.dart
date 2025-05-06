import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../routes/app_pages.dart';
import '../../../utils/logger.dart';

class SplashController extends GetxController with GetSingleTickerProviderStateMixin {
  late AnimationController animationController;
  late Animation<double> animation;

  @override
  void onInit() {
    super.onInit();
    Logger.d('SplashController initialized');

    // 初始化动画控制器
    animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    // 创建动画
    animation = CurvedAnimation(
      parent: animationController,
      curve: Curves.easeOut,
    );

    // 启动动画
    animationController.forward();

    // 延迟3秒后导航到首页
    Future.delayed(const Duration(seconds: 3), () {
      Get.offAllNamed(Routes.HOME);
    });
  }

  @override
  void onClose() {
    // 释放动画控制器
    animationController.dispose();
    super.onClose();
  }
}
