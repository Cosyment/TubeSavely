import 'package:flutter/material.dart';
import 'package:tubesavely/storage/storage.dart';

class ThemeManager with ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.values.byName(Storage().getString(StorageKeys.THEME_MODE_KEY) ?? ThemeMode.system.name);

  ThemeMode get currentTheme {
    return _themeMode;
  }

  set currentTheme(ThemeMode themeMode) {
    _themeMode = themeMode;
    notifyListeners();
  }

  void toggleTheme() {
    currentTheme = ThemeMode.light == _themeMode ? ThemeMode.light : ThemeMode.dark;
  }
}
