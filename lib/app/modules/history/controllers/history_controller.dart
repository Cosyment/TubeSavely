import 'package:get/get.dart';
import '../../../data/models/video_model.dart';
import '../../../data/repositories/video_repository.dart';
import '../../../routes/app_routes.dart';
import '../../../utils/utils.dart';
import '../../../utils/logger.dart';

class HistoryController extends GetxController {
  final VideoRepository _videoRepository = Get.find<VideoRepository>();
  
  // 历史记录列表
  final RxList<VideoModel> historyList = <VideoModel>[].obs;
  
  // 是否正在加载
  final RxBool isLoading = false.obs;
  
  // 是否正在编辑
  final RxBool isEditing = false.obs;
  
  // 选中的项目
  final RxList<String> selectedItems = <String>[].obs;
  
  @override
  void onInit() {
    super.onInit();
    Logger.d('HistoryController initialized');
    
    // 加载历史记录
    loadHistory();
  }
  
  // 加载历史记录
  void loadHistory() {
    try {
      isLoading.value = true;
      
      // 从本地存储获取历史记录
      final history = _videoRepository.getDownloadHistory();
      
      // 按时间倒序排序
      history.sort((a, b) {
        if (a.createdAt == null || b.createdAt == null) return 0;
        return b.createdAt!.compareTo(a.createdAt!);
      });
      
      historyList.value = history;
    } catch (e) {
      Logger.e('加载历史记录时出错: $e');
      Utils.showSnackbar('错误', '加载历史记录时出错: $e', isError: true);
    } finally {
      isLoading.value = false;
    }
  }
  
  // 清空历史记录
  Future<void> clearHistory() async {
    try {
      await _videoRepository.clearDownloadHistory();
      historyList.clear();
      Utils.showSnackbar('成功', '历史记录已清空');
    } catch (e) {
      Logger.e('清空历史记录时出错: $e');
      Utils.showSnackbar('错误', '清空历史记录时出错: $e', isError: true);
    }
  }
  
  // 查看视频详情
  void viewVideoDetail(VideoModel video) {
    if (isEditing.value) {
      toggleSelectItem(video);
    } else {
      Get.toNamed(Routes.VIDEO_DETAIL, arguments: video);
    }
  }
  
  // 切换编辑模式
  void toggleEditMode() {
    isEditing.value = !isEditing.value;
    if (!isEditing.value) {
      selectedItems.clear();
    }
  }
  
  // 切换选中状态
  void toggleSelectItem(VideoModel video) {
    final videoId = video.id ?? video.url;
    if (selectedItems.contains(videoId)) {
      selectedItems.remove(videoId);
    } else {
      selectedItems.add(videoId);
    }
  }
  
  // 是否选中
  bool isSelected(VideoModel video) {
    final videoId = video.id ?? video.url;
    return selectedItems.contains(videoId);
  }
  
  // 全选
  void selectAll() {
    if (selectedItems.length == historyList.length) {
      // 如果已经全选，则取消全选
      selectedItems.clear();
    } else {
      // 否则全选
      selectedItems.clear();
      for (var video in historyList) {
        final videoId = video.id ?? video.url;
        selectedItems.add(videoId);
      }
    }
  }
  
  // 删除选中项
  Future<void> deleteSelected() async {
    if (selectedItems.isEmpty) return;
    
    try {
      // 获取未选中的项目
      final remainingItems = historyList.where((video) {
        final videoId = video.id ?? video.url;
        return !selectedItems.contains(videoId);
      }).toList();
      
      // 保存剩余项目
      await _videoRepository.saveDownloadHistory(remainingItems);
      
      // 更新列表
      historyList.value = remainingItems;
      
      // 清空选中项
      selectedItems.clear();
      
      Utils.showSnackbar('成功', '已删除选中的历史记录');
    } catch (e) {
      Logger.e('删除历史记录时出错: $e');
      Utils.showSnackbar('错误', '删除历史记录时出错: $e', isError: true);
    }
  }
  
  // 搜索历史记录
  void searchHistory(String keyword) {
    if (keyword.isEmpty) {
      // 如果关键字为空，则加载所有历史记录
      loadHistory();
      return;
    }
    
    try {
      // 从本地存储获取所有历史记录
      final allHistory = _videoRepository.getDownloadHistory();
      
      // 过滤匹配的记录
      final filteredHistory = allHistory.where((video) {
        return video.title.toLowerCase().contains(keyword.toLowerCase()) ||
               (video.platform?.toLowerCase().contains(keyword.toLowerCase()) ?? false) ||
               (video.author?.toLowerCase().contains(keyword.toLowerCase()) ?? false);
      }).toList();
      
      // 按时间倒序排序
      filteredHistory.sort((a, b) {
        if (a.createdAt == null || b.createdAt == null) return 0;
        return b.createdAt!.compareTo(a.createdAt!);
      });
      
      historyList.value = filteredHistory;
    } catch (e) {
      Logger.e('搜索历史记录时出错: $e');
      Utils.showSnackbar('错误', '搜索历史记录时出错: $e', isError: true);
    }
  }
}
