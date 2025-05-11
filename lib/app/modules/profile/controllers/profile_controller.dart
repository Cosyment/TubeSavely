import 'package:get/get.dart';
import '../../../data/models/user_model.dart';
import '../../../services/user_service.dart';
import '../../../utils/logger.dart';
import '../../../utils/utils.dart';
// import '../../../routes/app_routes.dart';

/// 用户信息页面控制器
class ProfileController extends GetxController {
  final UserService _userService = Get.find<UserService>();

  // 当前用户
  final Rx<UserModel?> user = Rx<UserModel?>(null);

  // 是否已登录
  final RxBool isLoggedIn = false.obs;

  // 是否正在加载
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    Logger.d('ProfileController initialized');

    // 监听登录状态
    ever(_userService.isLoggedIn, (isLoggedIn) {
      this.isLoggedIn.value = isLoggedIn;
      if (isLoggedIn) {
        _loadUserInfo();
      } else {
        user.value = null;
      }
    });

    // 监听用户信息
    ever(_userService.currentUser, (user) {
      this.user.value = user;
    });

    // 初始化
    isLoggedIn.value = _userService.isLoggedIn.value;
    user.value = _userService.currentUser.value;

    // 如果已登录但没有用户信息，则加载用户信息
    if (isLoggedIn.value && user.value == null) {
      _loadUserInfo();
    }
  }

  /// 加载用户信息
  Future<void> _loadUserInfo() async {
    try {
      isLoading.value = true;
      await _userService.getUserInfo();
    } catch (e) {
      Logger.e('Load user info error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// 登录
  void login() {
    Get.toNamed('/login');
  }

  /// 退出登录
  Future<void> logout() async {
    try {
      isLoading.value = true;
      await _userService.logout();
      Utils.showSnackbar('成功', '已退出登录');
    } catch (e) {
      Logger.e('Logout error: $e');
      Utils.showSnackbar('错误', '退出登录时出错: $e', isError: true);
    } finally {
      isLoading.value = false;
    }
  }

  /// 刷新用户信息
  Future<void> refreshUserInfo() async {
    if (!isLoggedIn.value) return;

    try {
      isLoading.value = true;
      await _userService.getUserInfo();
      Utils.showSnackbar('成功', '已刷新用户信息');
    } catch (e) {
      Logger.e('Refresh user info error: $e');
      Utils.showSnackbar('错误', '刷新用户信息时出错: $e', isError: true);
    } finally {
      isLoading.value = false;
    }
  }

  /// 跳转到会员页面
  void goToMembership() {
    // 跳转到支付页面，并选择会员标签
    Get.toNamed('/payment', arguments: {'initialTab': 0});
  }

  /// 跳转到积分页面
  void goToPoints() {
    // 跳转到支付页面，并选择积分标签
    Get.toNamed('/payment', arguments: {'initialTab': 1});
  }

  /// 跳转到设置页面
  void goToSettings() {
    Get.toNamed('/settings');
  }

  /// 跳转到历史记录页面
  void goToHistory() {
    Get.toNamed('/history');
  }

  /// 跳转到下载任务页面
  void goToTasks() {
    Get.toNamed('/tasks');
  }

  /// 获取会员状态文本
  String getMembershipStatus() {
    if (user.value == null) return '未登录';

    if (user.value!.isPro && user.value!.isMembershipActive) {
      return '专业会员';
    } else if (user.value!.isPremium && user.value!.isMembershipActive) {
      return '高级会员';
    } else {
      return '免费用户';
    }
  }

  /// 获取会员到期时间
  String getMembershipExpiry() {
    if (user.value == null || user.value!.membershipExpiry == null) {
      return '无';
    }

    final expiry = user.value!.membershipExpiry!;
    return '${expiry.year}-${expiry.month.toString().padLeft(2, '0')}-${expiry.day.toString().padLeft(2, '0')}';
  }

  /// 获取注册时间
  String getRegistrationDate() {
    if (user.value == null || user.value!.createdAt == null) {
      return '未知';
    }

    final createdAt = user.value!.createdAt!;
    return '${createdAt.year}-${createdAt.month.toString().padLeft(2, '0')}-${createdAt.day.toString().padLeft(2, '0')}';
  }
}
