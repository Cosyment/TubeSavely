import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class ThemeService extends GetxService {
  final _box = GetStorage();
  final _key = 'isDarkMode';

  /// 获取主题模式
  ThemeMode get theme => _loadThemeFromBox() ? ThemeMode.dark : ThemeMode.light;

  /// 是否是暗黑模式
  bool get isDarkMode => _loadThemeFromBox();

  /// 从本地存储加载主题设置
  bool _loadThemeFromBox() => _box.read(_key) ?? false;

  /// 保存主题设置到本地存储
  _saveThemeToBox(bool isDarkMode) => _box.write(_key, isDarkMode);

  /// 切换主题
  void switchTheme() {
    Get.changeThemeMode(_loadThemeFromBox() ? ThemeMode.light : ThemeMode.dark);
    _saveThemeToBox(!_loadThemeFromBox());
  }

  /// 设置主题
  void setTheme(bool isDarkMode) {
    Get.changeThemeMode(isDarkMode ? ThemeMode.dark : ThemeMode.light);
    _saveThemeToBox(isDarkMode);
  }
}
