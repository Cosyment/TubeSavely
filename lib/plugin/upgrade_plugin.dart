import 'dart:async';

import 'package:flutter/services.dart';

import '../widget/appdownload/app_upgrade.dart';

class UpgradePlugin {
  static const MethodChannel _channel = MethodChannel('flutter_app_upgrade');

  ///
  /// 获取app信息
  ///
  static Future<AppInfo> get appInfo async {
    var result = await _channel.invokeMethod('getAppInfo');
    return AppInfo(
        versionName: result['versionName'],
        versionCode: result['versionCode'],
        packageName: result['packageName'],
        channelId: result['channelId']);
  }

  ///
  /// 获取apk下载路径
  ///
  static Future<String> get apkDownloadPath async {
    return await _channel.invokeMethod('getApkDownloadPath');
  }

  ///
  /// Android 安装app
  ///
  static installAppForAndroid(String path) async {
    var map = {'path': path};
    return await _channel.invokeMethod('install', map);
  }

  ///
  /// 跳转到ios app store
  ///
  static toAppStore(String id) async {
    var map = {'id': id};
    return await _channel.invokeMethod('toAppStore', map);
  }
}
