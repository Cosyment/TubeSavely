import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../controllers/history_controller.dart';
import '../../../theme/app_theme.dart';
import '../../../data/models/video_model.dart';

class HistoryView extends GetView<HistoryController> {
  const HistoryView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '下载历史',
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
          _buildSearchBar(),
          Expanded(
            child: _buildHistoryList(),
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
          return FloatingActionButton(
            onPressed: _showClearHistoryConfirmation,
            backgroundColor: AppTheme.primaryColor,
            child: Icon(Icons.delete_sweep),
          );
        }
      }),
    );
  }

  // 搜索栏
  Widget _buildSearchBar() {
    return Container(
      padding: EdgeInsets.all(16.w),
      child: TextField(
        decoration: InputDecoration(
          hintText: '搜索历史记录...',
          prefixIcon: Icon(Icons.search),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.r),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Get.theme.colorScheme.surface,
          contentPadding: EdgeInsets.symmetric(
            horizontal: 16.w,
            vertical: 12.h,
          ),
        ),
        onChanged: controller.searchHistory,
      ),
    );
  }

  // 历史记录列表
  Widget _buildHistoryList() {
    return Obx(() {
      if (controller.isLoading.value) {
        return Center(
          child: CircularProgressIndicator(),
        );
      }

      if (controller.historyList.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.history,
                size: 64.sp,
                color: Get.theme.colorScheme.onBackground.withOpacity(0.3),
              ),
              SizedBox(height: 16.h),
              Text(
                '暂无下载历史',
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
        itemCount: controller.historyList.length,
        itemBuilder: (context, index) {
          final video = controller.historyList[index];
          return _buildHistoryItem(video);
        },
      );
    });
  }

  // 历史记录项
  Widget _buildHistoryItem(VideoModel video) {
    return Obx(() {
      final isSelected = controller.isSelected(video);
      
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
          onTap: () => controller.viewVideoDetail(video),
          borderRadius: BorderRadius.circular(12.r),
          child: Padding(
            padding: EdgeInsets.all(12.w),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 缩略图
                ClipRRect(
                  borderRadius: BorderRadius.circular(8.r),
                  child: video.thumbnail != null
                      ? CachedNetworkImage(
                          imageUrl: video.thumbnail!,
                          width: 100.w,
                          height: 70.h,
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
                          width: 100.w,
                          height: 70.h,
                          color: Colors.grey[300],
                          child: Icon(
                            Icons.video_library,
                            color: Colors.grey[500],
                          ),
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
                      Row(
                        children: [
                          Icon(
                            Icons.videocam,
                            size: 14.sp,
                            color: Get.theme.colorScheme.onSurface.withOpacity(0.6),
                          ),
                          SizedBox(width: 4.w),
                          Text(
                            video.platform ?? '未知平台',
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: Get.theme.colorScheme.onSurface.withOpacity(0.6),
                            ),
                          ),
                          SizedBox(width: 8.w),
                          Icon(
                            Icons.access_time,
                            size: 14.sp,
                            color: Get.theme.colorScheme.onSurface.withOpacity(0.6),
                          ),
                          SizedBox(width: 4.w),
                          Text(
                            video.formattedDuration,
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: Get.theme.colorScheme.onSurface.withOpacity(0.6),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 4.h),
                      if (video.createdAt != null)
                        Text(
                          '添加时间: ${_formatDateTime(video.createdAt!)}',
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: Get.theme.colorScheme.onSurface.withOpacity(0.6),
                          ),
                        ),
                    ],
                  ),
                ),
                // 选择指示器
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
                  ),
              ],
            ),
          ),
        ),
      );
    });
  }

  // 格式化日期时间
  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    
    if (difference.inDays > 365) {
      return '${(difference.inDays / 365).floor()}年前';
    } else if (difference.inDays > 30) {
      return '${(difference.inDays / 30).floor()}个月前';
    } else if (difference.inDays > 0) {
      return '${difference.inDays}天前';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}小时前';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}分钟前';
    } else {
      return '刚刚';
    }
  }

  // 显示清空历史记录确认对话框
  void _showClearHistoryConfirmation() {
    Get.dialog(
      AlertDialog(
        title: Text('清空历史记录'),
        content: Text('确定要清空所有下载历史记录吗？'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('取消'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              controller.clearHistory();
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
