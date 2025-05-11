import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../home/views/home_view.dart';
import '../../history/views/history_view.dart';
import '../../tasks/views/tasks_view.dart';
import '../../profile/views/profile_view.dart';

class MainController extends GetxController {
  // 当前选中的标签页索引
  final RxInt currentIndex = 0.obs;

  // 页面列表
  final List<Widget> pages = [
    const HomeView(),
    const HistoryView(),
    const TasksView(),
    const ProfileView(),
  ];

  // 切换标签页
  void changePage(int index) {
    currentIndex.value = index;
  }
}
