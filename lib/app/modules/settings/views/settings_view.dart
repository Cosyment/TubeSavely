import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../routes/app_pages.dart';
import '../controllers/settings_controller.dart';
import '../../../theme/app_theme.dart';

class SettingsView extends GetView<SettingsController> {
  const SettingsView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '设置',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle('外观设置'),
              SizedBox(height: 8.h),
              _buildThemeSettings(),
              SizedBox(height: 8.h),
              _buildLanguageSettings(),
              SizedBox(height: 16.h),
              _buildSectionTitle('下载设置'),
              SizedBox(height: 8.h),
              _buildDownloadPathSettings(),
              SizedBox(height: 8.h),
              _buildWifiOnlySettings(),
              SizedBox(height: 8.h),
              _buildAutoDownloadSettings(),
              SizedBox(height: 8.h),
              _buildNotificationSettings(),
              SizedBox(height: 16.h),
              _buildSectionTitle('视频设置'),
              SizedBox(height: 8.h),
              _buildVideoQualitySettings(),
              SizedBox(height: 8.h),
              _buildVideoFormatSettings(),
              SizedBox(height: 8.h),
              _buildVideoConvertSettings(),
              SizedBox(height: 16.h),
              _buildSectionTitle('存储'),
              SizedBox(height: 8.h),
              _buildCacheSettings(),
              SizedBox(height: 16.h),
              _buildSectionTitle('关于'),
              SizedBox(height: 8.h),
              _buildAboutSettings(),
              SizedBox(height: 32.h),
            ],
          ),
        ),
      ),
    );
  }

  // 构建分区标题
  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 16.sp,
        fontWeight: FontWeight.bold,
        foreground: Paint()
          ..shader = LinearGradient(
            colors: [
              AppTheme.primaryColor,
              AppTheme.accentColor,
            ],
          ).createShader(Rect.fromLTWH(0, 0, 100.w, 24.h)),
      ),
    );
  }

  // 构建设置项
  Widget _buildSettingItem({
    required String title,
    required Widget trailing,
    String? subtitle,
    VoidCallback? onTap,
    Widget? leading,
  }) {
    return Card(
      elevation: 0,
      margin: EdgeInsets.only(bottom: 8.h),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.r),
        side: BorderSide(
          color: Get.theme.colorScheme.onSurface.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
        leading: leading,
        title: Text(
          title,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: subtitle != null
            ? Text(
                subtitle,
                style: TextStyle(
                  fontSize: 12.sp,
                  color: Get.theme.colorScheme.onSurface.withOpacity(0.6),
                ),
              )
            : null,
        trailing: trailing,
        onTap: onTap,
      ),
    );
  }

  // 主题设置
  Widget _buildThemeSettings() {
    return Obx(() {
      return _buildSettingItem(
        title: '深色模式',
        subtitle: '切换应用的主题',
        leading: Icon(
          controller.isDarkMode.value ? Icons.dark_mode : Icons.light_mode,
          color: controller.isDarkMode.value
              ? AppTheme.accentColor
              : AppTheme.primaryColor,
        ),
        trailing: Switch(
          value: controller.isDarkMode.value,
          onChanged: (value) => controller.toggleTheme(),
          activeColor: AppTheme.primaryColor,
        ),
        onTap: () => controller.toggleTheme(),
      );
    });
  }

  // 语言设置
  Widget _buildLanguageSettings() {
    return Obx(() {
      String languageName = '简体中文';
      switch (controller.currentLanguage.value) {
        case 'zh_CN':
          languageName = '简体中文';
          break;
        case 'en_US':
          languageName = 'English';
          break;
        case 'ja_JP':
          languageName = '日本語';
          break;
        case 'ko_KR':
          languageName = '한국어';
          break;
      }

      return _buildSettingItem(
        title: '语言',
        subtitle: languageName,
        leading: Icon(
          Icons.language,
          color: AppTheme.primaryColor,
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          size: 16.sp,
          color: Get.theme.colorScheme.onSurface.withOpacity(0.6),
        ),
        onTap: () => _showLanguageSelector(),
      );
    });
  }

  // 显示语言选择器
  void _showLanguageSelector() {
    Get.bottomSheet(
      Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: Get.theme.colorScheme.surface,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(16.r),
            topRight: Radius.circular(16.r),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '选择语言',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16.h),
            _buildLanguageOption('简体中文', 'zh', 'CN'),
            _buildLanguageOption('English', 'en', 'US'),
            _buildLanguageOption('日本語', 'ja', 'JP'),
            _buildLanguageOption('한국어', 'ko', 'KR'),
            SizedBox(height: 16.h),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Get.back(),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 12.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  backgroundColor: AppTheme.primaryColor,
                ),
                child: Text(
                  '关闭',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 构建语言选项
  Widget _buildLanguageOption(
      String name, String languageCode, String countryCode) {
    return Obx(() {
      final isSelected =
          controller.currentLanguage.value == '${languageCode}_$countryCode';

      return ListTile(
        title: Text(
          name,
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            color: isSelected
                ? AppTheme.primaryColor
                : Get.theme.colorScheme.onSurface,
          ),
        ),
        trailing: isSelected
            ? Icon(
                Icons.check_circle,
                color: AppTheme.primaryColor,
              )
            : null,
        onTap: () {
          controller.setLanguage(languageCode, countryCode);
          Get.back();
        },
      );
    });
  }

  // 下载路径设置
  Widget _buildDownloadPathSettings() {
    return Obx(() {
      return _buildSettingItem(
        title: '下载路径',
        subtitle: controller.downloadPath.value.isEmpty
            ? '默认路径'
            : controller.downloadPath.value,
        leading: Icon(
          Icons.folder,
          color: AppTheme.primaryColor,
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          size: 16.sp,
          color: Get.theme.colorScheme.onSurface.withOpacity(0.6),
        ),
        onTap: () => controller.selectDownloadPath(),
      );
    });
  }

  // 仅WiFi下载设置
  Widget _buildWifiOnlySettings() {
    return Obx(() {
      return _buildSettingItem(
        title: '仅在WiFi下下载',
        subtitle: '开启后仅在WiFi环境下下载视频',
        leading: Icon(
          Icons.wifi,
          color: AppTheme.primaryColor,
        ),
        trailing: Switch(
          value: controller.wifiOnly.value,
          onChanged: (value) => controller.setWifiOnly(value),
          activeColor: AppTheme.primaryColor,
        ),
        onTap: () => controller.setWifiOnly(!controller.wifiOnly.value),
      );
    });
  }

  // 自动下载设置
  Widget _buildAutoDownloadSettings() {
    return Obx(() {
      return _buildSettingItem(
        title: '自动下载',
        subtitle: '解析视频后自动开始下载',
        leading: Icon(
          Icons.download,
          color: AppTheme.primaryColor,
        ),
        trailing: Switch(
          value: controller.autoDownload.value,
          onChanged: (value) => controller.setAutoDownload(value),
          activeColor: AppTheme.primaryColor,
        ),
        onTap: () => controller.setAutoDownload(!controller.autoDownload.value),
      );
    });
  }

  // 通知设置
  Widget _buildNotificationSettings() {
    return Obx(() {
      return _buildSettingItem(
        title: '下载通知',
        subtitle: '显示下载进度通知',
        leading: Icon(
          Icons.notifications,
          color: AppTheme.primaryColor,
        ),
        trailing: Switch(
          value: controller.showNotification.value,
          onChanged: (value) => controller.setShowNotification(value),
          activeColor: AppTheme.primaryColor,
        ),
        onTap: () =>
            controller.setShowNotification(!controller.showNotification.value),
      );
    });
  }

  // 视频质量设置
  Widget _buildVideoQualitySettings() {
    return Obx(() {
      return _buildSettingItem(
        title: '默认视频质量',
        subtitle: '${controller.defaultVideoQuality.value}P',
        leading: Icon(
          Icons.high_quality,
          color: AppTheme.primaryColor,
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          size: 16.sp,
          color: Get.theme.colorScheme.onSurface.withOpacity(0.6),
        ),
        onTap: () => _showQualitySelector(),
      );
    });
  }

  // 显示质量选择器
  void _showQualitySelector() {
    Get.bottomSheet(
      Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: Get.theme.colorScheme.surface,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(16.r),
            topRight: Radius.circular(16.r),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '选择默认视频质量',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16.h),
            _buildQualityOption(1080),
            _buildQualityOption(720),
            _buildQualityOption(480),
            _buildQualityOption(360),
            SizedBox(height: 16.h),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Get.back(),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 12.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  backgroundColor: AppTheme.primaryColor,
                ),
                child: Text(
                  '关闭',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 构建质量选项
  Widget _buildQualityOption(int quality) {
    return Obx(() {
      final isSelected = controller.defaultVideoQuality.value == quality;

      return ListTile(
        title: Text(
          '${quality}P',
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            color: isSelected
                ? AppTheme.primaryColor
                : Get.theme.colorScheme.onSurface,
          ),
        ),
        trailing: isSelected
            ? Icon(
                Icons.check_circle,
                color: AppTheme.primaryColor,
              )
            : null,
        onTap: () {
          controller.setDefaultVideoQuality(quality);
          Get.back();
        },
      );
    });
  }

  // 视频格式设置
  Widget _buildVideoFormatSettings() {
    return Obx(() {
      return _buildSettingItem(
        title: '默认视频格式',
        subtitle: controller.defaultVideoFormat.value.toUpperCase(),
        leading: Icon(
          Icons.video_file,
          color: AppTheme.primaryColor,
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          size: 16.sp,
          color: Get.theme.colorScheme.onSurface.withOpacity(0.6),
        ),
        onTap: () => _showFormatSelector(),
      );
    });
  }

  // 显示格式选择器
  void _showFormatSelector() {
    Get.bottomSheet(
      Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: Get.theme.colorScheme.surface,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(16.r),
            topRight: Radius.circular(16.r),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '选择默认视频格式',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16.h),
            _buildFormatOption('mp4'),
            _buildFormatOption('mkv'),
            _buildFormatOption('mp3'),
            SizedBox(height: 16.h),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Get.back(),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 12.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  backgroundColor: AppTheme.primaryColor,
                ),
                child: Text(
                  '关闭',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 视频转换设置
  Widget _buildVideoConvertSettings() {
    return _buildSettingItem(
      title: '视频格式转换',
      subtitle: '转换视频格式、分辨率等',
      leading: Icon(
        Icons.transform,
        color: Colors.deepPurple,
      ),
      trailing: Icon(
        Icons.arrow_forward_ios,
        size: 16.sp,
        color: Get.theme.colorScheme.onSurface.withOpacity(0.6),
      ),
      onTap: () => Get.toNamed(Routes.CONVERT),
    );
  }

  // 构建格式选项
  Widget _buildFormatOption(String format) {
    return Obx(() {
      final isSelected = controller.defaultVideoFormat.value == format;

      return ListTile(
        title: Text(
          format.toUpperCase(),
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            color: isSelected
                ? AppTheme.primaryColor
                : Get.theme.colorScheme.onSurface,
          ),
        ),
        trailing: isSelected
            ? Icon(
                Icons.check_circle,
                color: AppTheme.primaryColor,
              )
            : null,
        onTap: () {
          controller.setDefaultVideoFormat(format);
          Get.back();
        },
      );
    });
  }

  // 缓存设置
  Widget _buildCacheSettings() {
    return Obx(() {
      return _buildSettingItem(
        title: '清除缓存',
        subtitle: '当前缓存大小: ${controller.cacheSize.value}',
        leading: Icon(
          Icons.cleaning_services,
          color: AppTheme.primaryColor,
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          size: 16.sp,
          color: Get.theme.colorScheme.onSurface.withOpacity(0.6),
        ),
        onTap: () => _showClearCacheConfirmation(),
      );
    });
  }

  // 显示清除缓存确认对话框
  void _showClearCacheConfirmation() {
    Get.dialog(
      AlertDialog(
        title: Text('清除缓存'),
        content: Text('确定要清除所有缓存吗？'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('取消'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              controller.clearCache();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
            ),
            child: Text('确定'),
          ),
        ],
      ),
    );
  }

  // 关于设置
  Widget _buildAboutSettings() {
    return Column(
      children: [
        _buildSettingItem(
          title: '关于 TubeSavely',
          leading: Icon(
            Icons.info,
            color: AppTheme.primaryColor,
          ),
          trailing: Icon(
            Icons.arrow_forward_ios,
            size: 16.sp,
            color: Get.theme.colorScheme.onSurface.withOpacity(0.6),
          ),
          onTap: () => controller.showAboutApp(),
        ),
        _buildSettingItem(
          title: '隐私政策',
          leading: Icon(
            Icons.privacy_tip,
            color: AppTheme.primaryColor,
          ),
          trailing: Icon(
            Icons.arrow_forward_ios,
            size: 16.sp,
            color: Get.theme.colorScheme.onSurface.withOpacity(0.6),
          ),
          onTap: () => controller.showPrivacyPolicy(),
        ),
        _buildSettingItem(
          title: '用户协议',
          leading: Icon(
            Icons.description,
            color: AppTheme.primaryColor,
          ),
          trailing: Icon(
            Icons.arrow_forward_ios,
            size: 16.sp,
            color: Get.theme.colorScheme.onSurface.withOpacity(0.6),
          ),
          onTap: () => controller.showTermsOfService(),
        ),
      ],
    );
  }
}
