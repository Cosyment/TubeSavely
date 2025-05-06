import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../theme/app_theme.dart';
import '../controllers/video_detail_controller.dart';

class VideoDetailView extends GetView<VideoDetailController> {
  const VideoDetailView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Obx(() {
          if (controller.video.value == null) {
            return Center(
              child: Text(
                '没有视频信息',
                style: TextStyle(
                  fontSize: 16.sp,
                  color: Get.theme.colorScheme.onBackground,
                ),
              ),
            );
          }

          return Column(
            children: [
              _buildAppBar(),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildVideoPreview(),
                      SizedBox(height: 16.h),
                      _buildVideoInfo(),
                      SizedBox(height: 16.h),
                      _buildDownloadOptions(),
                      SizedBox(height: 16.h),
                      _buildActionButtons(),
                      SizedBox(height: 16.h),
                    ],
                  ),
                ),
              ),
            ],
          );
        }),
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
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          IconButton(
            icon: Icon(
              Icons.arrow_back_ios,
              size: 20.sp,
              color: Get.theme.colorScheme.onSurface,
            ),
            onPressed: () => Get.back(),
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: Text(
              '视频详情',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: Get.theme.colorScheme.onSurface,
              ),
            ),
          ),
          IconButton(
            icon: Icon(
              Icons.share,
              size: 20.sp,
              color: Get.theme.colorScheme.onSurface,
            ),
            onPressed: controller.shareVideo,
          ),
          IconButton(
            icon: Icon(
              Icons.favorite_border,
              size: 20.sp,
              color: Get.theme.colorScheme.onSurface,
            ),
            onPressed: controller.favoriteVideo,
          ),
        ],
      ),
    );
  }

  // 视频预览
  Widget _buildVideoPreview() {
    final video = controller.video.value!;

    return Container(
      width: double.infinity,
      height: 200.h,
      color: Colors.black,
      child: video.thumbnail != null
          ? CachedNetworkImage(
              imageUrl: video.thumbnail!,
              fit: BoxFit.cover,
              placeholder: (context, url) => const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
                ),
              ),
              errorWidget: (context, url, error) => Center(
                child: Icon(
                  Icons.error,
                  color: Colors.white,
                  size: 40.sp,
                ),
              ),
            )
          : Center(
              child: Icon(
                Icons.video_library,
                color: Colors.white,
                size: 40.sp,
              ),
            ),
    );
  }

  // 视频信息
  Widget _buildVideoInfo() {
    final video = controller.video.value!;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            video.title,
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: Get.theme.colorScheme.onBackground,
            ),
          ),
          SizedBox(height: 8.h),
          Row(
            children: [
              Icon(
                Icons.videocam,
                size: 16.sp,
                color: Get.theme.colorScheme.onBackground.withOpacity(0.6),
              ),
              SizedBox(width: 4.w),
              Text(
                video.platform ?? '未知平台',
                style: TextStyle(
                  fontSize: 14.sp,
                  color: Get.theme.colorScheme.onBackground.withOpacity(0.6),
                ),
              ),
              SizedBox(width: 16.w),
              Icon(
                Icons.access_time,
                size: 16.sp,
                color: Get.theme.colorScheme.onBackground.withOpacity(0.6),
              ),
              SizedBox(width: 4.w),
              Text(
                video.formattedDuration,
                style: TextStyle(
                  fontSize: 14.sp,
                  color: Get.theme.colorScheme.onBackground.withOpacity(0.6),
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          if (video.author != null) ...[
            Row(
              children: [
                Icon(
                  Icons.person,
                  size: 16.sp,
                  color: Get.theme.colorScheme.onBackground.withOpacity(0.6),
                ),
                SizedBox(width: 4.w),
                Text(
                  '作者: ${video.author}',
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: Get.theme.colorScheme.onBackground.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ],
          SizedBox(height: 16.h),
          Divider(
            color: Get.theme.colorScheme.onBackground.withOpacity(0.1),
            thickness: 1,
          ),
        ],
      ),
    );
  }

  // 下载选项
  Widget _buildDownloadOptions() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '下载选项',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
              color: Get.theme.colorScheme.onBackground,
            ),
          ),
          SizedBox(height: 16.h),
          // 清晰度选择
          Text(
            '清晰度',
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
              color: Get.theme.colorScheme.onBackground,
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
              color: Get.theme.colorScheme.onBackground,
            ),
          ),
          SizedBox(height: 8.h),
          _buildFormatOptions(),
        ],
      ),
    );
  }

  // 清晰度选项
  Widget _buildQualityOptions() {
    return Obx(() {
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
    });
  }

  // 格式选项
  Widget _buildFormatOptions() {
    return Obx(() {
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
    });
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
              ? LinearGradient(
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

  // 操作按钮
  Widget _buildActionButtons() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Column(
        children: [
          SizedBox(
            width: double.infinity,
            child: Obx(() {
              return ElevatedButton(
                onPressed: controller.isDownloading.value ? null : controller.downloadVideo,
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 12.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  backgroundColor: AppTheme.primaryColor,
                ),
                child: controller.isDownloading.value
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 20.w,
                            height: 20.w,
                            child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              strokeWidth: 2.w,
                            ),
                          ),
                          SizedBox(width: 8.w),
                          Text(
                            '正在下载...',
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      )
                    : Text(
                        '开始下载',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
              );
            }),
          ),
          SizedBox(height: 12.h),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: controller.shareVideo,
                  style: OutlinedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 12.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    side: BorderSide(color: AppTheme.primaryColor),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.share,
                        size: 18.sp,
                        color: AppTheme.primaryColor,
                      ),
                      SizedBox(width: 8.w),
                      Text(
                        '分享',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w500,
                          color: AppTheme.primaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: OutlinedButton(
                  onPressed: controller.favoriteVideo,
                  style: OutlinedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 12.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    side: BorderSide(color: AppTheme.primaryColor),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.favorite_border,
                        size: 18.sp,
                        color: AppTheme.primaryColor,
                      ),
                      SizedBox(width: 8.w),
                      Text(
                        '收藏',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w500,
                          color: AppTheme.primaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
