import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../data/providers/storage_provider.dart';
import '../utils/constants.dart';
import '../utils/logger.dart';

/// 主题服务
///
/// 负责管理应用主题
class ThemeService extends GetxService {
  final StorageProvider _storageProvider = Get.find<StorageProvider>();
  
  // 当前主题模式
  final Rx<ThemeMode> themeMode = ThemeMode.system.obs;
  
  /// 初始化服务
  Future<ThemeService> init() async {
    Logger.d('ThemeService initialized');
    
    // 从存储中获取主题模式
    final savedThemeMode = _storageProvider.getThemeMode();
    if (savedThemeMode != null) {
      themeMode.value = savedThemeMode;
    }
    
    return this;
  }
  
  /// 切换主题模式
  Future<void> switchTheme() async {
    if (themeMode.value == ThemeMode.light) {
      await setThemeMode(ThemeMode.dark);
    } else {
      await setThemeMode(ThemeMode.light);
    }
  }
  
  /// 设置主题模式
  Future<void> setThemeMode(ThemeMode mode) async {
    themeMode.value = mode;
    Get.changeThemeMode(mode);
    await _storageProvider.saveThemeMode(mode);
  }
  
  /// 是否是暗色主题
  bool get isDarkMode {
    if (themeMode.value == ThemeMode.system) {
      return Get.isPlatformDarkMode;
    }
    return themeMode.value == ThemeMode.dark;
  }
}
