import 'package:get/get.dart';
import 'package:tubesavely/app/data/models/video_model.dart';
import 'package:tubesavely/app/data/repositories/download_repository.dart';
import 'package:tubesavely/app/data/repositories/video_repository.dart';
import 'package:tubesavely/app/utils/utils.dart';

import '../../../../utils/logger.dart';

class VideoDetailController extends GetxController {
  final VideoRepository _videoRepository = Get.find<VideoRepository>();
  final DownloadRepository _downloadRepository = Get.find<DownloadRepository>();

  // 视频信息
  final Rx<VideoModel?> video = Rx<VideoModel?>(null);

  // 选中的清晰度和格式
  final RxString selectedQuality = '1080P'.obs;
  final RxString selectedFormat = 'MP4'.obs;

  // 下载状态
  final RxBool isDownloading = false.obs;

  // 视频播放控制器
  // 注意：这里使用了MediaKit，实际使用时需要初始化
  // final Rx<Player?> player = Rx<Player?>(null);

  @override
  void onInit() {
    super.onInit();
    Logger.d('VideoDetailController initialized');

    // 获取传递的参数
    if (Get.arguments != null && Get.arguments is VideoModel) {
      video.value = Get.arguments;

      // 设置默认清晰度和格式
      if (video.value!.qualities.isNotEmpty) {
        selectedQuality.value = video.value!.qualities.first.label;
      }

      if (video.value!.formats.isNotEmpty) {
        selectedFormat.value = video.value!.formats.first.label;
      }

      // 初始化播放器
      // initPlayer();
    }
  }

  @override
  void onClose() {
    // 释放播放器资源
    // if (player.value != null) {
    //   player.value!.dispose();
    // }
    super.onClose();
  }

  // 初始化播放器
  // void initPlayer() {
  //   if (video.value != null && video.value!.qualities.isNotEmpty) {
  //     // 获取预览URL
  //     final previewUrl = video.value!.qualities.first.url;
  //
  //     // 创建播放器
  //     player.value = Player();
  //
  //     // 设置媒体
  //     player.value!.open(Media(previewUrl));
  //   }
  // }

  // 设置清晰度
  void setQuality(String quality) {
    selectedQuality.value = quality;
  }

  // 设置格式
  void setFormat(String format) {
    selectedFormat.value = format;
  }

  // 下载视频
  Future<void> downloadVideo() async {
    if (video.value == null) {
      Utils.showSnackbar('错误', '视频信息不完整', isError: true);
      return;
    }

    try {
      isDownloading.value = true;

      final task = await _downloadRepository.addDownloadTask(
        video.value!,
        quality: selectedQuality.value,
        format: selectedFormat.value,
      );

      if (task != null) {
        // 添加到下载历史
        await _videoRepository.addToDownloadHistory(video.value!);

        Utils.showSnackbar('成功', '已添加到下载队列');

        // 返回上一页
        Get.back();
      } else {
        Utils.showSnackbar('错误', '创建下载任务失败', isError: true);
      }
    } catch (e) {
      Logger.e('下载视频时出错: $e');
      Utils.showSnackbar('错误', '下载视频时出错: $e', isError: true);
    } finally {
      isDownloading.value = false;
    }
  }

  // 分享视频
  void shareVideo() {
    if (video.value == null) return;

    // 实现分享功能
    Utils.showSnackbar('提示', '分享功能尚未实现');
  }

  // 收藏视频
  void favoriteVideo() {
    if (video.value == null) return;

    // 实现收藏功能
    Utils.showSnackbar('提示', '收藏功能尚未实现');
  }

  // 播放视频
  void playVideo() {
    if (video.value == null) return;

    // 获取最高质量的视频URL
    String videoUrl = '';
    if (video.value!.qualities.isNotEmpty) {
      videoUrl = video.value!.qualities.first.url;
    } else if (video.value!.formats.isNotEmpty) {
      videoUrl = video.value!.formats.first.url;
    } else {
      videoUrl = video.value!.url;
    }

    // 跳转到视频播放页面
    if (videoUrl.isNotEmpty) {
      Get.toNamed('/video-player', arguments: video.value);
    } else {
      Utils.showSnackbar('错误', '无法播放视频，未找到有效的视频链接', isError: true);
    }
  }
}
