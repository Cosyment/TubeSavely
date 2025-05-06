import 'dart:convert';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../models/download_task_model.dart';
import '../models/user_model.dart';
import '../models/video_model.dart';
import '../../utils/constants.dart';

class StorageProvider extends GetxService {
  final _box = GetStorage();

  // 用户相关
  Future<void> saveUserToken(String token) async {
    await _box.write(Constants.STORAGE_USER_TOKEN, token);
  }

  String? getUserToken() {
    return _box.read<String>(Constants.STORAGE_USER_TOKEN);
  }

  Future<void> saveUserInfo(UserModel user) async {
    await _box.write(Constants.STORAGE_USER_INFO, jsonEncode(user.toJson()));
  }

  UserModel? getUserInfo() {
    final userJson = _box.read<String>(Constants.STORAGE_USER_INFO);
    if (userJson == null) return null;
    try {
      return UserModel.fromJson(jsonDecode(userJson));
    } catch (e) {
      return null;
    }
  }

  Future<void> clearUserData() async {
    await _box.remove(Constants.STORAGE_USER_TOKEN);
    await _box.remove(Constants.STORAGE_USER_INFO);
  }

  // 下载历史
  Future<void> saveDownloadHistory(List<VideoModel> videos) async {
    final List<Map<String, dynamic>> jsonList = videos.map((video) => video.toJson()).toList();
    await _box.write(Constants.STORAGE_DOWNLOAD_HISTORY, jsonEncode(jsonList));
  }

  Future<void> addToDownloadHistory(VideoModel video) async {
    final List<VideoModel> history = getDownloadHistory();
    // 检查是否已存在相同URL的视频
    if (!history.any((v) => v.url == video.url)) {
      history.add(video);
      await saveDownloadHistory(history);
    }
  }

  List<VideoModel> getDownloadHistory() {
    final historyJson = _box.read<String>(Constants.STORAGE_DOWNLOAD_HISTORY);
    if (historyJson == null) return [];
    try {
      final List<dynamic> jsonList = jsonDecode(historyJson);
      return jsonList.map((json) => VideoModel.fromJson(json)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<void> clearDownloadHistory() async {
    await _box.remove(Constants.STORAGE_DOWNLOAD_HISTORY);
  }

  // 下载任务
  Future<void> saveDownloadTasks(List<DownloadTaskModel> tasks) async {
    final List<Map<String, dynamic>> jsonList = tasks.map((task) => task.toJson()).toList();
    await _box.write(Constants.STORAGE_DOWNLOAD_TASKS, jsonEncode(jsonList));
  }

  Future<void> addDownloadTask(DownloadTaskModel task) async {
    final List<DownloadTaskModel> tasks = getDownloadTasks();
    tasks.add(task);
    await saveDownloadTasks(tasks);
  }

  Future<void> updateDownloadTask(DownloadTaskModel task) async {
    final List<DownloadTaskModel> tasks = getDownloadTasks();
    final index = tasks.indexWhere((t) => t.id == task.id);
    if (index != -1) {
      tasks[index] = task;
      await saveDownloadTasks(tasks);
    }
  }

  Future<void> removeDownloadTask(String taskId) async {
    final List<DownloadTaskModel> tasks = getDownloadTasks();
    tasks.removeWhere((task) => task.id == taskId);
    await saveDownloadTasks(tasks);
  }

  List<DownloadTaskModel> getDownloadTasks() {
    final tasksJson = _box.read<String>(Constants.STORAGE_DOWNLOAD_TASKS);
    if (tasksJson == null) return [];
    try {
      final List<dynamic> jsonList = jsonDecode(tasksJson);
      return jsonList.map((json) => DownloadTaskModel.fromJson(json)).toList();
    } catch (e) {
      return [];
    }
  }

  // 应用设置
  Future<void> saveSetting(String key, dynamic value) async {
    final Map<String, dynamic> settings = getSettings();
    settings[key] = value;
    await _box.write(Constants.STORAGE_SETTINGS, jsonEncode(settings));
  }

  dynamic getSetting(String key, {dynamic defaultValue}) {
    final settings = getSettings();
    return settings[key] ?? defaultValue;
  }

  Map<String, dynamic> getSettings() {
    final settingsJson = _box.read<String>(Constants.STORAGE_SETTINGS);
    if (settingsJson == null) return {};
    try {
      return jsonDecode(settingsJson);
    } catch (e) {
      return {};
    }
  }

  // 通用方法
  Future<void> saveData(String key, dynamic value) async {
    await _box.write(key, value);
  }

  dynamic getData(String key, {dynamic defaultValue}) {
    return _box.read(key) ?? defaultValue;
  }

  Future<void> removeData(String key) async {
    await _box.remove(key);
  }

  Future<void> clearAll() async {
    await _box.erase();
  }
}
