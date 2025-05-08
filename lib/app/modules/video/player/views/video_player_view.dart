import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:tubesavely/app/services/video_player_service.dart';
import 'package:tubesavely/app/theme/app_colors.dart';
import 'package:tubesavely/app/theme/app_text_styles.dart';

import '../controllers/video_player_controller.dart';

/// 视频播放页面
class VideoPlayerView extends GetView<VideoPlayerController> {
  const VideoPlayerView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      // 如果是全屏模式，则设置为横屏
      if (controller.isFullscreen.value) {
        SystemChrome.setPreferredOrientations([
          DeviceOrientation.landscapeLeft,
          DeviceOrientation.landscapeRight,
        ]);
        SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
      } else {
        SystemChrome.setPreferredOrientations([
          DeviceOrientation.portraitUp,
        ]);
        SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
      }

      return Scaffold(
        backgroundColor: Colors.black,
        appBar: controller.isFullscreen.value
            ? null
            : AppBar(
                title: Text(
                  controller.currentVideo.value?.title ?? '视频播放',
                  style: AppTextStyles.titleLarge,
                ),
                backgroundColor: AppColors.primary,
                elevation: 0,
              ),
        body: _buildBody(),
      );
    });
  }

  /// 构建页面主体
  Widget _buildBody() {
    return Stack(
      children: [
        // 视频播放器
        Center(
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
            return _buildControls();
          } else {
            return const SizedBox.shrink();
          }
        }),

        // 加载指示器
        Obx(() {
          if (controller.status.value == PlayerStatus.loading) {
            return const Center(
              child: CircularProgressIndicator(
                color: AppColors.accent,
              ),
            );
          } else {
            return const SizedBox.shrink();
          }
        }),

        // 错误提示
        Obx(() {
          if (controller.status.value == PlayerStatus.error) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.error_outline,
                    color: Colors.red,
                    size: 48,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '播放出错',
                    style: AppTextStyles.bodyLarge.copyWith(color: Colors.white),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => Get.back(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.accent,
                    ),
                    child: const Text('返回'),
                  ),
                ],
              ),
            );
          } else {
            return const SizedBox.shrink();
          }
        }),
      ],
    );
  }

  /// 构建控制器
  Widget _buildControls() {
    return Positioned.fill(
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.black.withOpacity(0.7),
              Colors.transparent,
              Colors.transparent,
              Colors.black.withOpacity(0.7),
            ],
            stops: const [0.0, 0.2, 0.8, 1.0],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // 顶部控制栏
            _buildTopControls(),

            // 中间控制按钮
            _buildCenterControls(),

            // 底部控制栏
            _buildBottomControls(),
          ],
        ),
      ),
    );
  }

  /// 构建顶部控制栏
  Widget _buildTopControls() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // 返回按钮
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () {
              if (controller.isFullscreen.value) {
                controller.toggleFullscreen();
              } else {
                Get.back();
              }
            },
          ),

          // 视频标题
          Expanded(
            child: Text(
              controller.currentVideo.value?.title ?? '视频播放',
              style: AppTextStyles.titleMedium.copyWith(color: Colors.white),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
          ),

          // 更多按钮
          IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            onPressed: () {
              // TODO: 显示更多选项菜单
            },
          ),
        ],
      ),
    );
  }

  /// 构建中间控制按钮
  Widget _buildCenterControls() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // 快退按钮
        IconButton(
          icon: const Icon(Icons.replay_10, color: Colors.white, size: 36),
          onPressed: () => controller.seekTo(controller.position.value - 10),
        ),

        const SizedBox(width: 16),

        // 播放/暂停按钮
        Obx(() {
          final IconData icon;
          if (controller.status.value == PlayerStatus.playing) {
            icon = Icons.pause;
          } else {
            icon = Icons.play_arrow;
          }
          return IconButton(
            icon: Icon(icon, color: Colors.white, size: 48),
            onPressed: controller.togglePlayPause,
          );
        }),

        const SizedBox(width: 16),

        // 快进按钮
        IconButton(
          icon: const Icon(Icons.forward_10, color: Colors.white, size: 36),
          onPressed: () => controller.seekTo(controller.position.value + 10),
        ),
      ],
    );
  }

  /// 构建底部控制栏
  Widget _buildBottomControls() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          // 进度条
          _buildProgressBar(),

          const SizedBox(height: 8),

          // 底部按钮栏
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // 播放时间
              Obx(() {
                return Text(
                  '${controller.getFormattedPosition()} / ${controller.getFormattedDuration()}',
                  style: AppTextStyles.bodyMedium.copyWith(color: Colors.white),
                );
              }),

              // 右侧按钮组
              Row(
                children: [
                  // 静音按钮
                  Obx(() {
                    final IconData icon = controller.isMuted.value ? Icons.volume_off : Icons.volume_up;
                    return IconButton(
                      icon: Icon(icon, color: Colors.white),
                      onPressed: controller.toggleMute,
                    );
                  }),

                  // 全屏按钮
                  Obx(() {
                    final IconData icon = controller.isFullscreen.value ? Icons.fullscreen_exit : Icons.fullscreen;
                    return IconButton(
                      icon: Icon(icon, color: Colors.white),
                      onPressed: controller.toggleFullscreen,
                    );
                  }),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// 构建进度条
  Widget _buildProgressBar() {
    return Obx(() {
      final double value = controller.isDraggingProgress.value
          ? controller.dragProgress.value
          : (controller.duration.value > 0 ? controller.position.value / controller.duration.value : 0.0);

      return SliderTheme(
        data: SliderThemeData(
          trackHeight: 4,
          thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
          overlayShape: const RoundSliderOverlayShape(overlayRadius: 12),
          activeTrackColor: AppColors.accent,
          inactiveTrackColor: Colors.white.withOpacity(0.3),
          thumbColor: AppColors.accent,
          overlayColor: AppColors.accent.withOpacity(0.3),
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
}
