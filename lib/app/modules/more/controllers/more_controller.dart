import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart' as url_launcher;

import '../../../data/providers/storage_provider.dart';
import '../../../utils/logger.dart';
import '../../../utils/utils.dart';

class MoreController extends GetxController {
  final StorageProvider _storageProvider = Get.find<StorageProvider>();

  // 应用信息
  final RxString appName = ''.obs;
  final RxString packageName = ''.obs;
  final RxString version = ''.obs;
  final RxString buildNumber = ''.obs;

  // 开发者信息
  final String developerName = 'TubeSavely Team';
  final String developerEmail = 'support@tubesavely.com';
  final String websiteUrl = 'https://tubesavely.cosyment.com';
  final String privacyPolicyUrl = 'https://tubesavely.cosyment.com/privacy';
  final String termsOfServiceUrl = 'https://tubesavely.cosyment.com/terms';

  // 社交媒体链接
  final String githubUrl = 'https://github.com/tubesavely';
  final String twitterUrl = 'https://twitter.com/tubesavely';

  @override
  void onInit() {
    super.onInit();
    _loadAppInfo();
  }

  // 加载应用信息
  Future<void> _loadAppInfo() async {
    try {
      final PackageInfo info = await PackageInfo.fromPlatform();
      appName.value = info.appName;
      packageName.value = info.packageName;
      version.value = info.version;
      buildNumber.value = info.buildNumber;
    } catch (e) {
      Logger.e('Error loading app info: $e');
      appName.value = 'TubeSavely';
      version.value = '1.0.0';
      buildNumber.value = '1';
    }
  }

  // 打开URL
  Future<void> launchUrl(String url) async {
    try {
      final Uri uri = Uri.parse(url);
      if (!await url_launcher.launchUrl(uri, mode: url_launcher.LaunchMode.externalApplication)) {
        Utils.showSnackbar('错误', '无法打开链接: $url', isError: true);
      }
    } catch (e) {
      Logger.e('Error launching URL: $e');
      Utils.showSnackbar('错误', '打开链接时出错: $e', isError: true);
    }
  }

  // 发送邮件
  Future<void> sendEmail() async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: developerEmail,
      queryParameters: {
        'subject': '关于 TubeSavely 的反馈',
        'body':
            '应用版本: ${version.value} (${buildNumber.value})\n设备: ${Platform.operatingSystem} ${Platform.operatingSystemVersion}\n\n'
      },
    );

    try {
      if (!await url_launcher.launchUrl(emailUri)) {
        Utils.showSnackbar('错误', '无法发送邮件', isError: true);
      }
    } catch (e) {
      Logger.e('Error sending email: $e');
      Utils.showSnackbar('错误', '发送邮件时出错: $e', isError: true);
    }
  }

  // 分享应用
  void shareApp() {
    Utils.showSnackbar('提示', '分享功能即将推出');
  }

  // 评分应用
  void rateApp() {
    Utils.showSnackbar('提示', '评分功能即将推出');
  }
}
