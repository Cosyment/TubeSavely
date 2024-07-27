import 'package:flutter/cupertino.dart';
import 'package:tubesavely/extension/extension.dart';
import 'package:tubesavely/storage/storage.dart';

class LocaleManager with ChangeNotifier {
  LocaleManager._internal();

  static LocaleManager? _instance;

  static LocaleManager get instance => _instance ??= LocaleManager._internal();

  Locale _locale = Locale((Storage().getString(StorageKeys.LANGUAGE_KEY) ?? 'English').toLanguageCode());

  Locale get locale => _locale;

  set locale(Locale value) {
    _locale = value;
    notifyListeners();
  }

  void changeLocale(String value) {
    locale = Locale(value.toLanguageCode());
  }
}
