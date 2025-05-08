import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../controllers/main_controller.dart';
import '../../../theme/app_colors.dart';

class MainView extends GetView<MainController> {
  const MainView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(() => controller.pages[controller.currentIndex.value]),
      bottomNavigationBar: Obx(() => _buildBottomNavigationBar()),
    );
  }

  // 底部导航栏
  Widget _buildBottomNavigationBar() {
    return BottomNavigationBar(
      currentIndex: controller.currentIndex.value,
      onTap: controller.changePage,
      type: BottomNavigationBarType.fixed,
      backgroundColor: Get.theme.colorScheme.surface,
      selectedItemColor: AppColors.primary,
      unselectedItemColor: AppColors.textSecondary,
      selectedLabelStyle: TextStyle(
        fontSize: 12.sp,
        fontWeight: FontWeight.bold,
      ),
      unselectedLabelStyle: TextStyle(
        fontSize: 12.sp,
      ),
      items: [
        _buildBottomNavigationBarItem(
          icon: Icons.home_outlined,
          activeIcon: Icons.home,
          label: '首页',
        ),
        _buildBottomNavigationBarItem(
          icon: Icons.history_outlined,
          activeIcon: Icons.history,
          label: '历史',
        ),
        _buildBottomNavigationBarItem(
          icon: Icons.download_outlined,
          activeIcon: Icons.download,
          label: '任务',
        ),
        _buildBottomNavigationBarItem(
          icon: Icons.more_horiz_outlined,
          activeIcon: Icons.more_horiz,
          label: '更多',
        ),
      ],
    );
  }

  // 底部导航栏项
  BottomNavigationBarItem _buildBottomNavigationBarItem({
    required IconData icon,
    required IconData activeIcon,
    required String label,
  }) {
    return BottomNavigationBarItem(
      icon: Icon(icon),
      activeIcon: Icon(activeIcon),
      label: label,
    );
  }
}
