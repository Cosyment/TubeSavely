import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../data/repositories/download_repository.dart';
import '../../../data/repositories/video_repository.dart';
import '../../../utils/logger.dart';

class SplashController extends GetxController
    with GetSingleTickerProviderStateMixin {
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
      _navigateToHome();
    });
  }

  // 导航到首页
  void _navigateToHome() {
    try {
      Logger.d('Trying to navigate to home...');

      // 打印已注册的服务
      Logger.d('Checking registered services...');

      // 确保所有必要的服务和仓库都已经初始化完成
      Logger.d('Checking VideoRepository...');
      final videoRepo = Get.find<VideoRepository>();
      Logger.d('VideoRepository found: ${videoRepo.runtimeType}');

      Logger.d('Checking DownloadRepository...');
      final downloadRepo = Get.find<DownloadRepository>();
      Logger.d('DownloadRepository found: ${downloadRepo.runtimeType}');

      Logger.d('All repositories initialized, navigating to main');
      Get.offAllNamed('/main');
    } catch (e) {
      Logger.e('Error navigating to home: $e');

      // 如果初始化失败，延迟1秒后重试
      Future.delayed(const Duration(seconds: 1), () {
        _navigateToHome();
      });
    }
  }

  @override
  void onClose() {
    // 释放动画控制器
    animationController.dispose();
    super.onClose();
  }
}
