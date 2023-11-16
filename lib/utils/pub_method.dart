import 'package:flutter/material.dart';
import 'package:in_app_review/in_app_review.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:umeng_common_sdk/umeng_common_sdk.dart';

import '../constants/constant.dart';
import '../data/update_model.dart';
import '../network/http_api.dart';
import '../network/http_utils.dart';
import '../plugin/method_plugin.dart';
import '../plugin/upgrade_plugin.dart';
import '../widget/appdownload/app_upgrade.dart';
import 'platform_utils.dart';

class PubMethodUtils {
  static void umengCommonSdkInit() {
    if (PlatformUtils.isAndroid) {
      MethodPlugin.isAgree();
      MethodPlugin.getAppChannelId().then((value) {
        Constant.appChannelId = value;
        UmengCommonSdk.initCommon(
            '652e62c3b2f6fa00ba65ae50', '652e62ddb2f6fa00ba65ae51', value);
      });
    } else if (PlatformUtils.isIOS) {
      Constant.appChannelId = "ios";
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

  static Future<AppUpgradeInfo> checkAppInfo(UpdataModel data) async {
    return Future.delayed(const Duration(seconds: 1), () {
      return AppUpgradeInfo(
          title: data.appVersion,
          contents: [data.description!],
          status: data.status,
          apkDownloadUrl: data.url);
    });
  }

  ///版本更新
  static getUpdateApp(context) async {
    var updataModel = await HttpUtils.instance
        .requestNetWorkAy<UpdataModel>(Method.get, HttpApi.updateApp);
    var appInfo = await UpgradePlugin.appInfo;

    if (updataModel == null) return;
    if (int.parse(appInfo.versionCode!) < updataModel.appCode!) {
      if (updataModel.status == 4) {
        ///代表不更新
        return;
      } else if (updataModel.status == 3) {
        var updateAppStatus =
            PubMethodUtils.getSharedPreferences("updateAppStatus");
        if (updateAppStatus != null) {
          return;
        }
      }
      AppUpgrade.appUpgrade(context, PubMethodUtils.checkAppInfo(updataModel),
          iosAppId: "1596691834",
          okBackgroundColors: [Theme.of(context).primaryColor.withOpacity(0.4)],
          progressBarColor: Theme.of(context).primaryColor.withOpacity(0.4));
    }
  }
}
