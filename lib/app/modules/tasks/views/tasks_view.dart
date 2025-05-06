import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../controllers/tasks_controller.dart';
import '../../../theme/app_theme.dart';
import '../../../data/models/download_task_model.dart';

class TasksView extends GetView<TasksController> {
  const TasksView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '下载任务',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        actions: [
          Obx(() {
            if (controller.isEditing.value) {
              return Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.select_all),
                    onPressed: controller.selectAll,
                  ),
                  IconButton(
                    icon: Icon(Icons.delete),
                    onPressed: controller.selectedItems.isNotEmpty
                        ? controller.deleteSelected
                        : null,
                  ),
                ],
              );
            } else {
              return IconButton(
                icon: Icon(Icons.edit),
                onPressed: controller.toggleEditMode,
              );
            }
          }),
        ],
      ),
      body: Column(
        children: [
          _buildTaskStats(),
          Expanded(
            child: _buildTaskList(),
          ),
        ],
      ),
      floatingActionButton: Obx(() {
        if (controller.isEditing.value) {
          return FloatingActionButton(
            onPressed: controller.toggleEditMode,
            backgroundColor: AppTheme.primaryColor,
            child: Icon(Icons.check),
          );
        } else {
          return SizedBox.shrink();
        }
      }),
    );
  }

  // 任务统计
  Widget _buildTaskStats() {
    return Obx(() {
      return Container(
        padding: EdgeInsets.all(16.w),
        child: Row(
          children: [
            Expanded(
              child: _buildStatCard(
                title: '下载中',
                count: controller.downloadingTasksCount,
                icon: Icons.download_rounded,
                color: AppTheme.primaryColor,
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: _buildStatCard(
                title: '已完成',
                count: controller.completedTasksCount,
                icon: Icons.check_circle,
                color: AppTheme.successColor,
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: _buildStatCard(
                title: '失败',
                count: controller.failedTasksCount,
                icon: Icons.error,
                color: AppTheme.errorColor,
              ),
            ),
          ],
        ),
      );
    });
  }

  // 统计卡片
  Widget _buildStatCard({
    required String title,
    required int count,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Get.theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: color,
            size: 24.sp,
          ),
          SizedBox(height: 8.h),
          Text(
            count.toString(),
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            title,
            style: TextStyle(
              fontSize: 12.sp,
              color: Get.theme.colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  // 任务列表
  Widget _buildTaskList() {
    return Obx(() {
      if (controller.isLoading.value) {
        return Center(
          child: CircularProgressIndicator(),
        );
      }

      if (controller.downloadTasks.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.download_done,
                size: 64.sp,
                color: Get.theme.colorScheme.onBackground.withOpacity(0.3),
              ),
              SizedBox(height: 16.h),
              Text(
                '暂无下载任务',
                style: TextStyle(
                  fontSize: 16.sp,
                  color: Get.theme.colorScheme.onBackground.withOpacity(0.5),
                ),
              ),
            ],
          ),
        );
      }

      return ListView.builder(
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        itemCount: controller.downloadTasks.length,
        itemBuilder: (context, index) {
          final task = controller.downloadTasks[index];
          return _buildTaskItem(task);
        },
      );
    });
  }

  // 任务项
  Widget _buildTaskItem(DownloadTaskModel task) {
    return Obx(() {
      final isSelected = controller.isSelected(task);
      
      return Card(
        margin: EdgeInsets.only(bottom: 12.h),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r),
          side: BorderSide(
            color: isSelected
                ? AppTheme.primaryColor
                : Get.theme.colorScheme.onSurface.withOpacity(0.1),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: InkWell(
          onTap: controller.isEditing.value
              ? () => controller.toggleSelectItem(task)
              : null,
          borderRadius: BorderRadius.circular(12.r),
          child: Padding(
            padding: EdgeInsets.all(12.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 缩略图
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8.r),
                      child: task.thumbnail != null
                          ? CachedNetworkImage(
                              imageUrl: task.thumbnail!,
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
                            )
                          : Container(
                              width: 80.w,
                              height: 60.h,
                              color: Colors.grey[300],
                              child: Icon(
                                Icons.video_library,
                                color: Colors.grey[500],
                              ),
                            ),
                    ),
                    SizedBox(width: 12.w),
                    // 任务信息
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            task.title,
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w500,
                              color: Get.theme.colorScheme.onSurface,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: 4.h),
                          Row(
                            children: [
                              _buildStatusBadge(task.status),
                              SizedBox(width: 8.w),
                              if (task.platform != null) ...[
                                Icon(
                                  Icons.videocam,
                                  size: 14.sp,
                                  color: Get.theme.colorScheme.onSurface.withOpacity(0.6),
                                ),
                                SizedBox(width: 4.w),
                                Text(
                                  task.platform!,
                                  style: TextStyle(
                                    fontSize: 12.sp,
                                    color: Get.theme.colorScheme.onSurface.withOpacity(0.6),
                                  ),
                                ),
                              ],
                            ],
                          ),
                          SizedBox(height: 4.h),
                          if (task.quality != null || task.format != null)
                            Text(
                              '${task.quality ?? ''} ${task.format ?? ''}',
                              style: TextStyle(
                                fontSize: 12.sp,
                                color: Get.theme.colorScheme.onSurface.withOpacity(0.6),
                              ),
                            ),
                        ],
                      ),
                    ),
                    // 选择指示器或操作按钮
                    if (controller.isEditing.value)
                      Padding(
                        padding: EdgeInsets.only(left: 8.w),
                        child: Icon(
                          isSelected
                              ? Icons.check_circle
                              : Icons.radio_button_unchecked,
                          color: isSelected
                              ? AppTheme.primaryColor
                              : Get.theme.colorScheme.onSurface.withOpacity(0.3),
                          size: 24.sp,
                        ),
                      )
                    else
                      _buildTaskActions(task),
                  ],
                ),
                SizedBox(height: 8.h),
                // 进度条
                if (task.status == DownloadStatus.downloading ||
                    task.status == DownloadStatus.paused)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      LinearProgressIndicator(
                        value: task.progress,
                        backgroundColor: Colors.grey[300],
                        valueColor: AlwaysStoppedAnimation<Color>(
                          task.status == DownloadStatus.paused
                              ? Colors.grey
                              : AppTheme.primaryColor,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            task.progressText,
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: Get.theme.colorScheme.onSurface.withOpacity(0.6),
                            ),
                          ),
                          Text(
                            '${task.formattedDownloadedBytes} / ${task.formattedTotalBytes}',
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: Get.theme.colorScheme.onSurface.withOpacity(0.6),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ),
      );
    });
  }

  // 状态标签
  Widget _buildStatusBadge(DownloadStatus status) {
    Color color;
    String text = status.toString().split('.').last;
    
    switch (status) {
      case DownloadStatus.downloading:
        color = AppTheme.primaryColor;
        text = '下载中';
        break;
      case DownloadStatus.pending:
        color = Colors.blue;
        text = '等待中';
        break;
      case DownloadStatus.paused:
        color = Colors.orange;
        text = '已暂停';
        break;
      case DownloadStatus.completed:
        color = AppTheme.successColor;
        text = '已完成';
        break;
      case DownloadStatus.failed:
        color = AppTheme.errorColor;
        text = '下载失败';
        break;
      case DownloadStatus.canceled:
        color = Colors.grey;
        text = '已取消';
        break;
    }
    
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4.r),
        border: Border.all(color: color, width: 1),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 10.sp,
          color: color,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  // 任务操作按钮
  Widget _buildTaskActions(DownloadTaskModel task) {
    switch (task.status) {
      case DownloadStatus.downloading:
        return IconButton(
          icon: Icon(
            Icons.pause,
            size: 20.sp,
            color: AppTheme.primaryColor,
          ),
          onPressed: () => controller.pauseTask(task.id),
        );
      case DownloadStatus.paused:
        return IconButton(
          icon: Icon(
            Icons.play_arrow,
            size: 20.sp,
            color: AppTheme.primaryColor,
          ),
          onPressed: () => controller.resumeTask(task.id),
        );
      case DownloadStatus.pending:
        return IconButton(
          icon: Icon(
            Icons.cancel,
            size: 20.sp,
            color: AppTheme.warningColor,
          ),
          onPressed: () => controller.cancelTask(task.id),
        );
      case DownloadStatus.completed:
      case DownloadStatus.failed:
      case DownloadStatus.canceled:
        return IconButton(
          icon: Icon(
            Icons.delete,
            size: 20.sp,
            color: AppTheme.errorColor,
          ),
          onPressed: () => _showDeleteConfirmation(task),
        );
    }
  }

  // 显示删除确认对话框
  void _showDeleteConfirmation(DownloadTaskModel task) {
    Get.dialog(
      AlertDialog(
        title: Text('删除任务'),
        content: Text('确定要删除此下载任务吗？'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('取消'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              controller.deleteTask(task.id);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
            ),
            child: Text('确定'),
          ),
        ],
      ),
    );
  }
}
