import 'dart:io';

// 暂时注释掉，编译时有问题
// import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';

import '../../../data/providers/storage_provider.dart';
import '../../../services/translation_service.dart';
import '../../../services/theme_service.dart';
import '../../../utils/constants.dart';
import '../../../utils/logger.dart';
import '../../../utils/utils.dart';

class SettingsController extends GetxController {
  late final StorageProvider _storageProvider;
  late final ThemeService _themeService;
  late final TranslationService _translationService;

  // 主题模式
  final Rx<bool> isDarkMode = false.obs;

  // 语言
  final RxString currentLanguage = 'zh_CN'.obs;

  // 下载设置
  final RxString downloadPath = ''.obs;
  final RxBool wifiOnly = true.obs;
  final RxBool autoDownload = false.obs;
  final RxBool showNotification = true.obs;

  // 视频质量
  final RxInt defaultVideoQuality = 1080.obs;

  // 视频格式
  final RxString defaultVideoFormat = 'mp4'.obs;

  // 缓存大小
  final RxString cacheSize = '0 MB'.obs;

  @override
  void onInit() {
    super.onInit();
    Logger.d('SettingsController initialized');

    try {
      // 初始化依赖项
      _storageProvider = Get.find<StorageProvider>();
      _themeService = Get.find<ThemeService>();
      _translationService = Get.find<TranslationService>();

      // 加载设置
      loadSettings();

      // 计算缓存大小
      calculateCacheSize();
    } catch (e) {
      Logger.e('SettingsController initialization error: $e');
      Utils.showSnackbar('错误', '初始化设置控制器时出错: $e', isError: true);
    }
  }

  // 加载设置
  void loadSettings() {
    // 主题设置
    isDarkMode.value = _themeService.isDarkMode;

    // 语言设置
    final locale = _translationService.locale;
    if (locale != null) {
      if (locale.countryCode != null) {
        currentLanguage.value = '${locale.languageCode}_${locale.countryCode}';
      } else {
        currentLanguage.value = locale.languageCode;
      }
    }

    // 下载设置
    downloadPath.value = _storageProvider.getSetting('download_path',
        defaultValue: Constants.DEFAULT_DOWNLOAD_PATH);
    wifiOnly.value = _storageProvider.getSetting('wifi_only',
        defaultValue: Constants.DEFAULT_WIFI_ONLY);
    autoDownload.value = _storageProvider.getSetting('auto_download',
        defaultValue: Constants.DEFAULT_AUTO_DOWNLOAD);
    showNotification.value = _storageProvider.getSetting('show_notification',
        defaultValue: Constants.DEFAULT_NOTIFICATION);

    // 视频设置
    defaultVideoQuality.value = _storageProvider.getSetting(
        'default_video_quality',
        defaultValue: Constants.DEFAULT_VIDEO_QUALITY);
    defaultVideoFormat.value = _storageProvider.getSetting(
        'default_video_format',
        defaultValue: Constants.DEFAULT_VIDEO_FORMAT);
  }

  // 切换主题
  void toggleTheme() {
    _themeService.switchTheme();
    isDarkMode.value = _themeService.isDarkMode;
  }

  // 设置语言
  void setLanguage(String languageCode, String? countryCode) {
    if (countryCode != null) {
      _translationService.updateLocale(Locale(languageCode, countryCode));
      currentLanguage.value = '${languageCode}_$countryCode';
    } else {
      _translationService.updateLocale(Locale(languageCode));
      currentLanguage.value = languageCode;
    }
  }

  // 选择下载路径
  Future<void> selectDownloadPath() async {
    try {
      // 注意：由于 FilePicker 已被注释掉，这里暂时使用模拟实现
      // 使用默认下载路径
      final directory = await getApplicationDocumentsDirectory();
      final selectedDirectory = '${directory.path}/downloads';

      // 创建目录
      final dir = Directory(selectedDirectory);
      if (!await dir.exists()) {
        await dir.create(recursive: true);
      }

      downloadPath.value = selectedDirectory;
      await _storageProvider.saveSetting('download_path', selectedDirectory);
      Utils.showSnackbar('成功', '下载路径已更新');
    } catch (e) {
      Logger.e('选择下载路径时出错: $e');
      Utils.showSnackbar('错误', '选择下载路径时出错: $e', isError: true);
    }
  }

  // 设置仅在WiFi下下载
  Future<void> setWifiOnly(bool value) async {
    wifiOnly.value = value;
    await _storageProvider.saveSetting('wifi_only', value);
  }

  // 设置自动下载
  Future<void> setAutoDownload(bool value) async {
    autoDownload.value = value;
    await _storageProvider.saveSetting('auto_download', value);
  }

  // 设置显示通知
  Future<void> setShowNotification(bool value) async {
    showNotification.value = value;
    await _storageProvider.saveSetting('show_notification', value);
  }

  // 设置默认视频质量
  Future<void> setDefaultVideoQuality(int quality) async {
    defaultVideoQuality.value = quality;
    await _storageProvider.saveSetting('default_video_quality', quality);
  }

  // 设置默认视频格式
  Future<void> setDefaultVideoFormat(String format) async {
    defaultVideoFormat.value = format;
    await _storageProvider.saveSetting('default_video_format', format);
  }

  // 计算缓存大小
  Future<void> calculateCacheSize() async {
    try {
      final tempDir = await getTemporaryDirectory();
      final cacheDir = await getApplicationCacheDirectory();

      int tempSize = await _calculateDirSize(tempDir);
      int cacheSize = await _calculateDirSize(cacheDir);

      int totalSize = tempSize + cacheSize;
      this.cacheSize.value = Utils.formatFileSize(totalSize);
    } catch (e) {
      Logger.e('计算缓存大小时出错: $e');
      cacheSize.value = '未知';
    }
  }

  // 计算目录大小
  Future<int> _calculateDirSize(Directory dir) async {
    int size = 0;
    try {
      final List<FileSystemEntity> entities = dir.listSync(recursive: true);
      for (var entity in entities) {
        if (entity is File) {
          size += await entity.length();
        }
      }
    } catch (e) {
      Logger.e('计算目录大小时出错: $e');
    }
    return size;
  }

  // 清除缓存
  Future<void> clearCache() async {
    try {
      final tempDir = await getTemporaryDirectory();
      final cacheDir = await getApplicationCacheDirectory();

      await _deleteDirectoryContents(tempDir);
      await _deleteDirectoryContents(cacheDir);

      await calculateCacheSize();
      Utils.showSnackbar('成功', '缓存已清除');
    } catch (e) {
      Logger.e('清除缓存时出错: $e');
      Utils.showSnackbar('错误', '清除缓存时出错: $e', isError: true);
    }
  }

  // 删除目录内容
  Future<void> _deleteDirectoryContents(Directory directory) async {
    try {
      final List<FileSystemEntity> entities = directory.listSync();
      for (var entity in entities) {
        if (entity is Directory) {
          await _deleteDirectoryContents(entity);
          await entity.delete();
        } else if (entity is File) {
          await entity.delete();
        }
      }
    } catch (e) {
      Logger.e('删除目录内容时出错: $e');
    }
  }

  // 关于应用
  void showAboutApp() {
    Get.dialog(
      AlertDialog(
        title: Text('关于 TubeSavely'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('版本: 1.0.0'),
            SizedBox(height: 8),
            Text('一个跨平台的视频下载工具'),
            SizedBox(height: 16),
            Text('© 2024 TubeSavely Team'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('关闭'),
          ),
        ],
      ),
    );
  }

  // 隐私政策
  void showPrivacyPolicy() {
    Utils.launchURL('https://tubesavely.cosyment.com/privacy');
  }

  // 用户协议
  void showTermsOfService() {
    Utils.launchURL('https://tubesavely.cosyment.com/terms');
  }
}
