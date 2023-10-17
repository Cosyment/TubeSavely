import 'package:in_app_review/in_app_review.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:umeng_common_sdk/umeng_common_sdk.dart';

import '../plugin/method_plugin.dart';
import 'platform_utils.dart';

class PubMethodUtils {
  static void umengCommonSdkInit() {
    if (PlatformUtils.isAndroid) {
      MethodPlugin.getAppChannelId().then((value) {
        UmengCommonSdk.initCommon(
            '652e62c3b2f6fa00ba65ae50', '652e62ddb2f6fa00ba65ae51', value);
      });
    } else if (PlatformUtils.isIOS) {
      UmengCommonSdk.initCommon(
          '652e62c3b2f6fa00ba65ae50', '652e62ddb2f6fa00ba65ae51', "ios");
    }
  }

  static void getInAppReview() async {
    final InAppReview inAppReview = InAppReview.instance;
    if (await inAppReview.isAvailable()) {
      inAppReview.requestReview();
    }
  }

  static void putSharedPreferences(key, value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString(key, value);
  }

  static Future<String?> getSharedPreferences(key) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(key);
  }
}
