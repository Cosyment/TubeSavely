import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/models/user_model.dart';
import '../../../services/user_service.dart';
import '../../../utils/logger.dart';
import '../../../utils/utils.dart';
import '../../../data/providers/api_provider.dart';

/// 开发者测试页面控制器
class DeveloperController extends GetxController {
  final UserService _userService = Get.find<UserService>();
  final ApiProvider _apiProvider = Get.find<ApiProvider>();

  // API测试相关
  final TextEditingController apiUrlController = TextEditingController();
  final TextEditingController apiParamsController = TextEditingController();
  final RxString apiResponse = ''.obs;
  final RxBool isApiLoading = false.obs;
  final RxString selectedMethod = 'GET'.obs;
  final List<String> httpMethods = ['GET', 'POST', 'PUT', 'DELETE'];

  // 登录测试相关
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final RxBool isLoginLoading = false.obs;

  // 模拟登录相关
  final TextEditingController mockNameController = TextEditingController();
  final TextEditingController mockEmailController = TextEditingController();
  final TextEditingController mockIdController = TextEditingController();
  final RxInt mockUserLevel = 0.obs;
  final RxInt mockUserPoints = 0.obs;
  final Rx<DateTime?> mockMembershipExpiry = Rx<DateTime?>(null);

  // 高级用户测试相关
  final RxBool isPremiumUser = false.obs;
  final RxBool isProUser = false.obs;

  // 当前用户信息
  final Rx<UserModel?> currentUser = Rx<UserModel?>(null);
  final RxBool isLoggedIn = false.obs;

  @override
  void onInit() {
    super.onInit();
    Logger.d('DeveloperController initialized');

    // 初始化API测试表单
    apiUrlController.text = '/parse';
    apiParamsController.text = '{"url": "https://www.youtube.com/watch?v=dQw4w9WgXcQ"}';

    // 初始化模拟用户信息
    mockNameController.text = 'Test User';
    mockEmailController.text = 'test@example.com';
    mockIdController.text = 'test123';
    mockUserLevel.value = 0;
    mockUserPoints.value = 100;
    mockMembershipExpiry.value = DateTime.now().add(const Duration(days: 30));

    // 监听登录状态
    ever(_userService.isLoggedIn, (isLoggedIn) {
      this.isLoggedIn.value = isLoggedIn;
      if (isLoggedIn) {
        _loadUserInfo();
      } else {
        currentUser.value = null;
      }
    });

    // 监听用户信息
    ever(_userService.currentUser, (user) {
      currentUser.value = user;
      if (user != null) {
        isPremiumUser.value = user.isPremium;
        isProUser.value = user.isPro;
      }
    });

    // 初始化
    isLoggedIn.value = _userService.isLoggedIn.value;
    currentUser.value = _userService.currentUser.value;
  }

  @override
  void onClose() {
    // 释放资源
    apiUrlController.dispose();
    apiParamsController.dispose();
    emailController.dispose();
    passwordController.dispose();
    mockNameController.dispose();
    mockEmailController.dispose();
    mockIdController.dispose();
    super.onClose();
  }

  /// 加载用户信息
  Future<void> _loadUserInfo() async {
    try {
      await _userService.getUserInfo();
    } catch (e) {
      Logger.e('Load user info error: $e');
    }
  }

  /// 发送API请求
  Future<void> sendApiRequest() async {
    try {
      isApiLoading.value = true;
      apiResponse.value = '';

      final url = apiUrlController.text.trim();
      if (url.isEmpty) {
        Utils.showSnackbar('错误', 'API路径不能为空', isError: true);
        return;
      }

      // 解析参数
      Map<String, dynamic>? params;
      if (apiParamsController.text.isNotEmpty) {
        try {
          params = json.decode(apiParamsController.text);
        } catch (e) {
          Utils.showSnackbar('错误', '参数格式错误: $e', isError: true);
          return;
        }
      }

      // 发送请求
      Response response;
      switch (selectedMethod.value) {
        case 'GET':
          response = await _apiProvider.get(url, query: params);
          break;
        case 'POST':
          response = await _apiProvider.post(url, params);
          break;
        case 'PUT':
          response = await _apiProvider.put(url, params);
          break;
        case 'DELETE':
          response = await _apiProvider.delete(url, query: params);
          break;
        default:
          response = await _apiProvider.get(url, query: params);
      }

      // 格式化响应
      final prettyResponse = _formatResponse(response);
      apiResponse.value = prettyResponse;
    } catch (e) {
      Logger.e('API request error: $e');
      apiResponse.value = 'Error: $e';
    } finally {
      isApiLoading.value = false;
    }
  }

  /// 格式化API响应
  String _formatResponse(Response response) {
    try {
      final buffer = StringBuffer();
      buffer.writeln('Status: ${response.statusCode} ${response.statusText}');
      buffer.writeln('Headers: ${response.headers}');
      buffer.writeln('Body:');

      if (response.body != null) {
        if (response.body is Map || response.body is List) {
          final encoder = JsonEncoder.withIndent('  ');
          buffer.writeln(encoder.convert(response.body));
        } else {
          buffer.writeln(response.body.toString());
        }
      } else {
        buffer.writeln('null');
      }

      return buffer.toString();
    } catch (e) {
      return 'Error formatting response: $e\nRaw response: ${response.body}';
    }
  }

  /// API登录
  Future<void> apiLogin() async {
    try {
      isLoginLoading.value = true;

      final email = emailController.text.trim();
      final password = passwordController.text;

      if (email.isEmpty || password.isEmpty) {
        Utils.showSnackbar('错误', '邮箱和密码不能为空', isError: true);
        return;
      }

      final success = await _userService.login(email, password);

      if (success) {
        Utils.showSnackbar('成功', 'API登录成功');
      } else {
        Utils.showSnackbar('错误', 'API登录失败，请检查邮箱和密码', isError: true);
      }
    } catch (e) {
      Logger.e('API login error: $e');
      Utils.showSnackbar('错误', 'API登录时出错: $e', isError: true);
    } finally {
      isLoginLoading.value = false;
    }
  }

  /// 模拟登录
  void mockLogin() {
    try {
      // 创建模拟用户
      final user = UserModel(
        id: mockIdController.text.trim(),
        name: mockNameController.text.trim(),
        email: mockEmailController.text.trim(),
        level: mockUserLevel.value,
        points: mockUserPoints.value,
        membershipExpiry: mockMembershipExpiry.value,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // 更新用户服务中的用户信息
      _userService.mockLogin(user);

      Utils.showSnackbar('成功', '模拟登录成功');
    } catch (e) {
      Logger.e('Mock login error: $e');
      Utils.showSnackbar('错误', '模拟登录时出错: $e', isError: true);
    }
  }

  /// 退出登录
  Future<void> logout() async {
    try {
      await _userService.logout();
      Utils.showSnackbar('成功', '已退出登录');
    } catch (e) {
      Logger.e('Logout error: $e');
      Utils.showSnackbar('错误', '退出登录时出错: $e', isError: true);
    }
  }

  /// 切换高级用户状态
  void togglePremiumUser() {
    if (!isLoggedIn.value || currentUser.value == null) {
      Utils.showSnackbar('错误', '请先登录', isError: true);
      return;
    }

    try {
      final user = currentUser.value!;
      final newLevel = isPremiumUser.value ? 0 : 1;
      
      // 更新用户等级
      final updatedUser = user.copyWith(level: newLevel);
      
      // 更新用户服务中的用户信息
      _userService.mockUpdateUser(updatedUser);
      
      isPremiumUser.value = !isPremiumUser.value;
      Utils.showSnackbar('成功', isPremiumUser.value ? '已切换为高级用户' : '已切换为普通用户');
    } catch (e) {
      Logger.e('Toggle premium user error: $e');
      Utils.showSnackbar('错误', '切换高级用户状态时出错: $e', isError: true);
    }
  }

  /// 切换专业用户状态
  void toggleProUser() {
    if (!isLoggedIn.value || currentUser.value == null) {
      Utils.showSnackbar('错误', '请先登录', isError: true);
      return;
    }

    try {
      final user = currentUser.value!;
      final newLevel = isProUser.value ? 1 : 2; // 如果是专业用户，降级为高级用户，否则升级为专业用户
      
      // 更新用户等级
      final updatedUser = user.copyWith(level: newLevel);
      
      // 更新用户服务中的用户信息
      _userService.mockUpdateUser(updatedUser);
      
      isProUser.value = !isProUser.value;
      Utils.showSnackbar('成功', isProUser.value ? '已切换为专业用户' : '已切换为高级用户');
    } catch (e) {
      Logger.e('Toggle pro user error: $e');
      Utils.showSnackbar('错误', '切换专业用户状态时出错: $e', isError: true);
    }
  }
}
