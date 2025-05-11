import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:tubesavely/app/services/video_player_service.dart';
import 'package:tubesavely/app/theme/app_theme.dart';

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
                  color: Get.theme.colorScheme.onSurface,
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
            color: Colors.black.withAlpha(13),
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

  // 视频预览/播放区域
  Widget _buildVideoPreview() {
    final video = controller.video.value!;

    return Obx(() {
      if (controller.isPlaying.value) {
        // 显示视频播放器
        return Stack(
          alignment: Alignment.center,
          children: [
            // 视频播放器
            Container(
              width: double.infinity,
              height: 220.h,
              color: Colors.black,
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: Video(controller: controller.videoController),
              ),
            ),

            // 点击区域，用于显示/隐藏控制器
            Positioned.fill(
              child: GestureDetector(
                onTap: controller.toggleControls,
                behavior: HitTestBehavior.translucent,
                child: Container(color: Colors.transparent),
              ),
            ),

            // 控制器
            Obx(() {
              if (controller.showControls.value) {
                return _buildVideoControls();
              } else {
                return const SizedBox.shrink();
              }
            }),

            // 加载指示器
            Obx(() {
              if (controller.playerStatus.value == PlayerStatus.loading) {
                return const Center(
                  child: CircularProgressIndicator(
                    valueColor:
                        AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
                  ),
                );
              } else {
                return const SizedBox.shrink();
              }
            }),
          ],
        );
      } else {
        // 显示缩略图和播放按钮
        return GestureDetector(
          onTap: () => controller.playVideo(),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: double.infinity,
                height: 220.h,
                color: Colors.black,
                child: video.thumbnail != null
                    ? CachedNetworkImage(
                        imageUrl: video.thumbnail!,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => const Center(
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                                AppTheme.primaryColor),
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
              ),
              Container(
                width: 60.w,
                height: 60.w,
                decoration: BoxDecoration(
                  color: Colors.black.withAlpha(128), // 0.5 透明度
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.play_arrow,
                  color: Colors.white,
                  size: 40.sp,
                ),
              ),
            ],
          ),
        );
      }
    });
  }

  // 视频控制器
  Widget _buildVideoControls() {
    return Stack(
      children: [
        // 顶部控制栏（标题和返回按钮）
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withAlpha(179),
                  Colors.transparent,
                ],
              ),
            ),
            child: Row(
              children: [
                IconButton(
                  icon: Icon(
                    Icons.arrow_back,
                    color: Colors.white,
                    size: 20.sp,
                  ),
                  onPressed: () {
                    controller.togglePlayPause();
                    controller.showControls.value = true;
                  },
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
                SizedBox(width: 8.w),
                Expanded(
                  child: Text(
                    controller.video.value?.title ?? '',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14.sp,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),

        // 中间控制按钮
        Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 快退按钮
              IconButton(
                icon: Icon(Icons.replay_10, color: Colors.white, size: 36.sp),
                onPressed: controller.rewind10Seconds,
              ),

              SizedBox(width: 16.w),

              // 播放/暂停按钮
              Container(
                width: 60.w,
                height: 60.w,
                decoration: BoxDecoration(
                  color: Colors.black.withAlpha(128), // 0.5 透明度
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: Icon(
                    controller.playerStatus.value == PlayerStatus.playing
                        ? Icons.pause
                        : Icons.play_arrow,
                    color: Colors.white,
                    size: 40.sp,
                  ),
                  onPressed: controller.togglePlayPause,
                ),
              ),

              SizedBox(width: 16.w),

              // 快进按钮
              IconButton(
                icon: Icon(Icons.forward_10, color: Colors.white, size: 36.sp),
                onPressed: controller.forward10Seconds,
              ),
            ],
          ),
        ),

        // 底部控制栏（进度条、时间、全屏按钮）
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [
                  Colors.black.withAlpha(179),
                  Colors.transparent,
                ],
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 进度条
                _buildProgressBar(),

                SizedBox(height: 8.h),

                // 时间和控制按钮
                Row(
                  children: [
                    // 当前时间
                    Text(
                      controller.getFormattedPosition(),
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12.sp,
                      ),
                    ),

                    SizedBox(width: 8.w),

                    // 总时长
                    Text(
                      '/ ${controller.getFormattedDuration()}',
                      style: TextStyle(
                        color: Colors.white.withAlpha(179),
                        fontSize: 12.sp,
                      ),
                    ),

                    const Spacer(),

                    // 静音按钮
                    IconButton(
                      icon: Icon(
                        controller.isMuted.value
                            ? Icons.volume_off
                            : Icons.volume_up,
                        color: Colors.white,
                        size: 20.sp,
                      ),
                      onPressed: controller.toggleMute,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),

                    SizedBox(width: 16.w),

                    // 全屏按钮
                    IconButton(
                      icon: Icon(
                        controller.isFullscreen.value
                            ? Icons.fullscreen_exit
                            : Icons.fullscreen,
                        color: Colors.white,
                        size: 20.sp,
                      ),
                      onPressed: controller.toggleFullscreen,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // 进度条
  Widget _buildProgressBar() {
    return Obx(() {
      double value = 0.0;

      if (controller.duration.value > 0) {
        if (controller.isDraggingProgress.value) {
          value = controller.dragProgress.value;
        } else {
          value = controller.position.value / controller.duration.value;
        }
      }

      return SliderTheme(
        data: SliderThemeData(
          trackHeight: 4.h,
          thumbShape: RoundSliderThumbShape(enabledThumbRadius: 6.r),
          overlayShape: RoundSliderOverlayShape(overlayRadius: 12.r),
          activeTrackColor: AppTheme.primaryColor,
          inactiveTrackColor: Colors.white.withAlpha(77), // 0.3 透明度
          thumbColor: AppTheme.primaryColor,
          overlayColor: AppTheme.primaryColor.withAlpha(77), // 0.3 透明度
        ),
        child: Slider(
          value: value.clamp(0.0, 1.0),
          onChanged: (value) {
            if (controller.duration.value > 0) {
              controller.updateDragProgress(value);
            }
          },
          onChangeStart: (value) {
            controller.startDraggingProgress(value);
          },
          onChangeEnd: (value) {
            controller.endDraggingProgress();
          },
        ),
      );
    });
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
              color: Get.theme.colorScheme.onSurface,
            ),
          ),
          SizedBox(height: 8.h),
          Row(
            children: [
              Icon(
                Icons.videocam,
                size: 16.sp,
                color: Get.theme.colorScheme.onSurface.withAlpha(153),
              ),
              SizedBox(width: 4.w),
              Text(
                video.platform ?? '未知平台',
                style: TextStyle(
                  fontSize: 14.sp,
                  color: Get.theme.colorScheme.onSurface.withAlpha(153),
                ),
              ),
              SizedBox(width: 16.w),
              Icon(
                Icons.access_time,
                size: 16.sp,
                color: Get.theme.colorScheme.onSurface.withAlpha(153),
              ),
              SizedBox(width: 4.w),
              Text(
                video.formattedDuration,
                style: TextStyle(
                  fontSize: 14.sp,
                  color: Get.theme.colorScheme.onSurface.withAlpha(153),
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
                  color: Get.theme.colorScheme.onSurface.withAlpha(153),
                ),
                SizedBox(width: 4.w),
                Text(
                  '作者: ${video.author}',
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: Get.theme.colorScheme.onSurface.withAlpha(153),
                  ),
                ),
              ],
            ),
          ],
          SizedBox(height: 16.h),
          Divider(
            color: Get.theme.colorScheme.onSurface.withAlpha(26),
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
              color: Get.theme.colorScheme.onSurface,
            ),
          ),
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
                  colors: const [
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
                  color: Get.theme.colorScheme.onSurface.withAlpha(26),
                ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppTheme.primaryColor.withAlpha(77),
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
          // 播放/暂停按钮
          SizedBox(
            width: double.infinity,
            child: Obx(() {
              final bool isPlaying = controller.isPlaying.value;
              return ElevatedButton(
                onPressed: isPlaying
                    ? controller.togglePlayPause
                    : controller.playVideo,
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 12.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  backgroundColor:
                      isPlaying ? Colors.orange : AppTheme.accentColor,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      isPlaying ? Icons.pause : Icons.play_arrow,
                      size: 20.sp,
                      color: Colors.white,
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      isPlaying ? '暂停播放' : '播放视频',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ),
          SizedBox(height: 12.h),
          // 下载按钮
          SizedBox(
            width: double.infinity,
            child: Obx(() {
              return ElevatedButton(
                onPressed: controller.isDownloading.value
                    ? null
                    : controller.downloadVideo,
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
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
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
          // 转换按钮
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Get.toNamed('/convert'),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 12.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
                backgroundColor: Colors.deepPurple,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.transform,
                    size: 20.sp,
                    color: Colors.white,
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    '视频格式转换',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
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
