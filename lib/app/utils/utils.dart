import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

class Utils {
  Utils._();

  /// 显示Snackbar
  static void showSnackbar(String title, String message,
      {bool isError = false}) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor:
          isError ? Colors.red.withOpacity(0.9) : Colors.green.withOpacity(0.9),
      colorText: Colors.white,
      margin: const EdgeInsets.all(16),
      borderRadius: 8,
      duration: const Duration(seconds: 3),
    );
  }

  /// 显示加载对话框
  static void showLoading({String? message}) {
    Get.dialog(
      Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: Center(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(),
                if (message != null) ...[
                  const SizedBox(height: 16),
                  Text(message),
                ],
              ],
            ),
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }

  /// 隐藏加载对话框
  static void hideLoading() {
    if (Get.isDialogOpen ?? false) {
      Get.back();
    }
  }

  /// 打开URL
  static Future<bool> launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      return await launchUrl(uri);
    } else {
      return false;
    }
  }

  /// 格式化文件大小
  static String formatFileSize(int bytes) {
    if (bytes < 1024) {
      return '$bytes B';
    } else if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(2)} KB';
    } else if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(2)} MB';
    } else {
      return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB';
    }
  }

  /// 格式化时间
  static String formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    if (duration.inHours > 0) {
      return '${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds';
    } else {
      return '$twoDigitMinutes:$twoDigitSeconds';
    }
  }

  /// 检查URL是否有效
  static bool isValidUrl(String url) {
    final RegExp urlRegExp = RegExp(
      r'^(http|https)://',
      caseSensitive: false,
    );
    return urlRegExp.hasMatch(url);
  }

  /// 从URL中提取视频ID
  static String? extractVideoId(String url, String platform) {
    switch (platform.toLowerCase()) {
      case 'youtube':
        // YouTube URL格式: https://www.youtube.com/watch?v=VIDEO_ID 或 https://youtu.be/VIDEO_ID
        final RegExp regExp1 = RegExp(r'youtube\.com/watch\?v=([^&]+)');
        final RegExp regExp2 = RegExp(r'youtu\.be/([^?&]+)');

        final match1 = regExp1.firstMatch(url);
        if (match1 != null && match1.groupCount >= 1) {
          return match1.group(1);
        }

        final match2 = regExp2.firstMatch(url);
        if (match2 != null && match2.groupCount >= 1) {
          return match2.group(1);
        }

        return null;

      case 'bilibili':
        // Bilibili URL格式: https://www.bilibili.com/video/BV1xx411c7mD
        final RegExp regExp = RegExp(r'bilibili\.com/video/([^/?&]+)');
        final match = regExp.firstMatch(url);
        if (match != null && match.groupCount >= 1) {
          return match.group(1);
        }
        return null;

      case 'tiktok':
        // TikTok URL格式: https://www.tiktok.com/@username/video/1234567890123456789
        final RegExp regExp = RegExp(r'tiktok\.com/.*?/video/(\d+)');
        final match = regExp.firstMatch(url);
        if (match != null && match.groupCount >= 1) {
          return match.group(1);
        }
        return null;

      case 'instagram':
        // Instagram URL格式: https://www.instagram.com/p/CODE/ 或 https://www.instagram.com/reel/CODE/
        final RegExp regExp1 = RegExp(r'instagram\.com/p/([^/?&]+)');
        final RegExp regExp2 = RegExp(r'instagram\.com/reel/([^/?&]+)');

        final match1 = regExp1.firstMatch(url);
        if (match1 != null && match1.groupCount >= 1) {
          return match1.group(1);
        }

        final match2 = regExp2.firstMatch(url);
        if (match2 != null && match2.groupCount >= 1) {
          return match2.group(1);
        }

        return null;

      default:
        return null;
    }
  }

  /// 检测URL所属平台
  static String? detectPlatform(String url) {
    if (url.contains('youtube.com') || url.contains('youtu.be')) {
      return 'youtube';
    } else if (url.contains('bilibili.com')) {
      return 'bilibili';
    } else if (url.contains('tiktok.com') || url.contains('douyin.com')) {
      return 'tiktok';
    } else if (url.contains('instagram.com')) {
      return 'instagram';
    } else {
      return null;
    }
  }

  /// 格式化日期时间
  ///
  /// [dateTime] 日期时间
  /// [format] 格式，默认为 'yyyy-MM-dd HH:mm:ss'
  static String formatDateTime(DateTime dateTime,
      {String format = 'yyyy-MM-dd HH:mm:ss'}) {
    return DateFormat(format).format(dateTime);
  }
}
