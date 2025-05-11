import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/models/video_model.dart';
import '../../../data/repositories/video_repository.dart';
import '../../../data/repositories/download_repository.dart';
import '../../../utils/utils.dart';
import '../../../utils/logger.dart';

class HomeController extends GetxController {
  final VideoRepository _videoRepository = Get.find<VideoRepository>();
  final DownloadRepository _downloadRepository = Get.find<DownloadRepository>();

  // 视频链接输入控制器
  final TextEditingController urlController = TextEditingController();

  // 解析状态
  final RxBool isLoading = false.obs;

  // 当前视频
  final Rx<VideoModel?> currentVideo = Rx<VideoModel?>(null);

  // 选中的清晰度和格式
  final RxString selectedQuality = '1080P'.obs;
  final RxString selectedFormat = 'MP4'.obs;

  // 支持的平台
  final RxList<Map<String, dynamic>> supportedPlatforms =
      <Map<String, dynamic>>[].obs;

  // 热门视频
  final RxList<VideoModel> trendingVideos = <VideoModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    Logger.d('HomeController initialized');
    _loadSupportedPlatforms();
    _loadTrendingVideos();
  }

  @override
  void onClose() {
    urlController.dispose();
    super.onClose();
  }

  // 加载支持的平台
  Future<void> _loadSupportedPlatforms() async {
    supportedPlatforms.value = await _videoRepository.getSupportedPlatforms();
  }

  // 解析视频链接
  Future<void> parseVideo() async {
    final url = urlController.text.trim();

    if (url.isEmpty) {
      Utils.showSnackbar('错误', '请输入视频链接', isError: true);
      return;
    }

    if (!Utils.isValidUrl(url)) {
      Utils.showSnackbar('错误', '请输入有效的URL', isError: true);
      return;
    }

    try {
      isLoading.value = true;

      final video = await _videoRepository.parseVideo(url);

      if (video != null) {
        currentVideo.value = video;

        // 设置默认清晰度和格式
        if (video.qualities.isNotEmpty) {
          selectedQuality.value = video.qualities.first.label;
        }

        if (video.formats.isNotEmpty) {
          selectedFormat.value = video.formats.first.label;
        }

        Utils.showSnackbar('成功', '视频解析成功');

        // 导航到视频详情页
        Get.toNamed('/video-detail', arguments: video);
      } else {
        Utils.showSnackbar('错误', '无法解析此视频链接', isError: true);
      }
    } catch (e) {
      Logger.e('解析视频时出错: $e');
      Utils.showSnackbar('错误', '解析视频时出错: $e', isError: true);
    } finally {
      isLoading.value = false;
    }
  }

  // 下载视频
  Future<void> downloadVideo() async {
    if (currentVideo.value == null) {
      Utils.showSnackbar('错误', '请先解析视频链接', isError: true);
      return;
    }

    try {
      isLoading.value = true;

      final task = await _downloadRepository.addDownloadTask(
        currentVideo.value!,
        quality: selectedQuality.value,
        format: selectedFormat.value,
      );

      if (task != null) {
        // 添加到下载历史
        await _videoRepository.addToDownloadHistory(currentVideo.value!);

        Utils.showSnackbar('成功', '已添加到下载队列');

        // 清空当前视频和输入框
        currentVideo.value = null;
        urlController.clear();
      } else {
        Utils.showSnackbar('错误', '创建下载任务失败', isError: true);
      }
    } catch (e) {
      Logger.e('下载视频时出错: $e');
      Utils.showSnackbar('错误', '下载视频时出错: $e', isError: true);
    } finally {
      isLoading.value = false;
    }
  }

  // 设置清晰度
  void setQuality(String quality) {
    selectedQuality.value = quality;
  }

  // 设置格式
  void setFormat(String format) {
    selectedFormat.value = format;
  }

  // 加载热门视频
  Future<void> _loadTrendingVideos() async {
    try {
      final videos = await _videoRepository.getTrendingVideos();
      trendingVideos.value = videos;
    } catch (e) {
      Logger.e('加载热门视频时出错: $e');
    }
  }

  // 打开视频详情
  void openVideoDetail(VideoModel video) {
    Get.toNamed('/video-detail', arguments: video);
  }
}
