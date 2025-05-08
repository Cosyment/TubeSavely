// import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:tubesavely/app/modules/video/convert/controllers/convert_controller.dart';
import 'package:tubesavely/app/services/video_converter_service.dart';
import 'package:tubesavely/app/theme/app_colors.dart';
import 'package:tubesavely/app/theme/app_text_styles.dart';

class ConvertView extends GetView<ConvertController> {
  const ConvertView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('视频格式转换', style: AppTextStyles.titleLarge),
        actions: [
          IconButton(
            icon: const Icon(Icons.folder_open),
            onPressed: controller.openOutputFolder,
            tooltip: '打开输出文件夹',
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildFormatSelector(),
            SizedBox(height: 16.h),
            _buildResolutionSelector(),
            SizedBox(height: 16.h),
            _buildFileSelector(),
            SizedBox(height: 16.h),
            _buildTaskList(),
          ],
        ),
      ),
      floatingActionButton: Obx(() {
        return controller.selectedFiles.isNotEmpty
            ? FloatingActionButton.extended(
                onPressed: controller.convertAllVideos,
                icon: const Icon(Icons.transform),
                label: Text('转换所有文件 (${controller.selectedFiles.length})'),
                backgroundColor: AppColors.primary,
              )
            : const SizedBox.shrink();
      }),
    );
  }

  // 格式选择器
  Widget _buildFormatSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('输出格式', style: AppTextStyles.titleMedium),
        SizedBox(height: 8.h),
        Obx(() {
          return Wrap(
            spacing: 8.w,
            runSpacing: 8.h,
            children: controller.availableFormats.map((format) {
              final isSelected = controller.selectedFormat.value == format;
              return ChoiceChip(
                label: Text(format.toUpperCase()),
                selected: isSelected,
                onSelected: (selected) {
                  if (selected) controller.setFormat(format);
                },
                backgroundColor: AppColors.background,
                selectedColor: AppColors.primary,
                labelStyle: TextStyle(
                  color: isSelected ? Colors.white : AppColors.textPrimary,
                ),
              );
            }).toList(),
          );
        }),
      ],
    );
  }

  // 分辨率选择器
  Widget _buildResolutionSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('输出分辨率', style: AppTextStyles.titleMedium),
        SizedBox(height: 8.h),
        Obx(() {
          return Wrap(
            spacing: 8.w,
            runSpacing: 8.h,
            children: controller.availableResolutions.map((resolution) {
              final isSelected = controller.selectedResolution.value == resolution;
              return ChoiceChip(
                label: Text(resolution),
                selected: isSelected,
                onSelected: (selected) {
                  if (selected) controller.setResolution(resolution);
                },
                backgroundColor: AppColors.background,
                selectedColor: AppColors.primary,
                labelStyle: TextStyle(
                  color: isSelected ? Colors.white : AppColors.textPrimary,
                ),
              );
            }).toList(),
          );
        }),
      ],
    );
  }

  // 文件选择器
  Widget _buildFileSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('选择视频文件', style: AppTextStyles.titleMedium),
            TextButton.icon(
              onPressed: controller.pickVideoFiles,
              icon: const Icon(Icons.add),
              label: const Text('添加文件'),
            ),
          ],
        ),
        SizedBox(height: 8.h),
        Obx(() {
          if (controller.selectedFiles.isEmpty) {
            return Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 24.h),
                child: Column(
                  children: [
                    Icon(Icons.video_file, size: 48.sp, color: AppColors.textSecondary),
                    SizedBox(height: 8.h),
                    Text('暂无选择的视频文件', style: AppTextStyles.bodyMedium),
                    SizedBox(height: 16.h),
                    ElevatedButton.icon(
                      onPressed: controller.pickVideoFiles,
                      icon: const Icon(Icons.add),
                      label: const Text('选择视频文件'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          return Container(
            height: 120.h,
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.border),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: ListView.builder(
              itemCount: controller.selectedFiles.length,
              itemBuilder: (context, index) {
                final file = controller.selectedFiles[index];
                return ListTile(
                  leading: Icon(Icons.video_file, color: AppColors.primary),
                  title: Text(
                    file.path.split('/').last,
                    style: AppTextStyles.bodyMedium,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Text(
                    file.path,
                    style: AppTextStyles.bodySmall,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.transform),
                        onPressed: () => controller.convertVideo(file),
                        tooltip: '转换此文件',
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () => controller.removeFile(file),
                        tooltip: '移除此文件',
                      ),
                    ],
                  ),
                );
              },
            ),
          );
        }),
      ],
    );
  }

  // 任务列表
  Widget _buildTaskList() {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('转换任务', style: AppTextStyles.titleMedium),
          SizedBox(height: 8.h),
          Expanded(
            child: Obx(() {
              if (controller.conversionTasks.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.list, size: 48.sp, color: AppColors.textSecondary),
                      SizedBox(height: 8.h),
                      Text('暂无转换任务', style: AppTextStyles.bodyMedium),
                    ],
                  ),
                );
              }

              return ListView.builder(
                itemCount: controller.conversionTasks.length,
                itemBuilder: (context, index) {
                  final task = controller.conversionTasks[index];
                  return _buildTaskItem(task);
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  // 任务项
  Widget _buildTaskItem(ConversionTask task) {
    final fileName = task.sourceFilePath.split('/').last;
    final statusText = _getStatusText(task.status);
    final statusColor = _getStatusColor(task.status);

    return Card(
      margin: EdgeInsets.only(bottom: 8.h),
      child: Padding(
        padding: EdgeInsets.all(12.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.video_file, color: AppColors.primary),
                SizedBox(width: 8.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        fileName,
                        style: AppTextStyles.bodyMedium,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        '${task.format.toUpperCase()} • ${task.resolution}',
                        style: AppTextStyles.bodySmall,
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4.r),
                  ),
                  child: Text(
                    statusText,
                    style: TextStyle(color: statusColor, fontSize: 12.sp),
                  ),
                ),
              ],
            ),
            if (task.status == ConversionStatus.converting || task.status == ConversionStatus.pending)
              Padding(
                padding: EdgeInsets.only(top: 8.h),
                child: LinearProgressIndicator(
                  value: task.progress,
                  backgroundColor: AppColors.border,
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                ),
              ),
            SizedBox(height: 8.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (task.status == ConversionStatus.completed)
                  TextButton.icon(
                    onPressed: () => controller.openFile(task.targetFilePath),
                    icon: const Icon(Icons.play_arrow),
                    label: const Text('播放'),
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.success,
                    ),
                  ),
                if (task.status == ConversionStatus.pending || task.status == ConversionStatus.converting)
                  TextButton.icon(
                    onPressed: () => controller.cancelTask(task.id),
                    icon: const Icon(Icons.cancel),
                    label: const Text('取消'),
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.error,
                    ),
                  ),
                TextButton.icon(
                  onPressed: () => controller.deleteTask(task.id),
                  icon: const Icon(Icons.delete),
                  label: const Text('删除'),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // 获取状态文本
  String _getStatusText(ConversionStatus status) {
    switch (status) {
      case ConversionStatus.pending:
        return '等待中';
      case ConversionStatus.converting:
        return '转换中';
      case ConversionStatus.completed:
        return '已完成';
      case ConversionStatus.failed:
        return '失败';
      case ConversionStatus.canceled:
        return '已取消';
    }
  }

  // 获取状态颜色
  Color _getStatusColor(ConversionStatus status) {
    switch (status) {
      case ConversionStatus.pending:
        return AppColors.warning;
      case ConversionStatus.converting:
        return AppColors.primary;
      case ConversionStatus.completed:
        return AppColors.success;
      case ConversionStatus.failed:
        return AppColors.error;
      case ConversionStatus.canceled:
        return AppColors.textSecondary;
    }
  }
}
