import 'package:shared_preferences/shared_preferences.dart';

class StorageKeys {
  static const String isFirstRun = 'isFirstRun';
  static const String THEME_MODE_KEY = 'THEME_MODE_KEY';
  static const String CACHE_DIR_KEY = 'CACHE_DIR_KEY';
  static const String LANGUAGE_KEY = 'LANGUAGE_KEY';
  static const String RETRY_COUNT_KEY = 'RETRY_COUNT_KEY';
  static const String DOWNLOAD_QUALITY_KEY = 'DOWNLOAD_QUALITY_KEY';
  static const String AUTO_MERGE_AUDIO_KEY = 'AUTO_MERGE_AUDIO_KEY';
  static const String AUTO_RECODE_KEY = 'AUTO_RECODE_KEY';
  static const String CONVERT_FORMAT_KEY = 'CONVERT_FORMAT_KEY';
}

class Storage {
  Storage._internal();

  static final Storage _instance = Storage._internal();

  static late SharedPreferences _prefs; // 使用late关键字，但确保在使用前初始化

  // 工厂构造器，确保_prefs在首次实例化时被初始化
  factory Storage() {
    _instance.init();
    return _instance;
  }

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  Future<void> set(String key, dynamic value) async {
    if (value is String) {
      await _prefs.setString(key, value);
    } else if (value is int) {
      await _prefs.setInt(key, value);
    } else if (value is double) {
      await _prefs.setDouble(key, value);
    } else if (value is bool) {
      await _prefs.setBool(key, value);
    } else if (value is List<String>) {
      await _prefs.setStringList(key, value);
    }
  }

  String? getString(String key) {
    return _prefs.getString(key);
  }

  bool getBool(String key) {
    return _prefs.getBool(key) ?? false;
  }

  int? getInt(String key) {
    return _prefs.getInt(key);
  }

  Future<void> delete(String key) async {}
}
