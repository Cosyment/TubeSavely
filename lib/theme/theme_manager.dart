import 'package:flutter/material.dart';
import 'package:tubesavely/storage/storage.dart';

class ThemeManager with ChangeNotifier {
  ThemeManager._internal();

  static ThemeManager? _instance;

  static ThemeManager get instance => _instance ??= ThemeManager._internal();

  ThemeMode _themeMode = ThemeMode.values.byName(Storage().getString(StorageKeys.THEME_MODE_KEY) ?? ThemeMode.system.name);

  ThemeMode get currentTheme => _themeMode;

  set currentTheme(ThemeMode themeMode) {
    _themeMode = themeMode;
    notifyListeners();
  }

  void toggleTheme() {
    currentTheme = ThemeMode.light == _themeMode ? ThemeMode.dark : ThemeMode.light;
  }
}
