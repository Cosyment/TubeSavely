import 'dart:io';
import 'package:file_picker/file_picker.dart';
// import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import '../../../data/repositories/video_converter_repository.dart';
import '../../../services/video_converter_service.dart';
import '../../../utils/logger.dart';
import '../../../utils/utils.dart';

class ConvertController extends GetxController {
  final VideoConverterRepository _videoConverterRepository = Get.find<VideoConverterRepository>();
  final VideoConverterService _videoConverterService = Get.find<VideoConverterService>();

  // 选择的视频文件
  final RxList<File> selectedFiles = <File>[].obs;

  // 转换任务列表
  final RxList<ConversionTask> conversionTasks = <ConversionTask>[].obs;

  // 选择的格式
  final RxString selectedFormat = 'mp4'.obs;

  // 选择的分辨率
  final RxString selectedResolution = '720p'.obs;

  // 可用的格式
  final List<String> availableFormats = ['mp4', 'mkv', 'avi', 'mov', 'webm', 'mp3'];

  // 可用的分辨率
  final List<String> availableResolutions = ['480p', '720p', '1080p', '2K', '4K'];

  // 是否正在加载
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    _loadConversionTasks();
  }

  // 加载转换任务
  void _loadConversionTasks() {
    conversionTasks.assignAll(_videoConverterService.getTasks());
    // 监听任务列表变化
    ever(_videoConverterService.conversionTasks, (tasks) {
      conversionTasks.assignAll(tasks);
    });
  }

  // 选择视频文件
  Future<void> pickVideoFiles() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.video,
        allowMultiple: true,
      );

      if (result != null && result.files.isNotEmpty) {
        final files = result.files
            .where((file) => file.path != null)
            .map((file) => File(file.path!))
            .toList();

        if (files.isNotEmpty) {
          selectedFiles.addAll(files);
        }
      }
    } catch (e) {
      Logger.e('Error picking video files: $e');
      Utils.showSnackbar('错误', '选择视频文件时出错: $e', isError: true);
    }
  }

  // 移除选择的文件
  void removeFile(File file) {
    selectedFiles.remove(file);
  }

  // 清空选择的文件
  void clearFiles() {
    selectedFiles.clear();
  }

  // 设置格式
  void setFormat(String format) {
    selectedFormat.value = format;
  }

  // 设置分辨率
  void setResolution(String resolution) {
    selectedResolution.value = resolution;
  }

  // 转换视频
  Future<void> convertVideo(File file) async {
    try {
      isLoading.value = true;

      final task = await _videoConverterRepository.createConversionTask(
        sourceFilePath: file.path,
        format: selectedFormat.value,
        resolution: selectedResolution.value,
      );

      if (task != null) {
        Utils.showSnackbar('成功', '已添加到转换队列');
        removeFile(file);
      } else {
        Utils.showSnackbar('错误', '创建转换任务失败', isError: true);
      }
    } catch (e) {
      Logger.e('Error converting video: $e');
      Utils.showSnackbar('错误', '转换视频时出错: $e', isError: true);
    } finally {
      isLoading.value = false;
    }
  }

  // 转换所有选择的视频
  Future<void> convertAllVideos() async {
    if (selectedFiles.isEmpty) {
      Utils.showSnackbar('提示', '请先选择视频文件');
      return;
    }

    try {
      isLoading.value = true;

      for (final file in List<File>.from(selectedFiles)) {
        await convertVideo(file);
      }

      Utils.showSnackbar('成功', '所有视频已添加到转换队列');
    } catch (e) {
      Logger.e('Error converting all videos: $e');
      Utils.showSnackbar('错误', '转换视频时出错: $e', isError: true);
    } finally {
      isLoading.value = false;
    }
  }

  // 取消转换任务
  Future<void> cancelTask(String taskId) async {
    try {
      final success = await _videoConverterRepository.cancelConversionTask(taskId);
      if (success) {
        Utils.showSnackbar('成功', '已取消转换任务');
      } else {
        Utils.showSnackbar('错误', '取消转换任务失败', isError: true);
      }
    } catch (e) {
      Logger.e('Error canceling conversion task: $e');
      Utils.showSnackbar('错误', '取消转换任务时出错: $e', isError: true);
    }
  }

  // 删除转换任务
  Future<void> deleteTask(String taskId, {bool deleteFile = false}) async {
    try {
      final success = await _videoConverterRepository.deleteConversionTask(
        taskId,
        deleteFile: deleteFile,
      );
      if (success) {
        Utils.showSnackbar('成功', '已删除转换任务');
      } else {
        Utils.showSnackbar('错误', '删除转换任务失败', isError: true);
      }
    } catch (e) {
      Logger.e('Error deleting conversion task: $e');
      Utils.showSnackbar('错误', '删除转换任务时出错: $e', isError: true);
    }
  }

  // 打开输出文件夹
  Future<void> openOutputFolder() async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final convertDir = Directory('${appDir.path}/converted');

      if (await convertDir.exists()) {
        // 在移动平台上，我们可能需要使用不同的方法
        if (Platform.isAndroid || Platform.isIOS) {
          Utils.showSnackbar('提示', '在移动平台上无法直接打开文件夹');
        } else {
          // 在桌面平台上，我们可以使用open_file打开文件夹
          await OpenFile.open(convertDir.path);
        }
      } else {
        Utils.showSnackbar('提示', '输出文件夹不存在');
      }
    } catch (e) {
      Logger.e('Error opening output folder: $e');
      Utils.showSnackbar('错误', '打开输出文件夹时出错: $e', isError: true);
    }
  }

  // 打开文件
  Future<void> openFile(String filePath) async {
    try {
      final file = File(filePath);
      if (await file.exists()) {
        await OpenFile.open(filePath);
      } else {
        Utils.showSnackbar('错误', '文件不存在', isError: true);
      }
    } catch (e) {
      Logger.e('Error opening file: $e');
      Utils.showSnackbar('错误', '打开文件时出错: $e', isError: true);
    }
  }
}
