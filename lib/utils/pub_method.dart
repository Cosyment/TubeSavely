import 'package:in_app_review/in_app_review.dart';

class PubMethodUtils {


  // static void umengCommonSdkInit() {
  //   if (PlatformUtils.isAndroid) {
  //     MethodPlugin.getAppChannelId().then((value) {
  //       UmengCommonSdk.initCommon(
  //           '63b91145ba6a5259c4e3e8b6', '63b912d9ba6a5259c4e3e8f1', value);
  //     });
  //   } else if (PlatformUtils.isIOS) {
  //     UmengCommonSdk.initCommon(
  //         '63b91145ba6a5259c4e3e8b6', '63b912d9ba6a5259c4e3e8f1', "ios");
  //   }
  // }

  static void getInAppReview() async {
    final InAppReview inAppReview = InAppReview.instance;
    if (await inAppReview.isAvailable()) {
      inAppReview.requestReview();
    }
  }
}