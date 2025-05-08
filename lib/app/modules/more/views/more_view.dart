import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../controllers/more_controller.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_text_styles.dart';

class MoreView extends GetView<MoreController> {
  const MoreView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('更多', style: AppTextStyles.titleLarge),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildAppInfo(),
              SizedBox(height: 24.h),
              _buildSectionTitle('应用'),
              _buildAppSection(),
              SizedBox(height: 24.h),
              _buildSectionTitle('关于'),
              _buildAboutSection(),
              SizedBox(height: 24.h),
              _buildSectionTitle('联系我们'),
              _buildContactSection(),
              SizedBox(height: 24.h),
              _buildSectionTitle('法律'),
              _buildLegalSection(),
              SizedBox(height: 32.h),
              _buildVersionInfo(),
            ],
          ),
        ),
      ),
    );
  }

  // 应用信息
  Widget _buildAppInfo() {
    return Center(
      child: Column(
        children: [
          Container(
            width: 100.w,
            height: 100.w,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20.r),
            ),
            child: Icon(
              Icons.download_rounded,
              size: 60.sp,
              color: AppColors.primary,
            ),
          ),
          SizedBox(height: 16.h),
          Obx(() => Text(
                controller.appName.value,
                style: AppTextStyles.titleLarge,
              )),
          SizedBox(height: 8.h),
          Obx(() => Text(
                '版本 ${controller.version.value} (${controller.buildNumber.value})',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              )),
        ],
      ),
    );
  }

  // 版本信息
  Widget _buildVersionInfo() {
    return Center(
      child: Column(
        children: [
          Text(
            '© 2024 TubeSavely Team',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'Made with ❤️ in China',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  // 分区标题
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Text(
        title,
        style: AppTextStyles.titleMedium.copyWith(
          color: AppColors.primary,
        ),
      ),
    );
  }

  // 应用分区
  Widget _buildAppSection() {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.r),
        side: BorderSide(color: AppColors.border),
      ),
      child: Column(
        children: [
          _buildListTile(
            icon: Icons.star_outline,
            title: '评分应用',
            onTap: controller.rateApp,
          ),
          _buildDivider(),
          _buildListTile(
            icon: Icons.share_outlined,
            title: '分享应用',
            onTap: controller.shareApp,
          ),
          _buildDivider(),
          _buildListTile(
            icon: Icons.language_outlined,
            title: '访问网站',
            onTap: () => controller.launchUrl(controller.websiteUrl),
          ),
        ],
      ),
    );
  }

  // 关于分区
  Widget _buildAboutSection() {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.r),
        side: BorderSide(color: AppColors.border),
      ),
      child: Column(
        children: [
          _buildListTile(
            icon: Icons.info_outline,
            title: '关于 TubeSavely',
            onTap: () => _showAboutDialog(),
          ),
          _buildDivider(),
          _buildListTile(
            icon: Icons.update,
            title: '检查更新',
            onTap: () => Utils.showSnackbar('提示', '当前已是最新版本'),
          ),
          _buildDivider(),
          _buildListTile(
            icon: Icons.history,
            title: '更新日志',
            onTap: () => _showChangelogDialog(),
          ),
        ],
      ),
    );
  }

  // 联系我们分区
  Widget _buildContactSection() {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.r),
        side: BorderSide(color: AppColors.border),
      ),
      child: Column(
        children: [
          _buildListTile(
            icon: Icons.email_outlined,
            title: '发送邮件',
            subtitle: controller.developerEmail,
            onTap: controller.sendEmail,
          ),
          _buildDivider(),
          _buildListTile(
            icon: Icons.code,
            title: 'GitHub',
            onTap: () => controller.launchUrl(controller.githubUrl),
          ),
          _buildDivider(),
          _buildListTile(
            icon: Icons.chat_bubble_outline,
            title: 'Twitter',
            onTap: () => controller.launchUrl(controller.twitterUrl),
          ),
        ],
      ),
    );
  }

  // 法律分区
  Widget _buildLegalSection() {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.r),
        side: BorderSide(color: AppColors.border),
      ),
      child: Column(
        children: [
          _buildListTile(
            icon: Icons.privacy_tip_outlined,
            title: '隐私政策',
            onTap: () => controller.launchUrl(controller.privacyPolicyUrl),
          ),
          _buildDivider(),
          _buildListTile(
            icon: Icons.gavel_outlined,
            title: '服务条款',
            onTap: () => controller.launchUrl(controller.termsOfServiceUrl),
          ),
          _buildDivider(),
          _buildListTile(
            icon: Icons.verified_user_outlined,
            title: '开源许可',
            onTap: () => _showLicensesDialog(),
          ),
        ],
      ),
    );
  }

  // 列表项
  Widget _buildListTile({
    required IconData icon,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primary),
      title: Text(title, style: AppTextStyles.bodyMedium),
      subtitle: subtitle != null
          ? Text(
              subtitle,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            )
          : null,
      trailing: Icon(
        Icons.arrow_forward_ios,
        size: 16.sp,
        color: AppColors.textSecondary,
      ),
      onTap: onTap,
    );
  }

  // 分隔线
  Widget _buildDivider() {
    return Divider(
      height: 1,
      thickness: 1,
      color: AppColors.border,
      indent: 16.w,
      endIndent: 16.w,
    );
  }

  // 关于对话框
  void _showAboutDialog() {
    Get.dialog(
      AlertDialog(
        title: Text('关于 TubeSavely', style: AppTextStyles.titleMedium),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'TubeSavely 是一款功能强大的视频下载工具，支持多种视频平台，提供高质量的视频下载、格式转换和播放功能。',
                style: AppTextStyles.bodyMedium,
              ),
              SizedBox(height: 16.h),
              Text(
                '主要功能：',
                style: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8.h),
              _buildFeatureItem('支持多平台视频下载'),
              _buildFeatureItem('视频格式转换'),
              _buildFeatureItem('后台下载支持'),
              _buildFeatureItem('高清视频播放'),
              _buildFeatureItem('历史记录管理'),
              SizedBox(height: 16.h),
              Text(
                '开发团队：${controller.developerName}',
                style: AppTextStyles.bodyMedium,
              ),
            ],
          ),
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

  // 功能项
  Widget _buildFeatureItem(String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: 4.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('• ', style: AppTextStyles.bodyMedium),
          Expanded(
            child: Text(text, style: AppTextStyles.bodyMedium),
          ),
        ],
      ),
    );
  }

  // 更新日志对话框
  void _showChangelogDialog() {
    Get.dialog(
      AlertDialog(
        title: Text('更新日志', style: AppTextStyles.titleMedium),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildVersionChangeLog(
                version: '1.0.0',
                date: '2024-05-01',
                changes: [
                  '初始版本发布',
                  '支持多平台视频下载',
                  '视频格式转换功能',
                  '后台下载支持',
                  '高清视频播放器',
                ],
              ),
              SizedBox(height: 16.h),
              _buildVersionChangeLog(
                version: '0.9.0',
                date: '2024-04-15',
                changes: [
                  'Beta 版本发布',
                  '核心功能测试',
                  'UI 优化',
                  '性能改进',
                ],
              ),
            ],
          ),
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

  // 版本更新日志
  Widget _buildVersionChangeLog({
    required String version,
    required String date,
    required List<String> changes,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'v$version - $date',
          style: AppTextStyles.bodyMedium.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 8.h),
        ...changes.map((change) => _buildFeatureItem(change)).toList(),
      ],
    );
  }

  // 许可证对话框
  void _showLicensesDialog() {
    Get.to(() => LicensePage(
          applicationName: 'TubeSavely',
          applicationVersion: controller.version.value,
          applicationIcon: Padding(
            padding: EdgeInsets.all(16.w),
            child: Container(
              width: 60.w,
              height: 60.w,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Icon(
                Icons.download_rounded,
                size: 36.sp,
                color: AppColors.primary,
              ),
            ),
          ),
        ));
  }
}
