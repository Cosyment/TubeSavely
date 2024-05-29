import 'package:shared_preferences/shared_preferences.dart';

class LocalStorageService {
  static final LocalStorageService _instance = LocalStorageService._internal();

  factory LocalStorageService() => _instance;

  LocalStorageService._internal();

  late SharedPreferences _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  static const prefAppLaunchTime = 'pref_app_launch_time';
  static const prefLanguageCode = 'pref_language_code';
  static const prefPad = 'pref_pad';
  static const preShownAppReview = 'pref_shown_app_review';
  static const prefMembershipProductId = 'pref_membership_productId';

  remove(String key) {
    _prefs.remove(key);
  }

  String? get appLaunchTime => _prefs.getString(prefAppLaunchTime);

  set updateAppLaunchTime(DateTime time) {
    _prefs.setString(prefAppLaunchTime, time.toString());
  }

  set languageCode(String value) => _prefs.setString(prefLanguageCode, value);

  String? get currentLanguageCode => _prefs.getString(prefLanguageCode);

  set isPad(bool value) => _prefs.setBool(prefPad, value);

  bool get isPad => _prefs.getBool(prefPad) ?? false;

  set shownAppReview(bool value) => _prefs.setBool(preShownAppReview, value);

  bool getShownAppReviewFlag() => _prefs.getBool(preShownAppReview) ?? false;

  set currentMembershipProductId(String productId) => _prefs.setString(prefMembershipProductId, productId);

  String getCurrentMembershipProductId() => _prefs.getString(prefMembershipProductId) ?? '';

  bool isMembershipUser() => getCurrentMembershipProductId().isNotEmpty;
}
