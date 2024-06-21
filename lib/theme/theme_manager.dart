import 'package:flutter/material.dart';

class ThemeManager with ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.light;

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
