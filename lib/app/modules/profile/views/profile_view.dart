import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_text_styles.dart';
import '../../../utils/utils.dart';
import '../controllers/profile_controller.dart';

/// 用户信息页面
class ProfileView extends GetView<ProfileController> {
  const ProfileView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '个人中心',
          style: AppTextStyles.titleLarge,
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Theme.of(context).primaryColor,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: controller.goToSettings,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: controller.refreshUserInfo,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              _buildUserHeader(),
              SizedBox(height: 16.h),
              _buildAccountInfo(),
              SizedBox(height: 16.h),
              _buildFunctionList(),
              SizedBox(height: 16.h),
              _buildAboutSection(),
              SizedBox(height: 16.h),
              _buildLogoutButton(),
              SizedBox(height: 32.h),
              _buildVersionInfo(),
            ],
          ),
        ),
      ),
    );
  }

  /// 构建用户头部信息
  Widget _buildUserHeader() {
    return Obx(() {
      return Container(
        padding: EdgeInsets.symmetric(vertical: 24.h),
        decoration: BoxDecoration(
          color: AppColors.primary,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(26),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: controller.isLoggedIn.value
            ? _buildLoggedInHeader()
            : _buildNotLoggedInHeader(),
      );
    });
  }

  /// 构建已登录的头部
  Widget _buildLoggedInHeader() {
    return Obx(() {
      final user = controller.user.value;

      return Column(
        children: [
          // 头像
          Container(
            width: 80.w,
            height: 80.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              border: Border.all(
                color: Colors.white,
                width: 2.w,
              ),
              image: user?.avatar != null
                  ? DecorationImage(
                      image: NetworkImage(user!.avatar!),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            child: user?.avatar == null
                ? Icon(
                    Icons.person,
                    size: 40.sp,
                    color: AppColors.primary,
                  )
                : null,
          ),
          SizedBox(height: 16.h),
          // 用户名
          Text(
            user?.name ?? '未知用户',
            style: AppTextStyles.titleLarge.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8.h),
          // 会员状态
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: 12.w,
              vertical: 4.h,
            ),
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(51),
              borderRadius: BorderRadius.circular(16.r),
            ),
            child: Text(
              controller.getMembershipStatus(),
              style: AppTextStyles.bodySmall.copyWith(
                color: Colors.white,
              ),
            ),
          ),
        ],
      );
    });
  }

  /// 构建未登录的头部
  Widget _buildNotLoggedInHeader() {
    return Column(
      children: [
        // 头像
        Container(
          width: 80.w,
          height: 80.w,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white,
            border: Border.all(
              color: Colors.white,
              width: 2.w,
            ),
          ),
          child: Icon(
            Icons.person,
            size: 40.sp,
            color: AppColors.primary,
          ),
        ),
        SizedBox(height: 16.h),
        // 登录按钮
        ElevatedButton(
          onPressed: controller.login,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: AppColors.primary,
            padding: EdgeInsets.symmetric(
              horizontal: 24.w,
              vertical: 8.h,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.r),
            ),
          ),
          child: Text(
            '点击登录',
            style: AppTextStyles.bodyMedium.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  /// 构建账户信息
  Widget _buildAccountInfo() {
    return Obx(() {
      if (!controller.isLoggedIn.value) {
        return const SizedBox.shrink();
      }

      final user = controller.user.value;
      if (user == null) return const SizedBox.shrink();

      return Container(
        margin: EdgeInsets.symmetric(horizontal: 16.w),
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: Get.theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(12.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(13),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '账户信息',
              style: AppTextStyles.titleMedium.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16.h),
            _buildInfoItem('会员等级', controller.getMembershipStatus()),
            _buildInfoItem('会员到期', controller.getMembershipExpiry()),
            _buildInfoItem('积分余额', '${user.points}'),
            _buildInfoItem('注册时间', controller.getRegistrationDate()),
          ],
        ),
      );
    });
  }

  /// 构建信息项
  Widget _buildInfoItem(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTextStyles.bodyMedium.copyWith(
              color: Get.theme.colorScheme.onSurface.withAlpha(153),
            ),
          ),
          Text(
            value,
            style: AppTextStyles.bodyMedium.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  /// 构建功能列表
  Widget _buildFunctionList() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      decoration: BoxDecoration(
        color: Get.theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(13),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildFunctionItem(
            icon: Icons.history,
            title: '下载历史',
            onTap: controller.goToHistory,
          ),
          _buildDivider(),
          _buildFunctionItem(
            icon: Icons.download,
            title: '下载任务',
            onTap: controller.goToTasks,
          ),
          _buildDivider(),
          _buildFunctionItem(
            icon: Icons.card_membership,
            title: '会员中心',
            onTap: controller.goToMembership,
          ),
          _buildDivider(),
          _buildFunctionItem(
            icon: Icons.monetization_on,
            title: '积分中心',
            onTap: controller.goToPoints,
          ),
          _buildDivider(),
          _buildFunctionItem(
            icon: Icons.settings,
            title: '设置',
            onTap: controller.goToSettings,
          ),
          _buildDivider(),
          _buildFunctionItem(
            icon: Icons.more_horiz,
            title: '更多',
            onTap: controller.goToMore,
          ),
        ],
      ),
    );
  }

  /// 构建功能项
  Widget _buildFunctionItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: 16.w,
          vertical: 16.h,
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 24.sp,
              color: AppColors.primary,
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: Text(
                title,
                style: AppTextStyles.bodyLarge,
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 16.sp,
              color: Get.theme.colorScheme.onSurface.withAlpha(77),
            ),
          ],
        ),
      ),
    );
  }

  /// 构建分隔线
  Widget _buildDivider() {
    return Divider(
      height: 1,
      thickness: 1,
      color: Get.theme.colorScheme.onSurface.withAlpha(13),
      indent: 56.w,
    );
  }

  /// 构建关于部分
  Widget _buildAboutSection() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      decoration: BoxDecoration(
        color: Get.theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(13),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildFunctionItem(
            icon: Icons.info_outline,
            title: '关于应用',
            onTap: () => _showAboutDialog(),
          ),
          _buildDivider(),
          _buildFunctionItem(
            icon: Icons.update,
            title: '检查更新',
            onTap: () => Get.snackbar('提示', '当前已是最新版本'),
          ),
          _buildDivider(),
          _buildFunctionItem(
            icon: Icons.privacy_tip_outlined,
            title: '隐私政策',
            onTap: () =>
                Utils.launchURL('https://tubesavely.cosyment.com/privacy'),
          ),
          _buildDivider(),
          _buildFunctionItem(
            icon: Icons.gavel_outlined,
            title: '服务条款',
            onTap: () =>
                Utils.launchURL('https://tubesavely.cosyment.com/terms'),
          ),
        ],
      ),
    );
  }

  /// 构建版本信息
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

  /// 显示关于对话框
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
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('关闭'),
          ),
        ],
      ),
    );
  }

  /// 功能项
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

  /// 构建退出登录按钮
  Widget _buildLogoutButton() {
    return Obx(() {
      if (!controller.isLoggedIn.value) {
        return const SizedBox.shrink();
      }

      return Container(
        margin: EdgeInsets.symmetric(horizontal: 16.w),
        width: double.infinity,
        child: ElevatedButton(
          onPressed: controller.isLoading.value ? null : controller.logout,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red.shade100,
            foregroundColor: Colors.red,
            padding: EdgeInsets.symmetric(vertical: 16.h),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.r),
            ),
            elevation: 0,
          ),
          child: controller.isLoading.value
              ? SizedBox(
                  width: 24.w,
                  height: 24.w,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.w,
                    valueColor: const AlwaysStoppedAnimation<Color>(Colors.red),
                  ),
                )
              : Text(
                  '退出登录',
                  style: AppTextStyles.titleMedium.copyWith(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
        ),
      );
    });
  }
}
