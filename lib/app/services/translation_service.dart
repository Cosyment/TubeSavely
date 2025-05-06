import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class TranslationService extends GetxService {
  final _box = GetStorage();
  final _key = 'locale';

  /// 获取当前语言
  Locale? get locale {
    final String? localeString = _box.read(_key);
    if (localeString == null) return null;
    
    final parts = localeString.split('_');
    if (parts.length == 2) {
      return Locale(parts[0], parts[1]);
    } else {
      return Locale(parts[0]);
    }
  }

  /// 保存语言设置到本地存储
  _saveLocaleToBox(Locale locale) {
    if (locale.countryCode != null) {
      _box.write(_key, '${locale.languageCode}_${locale.countryCode}');
    } else {
      _box.write(_key, locale.languageCode);
    }
  }

  /// 更新语言
  void updateLocale(Locale locale) {
    Get.updateLocale(locale);
    _saveLocaleToBox(locale);
  }

  /// 支持的语言列表
  List<Map<String, dynamic>> get supportedLocales => [
    {'name': '简体中文', 'locale': const Locale('zh', 'CN')},
    {'name': 'English', 'locale': const Locale('en', 'US')},
    {'name': '日本語', 'locale': const Locale('ja', 'JP')},
    {'name': '한국어', 'locale': const Locale('ko', 'KR')},
  ];
}
