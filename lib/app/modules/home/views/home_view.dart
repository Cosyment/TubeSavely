import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../data/models/video_model.dart';
import '../../../theme/app_theme.dart';
import '../controllers/home_controller.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildAppBar(),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildUrlInput(),
                    SizedBox(height: 24.h),
                    _buildQuickActions(),
                    SizedBox(height: 24.h),
                    _buildTrendingVideos(),
                    SizedBox(height: 24.h),
                    _buildDownloadOptions(),
                    SizedBox(height: 24.h),
                    _buildSupportedPlatforms(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 顶部导航栏
  Widget _buildAppBar() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: Get.theme.colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(13),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'TubeSavely',
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.bold,
              foreground: Paint()
                ..shader = LinearGradient(
                  colors: [
                    AppTheme.primaryColor,
                    AppTheme.accentColor,
                  ],
                ).createShader(Rect.fromLTWH(0, 0, 200.w, 70.h)),
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: Icon(Icons.history, size: 22.sp),
                onPressed: () => Get.toNamed('/history'),
                padding: EdgeInsets.all(8.w),
                constraints: const BoxConstraints(),
              ),
              SizedBox(width: 4.w),
              IconButton(
                icon: Icon(Icons.download, size: 22.sp),
                onPressed: () => Get.toNamed('/tasks'),
                padding: EdgeInsets.all(8.w),
                constraints: const BoxConstraints(),
              ),
              SizedBox(width: 4.w),
              IconButton(
                icon: Icon(Icons.settings, size: 22.sp),
                onPressed: () => Get.toNamed('/settings'),
                padding: EdgeInsets.all(8.w),
                constraints: const BoxConstraints(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // URL输入框
  Widget _buildUrlInput() {
    return Obx(() {
      return Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: AppTheme.primaryColor.withAlpha(26),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: TextField(
          controller: controller.urlController,
          decoration: InputDecoration(
            hintText: '输入视频链接...',
            hintStyle: TextStyle(
              color: Colors.grey,
              fontSize: 14.sp,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16.r),
              borderSide: BorderSide.none,
            ),
            filled: true,
            fillColor: Get.theme.colorScheme.surface,
            contentPadding: EdgeInsets.symmetric(
              horizontal: 16.w,
              vertical: 16.h,
            ),
            suffixIcon: Container(
              margin: EdgeInsets.all(4.w),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppTheme.primaryColor,
                    AppTheme.accentColor,
                  ],
                ),
                borderRadius: BorderRadius.circular(12.r),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primaryColor.withAlpha(77),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: controller.isLoading.value
                  ? Padding(
                      padding: EdgeInsets.all(8.w),
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        strokeWidth: 2.w,
                      ),
                    )
                  : IconButton(
                      icon: Icon(
                        Icons.download,
                        color: Colors.white,
                        size: 20.sp,
                      ),
                      onPressed: controller.parseVideo,
                    ),
            ),
          ),
          style: TextStyle(
            fontSize: 14.sp,
            color: Get.theme.colorScheme.onSurface,
          ),
          onSubmitted: (_) => controller.parseVideo(),
        ),
      );
    });
  }

  // 快捷功能区
  Widget _buildQuickActions() {
    return Row(
      children: [
        Expanded(
          child: _buildActionCard(
            gradient: LinearGradient(
              colors: [
                Color(0xFF8B5CF6),
                Color(0xFF7C3AED),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            icon: Icons.workspace_premium,
            title: '升级会员',
            subtitle: '享受更多特权',
            onTap: () => Get.toNamed('/login'),
          ),
        ),
        SizedBox(width: 16.w),
        Expanded(
          child: _buildActionCard(
            gradient: LinearGradient(
              colors: [
                Color(0xFF3B82F6),
                Color(0xFF0EA5E9),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            icon: Icons.monetization_on,
            title: '充值积分',
            subtitle: '畅享下载体验',
            onTap: () => Get.toNamed('/login'),
          ),
        ),
      ],
    );
  }

  // 快捷功能卡片
  Widget _buildActionCard({
    required LinearGradient gradient,
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: gradient.colors.first.withAlpha(77),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 40.w,
              height: 40.w,
              decoration: BoxDecoration(
                color: Colors.white.withAlpha(51),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Icon(
                icon,
                color: Colors.white,
                size: 24.sp,
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: Colors.white.withAlpha(204),
                      fontSize: 12.sp,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 下载选项
  Widget _buildDownloadOptions() {
    return Obx(() {
      if (controller.currentVideo.value == null) {
        return SizedBox.shrink();
      }

      return Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: Get.theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(13),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(
            color: AppTheme.primaryColor.withAlpha(26),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.tune,
                  color: AppTheme.primaryColor,
                  size: 20.sp,
                ),
                SizedBox(width: 8.w),
                Text(
                  '下载选项',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    foreground: Paint()
                      ..shader = const LinearGradient(
                        colors: [
                          AppTheme.primaryColor,
                          AppTheme.accentColor,
                        ],
                      ).createShader(Rect.fromLTWH(0, 0, 120.w, 24.h)),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.h),
            // 视频信息
            if (controller.currentVideo.value != null)
              _buildVideoInfo(controller.currentVideo.value!),
            SizedBox(height: 16.h),
            // 清晰度选择
            Text(
              '清晰度',
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
                color: Get.theme.colorScheme.onSurface,
              ),
            ),
            SizedBox(height: 8.h),
            _buildQualityOptions(),
            SizedBox(height: 16.h),
            // 格式选择
            Text(
              '格式',
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
                color: Get.theme.colorScheme.onSurface,
              ),
            ),
            SizedBox(height: 8.h),
            _buildFormatOptions(),
            SizedBox(height: 16.h),
            // 下载按钮
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: controller.downloadVideo,
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 12.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  backgroundColor: AppTheme.primaryColor,
                ),
                child: Text(
                  '开始下载',
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
      );
    });
  }

  // 视频信息
  Widget _buildVideoInfo(VideoModel video) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Get.theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 缩略图
          if (video.thumbnail != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(8.r),
              child: CachedNetworkImage(
                imageUrl: video.thumbnail!,
                width: 80.w,
                height: 60.h,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  color: Colors.grey[300],
                  child: Center(
                    child: CircularProgressIndicator(
                      strokeWidth: 2.w,
                    ),
                  ),
                ),
                errorWidget: (context, url, error) => Container(
                  color: Colors.grey[300],
                  child: Icon(
                    Icons.error,
                    color: Colors.grey[500],
                  ),
                ),
              ),
            )
          else
            Container(
              width: 80.w,
              height: 60.h,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Icon(
                Icons.video_library,
                color: Colors.grey[500],
              ),
            ),
          SizedBox(width: 12.w),
          // 视频信息
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  video.title,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                    color: Get.theme.colorScheme.onSurface,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 4.h),
                if (video.platform != null)
                  Text(
                    '来源: ${video.platform}',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: Get.theme.colorScheme.onSurface.withAlpha(179),
                    ),
                  ),
                if (video.duration != null)
                  Text(
                    '时长: ${video.duration! ~/ 60}:${(video.duration! % 60).toString().padLeft(2, '0')}',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: Get.theme.colorScheme.onSurface.withAlpha(179),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 清晰度选项
  Widget _buildQualityOptions() {
    return Wrap(
      spacing: 8.w,
      runSpacing: 8.h,
      children: [
        _buildOptionButton(
          label: '1080P',
          isSelected: controller.selectedQuality.value == '1080P',
          onTap: () => controller.setQuality('1080P'),
        ),
        _buildOptionButton(
          label: '720P',
          isSelected: controller.selectedQuality.value == '720P',
          onTap: () => controller.setQuality('720P'),
        ),
        _buildOptionButton(
          label: '480P',
          isSelected: controller.selectedQuality.value == '480P',
          onTap: () => controller.setQuality('480P'),
        ),
      ],
    );
  }

  // 格式选项
  Widget _buildFormatOptions() {
    return Wrap(
      spacing: 8.w,
      runSpacing: 8.h,
      children: [
        _buildOptionButton(
          label: 'MP4',
          isSelected: controller.selectedFormat.value == 'MP4',
          onTap: () => controller.setFormat('MP4'),
        ),
        _buildOptionButton(
          label: 'MKV',
          isSelected: controller.selectedFormat.value == 'MKV',
          onTap: () => controller.setFormat('MKV'),
        ),
        _buildOptionButton(
          label: 'MP3',
          isSelected: controller.selectedFormat.value == 'MP3',
          onTap: () => controller.setFormat('MP3'),
        ),
      ],
    );
  }

  // 选项按钮
  Widget _buildOptionButton({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: 16.w,
          vertical: 10.h,
        ),
        decoration: BoxDecoration(
          gradient: isSelected
              ? const LinearGradient(
                  colors: [
                    AppTheme.primaryColor,
                    AppTheme.accentColor,
                  ],
                )
              : null,
          color: isSelected ? null : Get.theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(12.r),
          border: isSelected
              ? null
              : Border.all(
                  color: Get.theme.colorScheme.onSurface.withOpacity(0.1),
                ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppTheme.primaryColor.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
            color: isSelected ? Colors.white : Get.theme.colorScheme.onSurface,
          ),
        ),
      ),
    );
  }

  // 热门视频
  Widget _buildTrendingVideos() {
    return Obx(() {
      if (controller.trendingVideos.isEmpty) {
        return const SizedBox.shrink();
      }

      return Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: Get.theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(13), // 0.05 透明度
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(
            color: AppTheme.primaryColor.withAlpha(26), // 0.1 透明度
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.trending_up,
                      color: AppTheme.primaryColor,
                      size: 20.sp,
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      '热门视频',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                        foreground: Paint()
                          ..shader = const LinearGradient(
                            colors: [
                              AppTheme.primaryColor,
                              AppTheme.accentColor,
                            ],
                          ).createShader(Rect.fromLTWH(0, 0, 120.w, 24.h)),
                      ),
                    ),
                  ],
                ),
                TextButton(
                  onPressed: () {
                    // 查看更多热门视频
                  },
                  child: Text(
                    '查看更多',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.h),
            SizedBox(
              height: 180.h,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: controller.trendingVideos.length,
                itemBuilder: (context, index) {
                  final video = controller.trendingVideos[index];
                  return GestureDetector(
                    onTap: () => controller.openVideoDetail(video),
                    child: Container(
                      width: 160.w,
                      margin: EdgeInsets.only(right: 12.w),
                      decoration: BoxDecoration(
                        color: Get.theme.colorScheme.surface,
                        borderRadius: BorderRadius.circular(12.r),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withAlpha(13), // 0.05 透明度
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 缩略图
                          ClipRRect(
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(12.r),
                              topRight: Radius.circular(12.r),
                            ),
                            child: Stack(
                              children: [
                                CachedNetworkImage(
                                  imageUrl: video.thumbnail ?? '',
                                  width: 160.w,
                                  height: 90.h,
                                  fit: BoxFit.cover,
                                  placeholder: (context, url) => Container(
                                    color: Colors.grey[300],
                                    child: const Center(
                                      child: CircularProgressIndicator(),
                                    ),
                                  ),
                                  errorWidget: (context, url, error) =>
                                      Container(
                                    color: Colors.grey[300],
                                    child: const Icon(
                                      Icons.error,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ),
                                // 时长
                                if (video.duration != null)
                                  Positioned(
                                    right: 8.w,
                                    bottom: 8.h,
                                    child: Container(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 6.w,
                                        vertical: 2.h,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.black
                                            .withAlpha(179), // 0.7 透明度
                                        borderRadius:
                                            BorderRadius.circular(4.r),
                                      ),
                                      child: Text(
                                        '${video.duration! ~/ 60}:${(video.duration! % 60).toString().padLeft(2, '0')}',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 10.sp,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          // 视频信息
                          Padding(
                            padding: EdgeInsets.all(8.w),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  video.title,
                                  style: TextStyle(
                                    fontSize: 12.sp,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                SizedBox(height: 4.h),
                                Text(
                                  video.author ?? '未知作者',
                                  style: TextStyle(
                                    fontSize: 10.sp,
                                    color: Get.theme.colorScheme.onSurface
                                        .withAlpha(179), // 0.7 透明度
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                SizedBox(height: 4.h),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.play_arrow,
                                      size: 12.sp,
                                      color: AppTheme.primaryColor,
                                    ),
                                    SizedBox(width: 2.w),
                                    Text(
                                      '${(index + 1) * 1000 + 500}次播放',
                                      style: TextStyle(
                                        fontSize: 10.sp,
                                        color: Get.theme.colorScheme.onSurface
                                            .withAlpha(179), // 0.7 透明度
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      );
    });
  }

  // 支持的平台
  Widget _buildSupportedPlatforms() {
    return Obx(() {
      if (controller.supportedPlatforms.isEmpty) {
        return const SizedBox.shrink();
      }

      return Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: Get.theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(13), // 0.05 透明度
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(
            color: AppTheme.primaryColor.withAlpha(26), // 0.1 透明度
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.language,
                  color: AppTheme.primaryColor,
                  size: 20.sp,
                ),
                SizedBox(width: 8.w),
                Text(
                  '支持的平台',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    foreground: Paint()
                      ..shader = LinearGradient(
                        colors: [
                          AppTheme.primaryColor,
                          AppTheme.accentColor,
                        ],
                      ).createShader(Rect.fromLTWH(0, 0, 120.w, 24.h)),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.h),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                crossAxisSpacing: 16.w,
                mainAxisSpacing: 16.h,
                childAspectRatio: 0.8,
              ),
              itemCount: controller.supportedPlatforms.length,
              itemBuilder: (context, index) {
                final platform = controller.supportedPlatforms[index];
                return _buildPlatformItem(
                  name: platform['name'] ?? '',
                  icon: platform['icon'] ?? '',
                );
              },
            ),
          ],
        ),
      );
    });
  }

  // 平台项
  Widget _buildPlatformItem({
    required String name,
    required String icon,
  }) {
    return Column(
      children: [
        Container(
          width: 50.w,
          height: 50.w,
          decoration: BoxDecoration(
            color: Get.theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(
              color: AppTheme.primaryColor.withAlpha(26), // 0.1 透明度
              width: 1,
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12.r),
            child: CachedNetworkImage(
              imageUrl: icon,
              width: 30.w,
              height: 30.w,
              fit: BoxFit.contain,
              placeholder: (context, url) => Center(
                child: CircularProgressIndicator(
                  strokeWidth: 2.w,
                ),
              ),
              errorWidget: (context, url, error) => Icon(
                Icons.language,
                color: Colors.grey[500],
                size: 30.sp,
              ),
            ),
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          name,
          style: TextStyle(
            fontSize: 10.sp,
            fontWeight: FontWeight.w500,
            color: Get.theme.colorScheme.onSurface,
          ),
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}
