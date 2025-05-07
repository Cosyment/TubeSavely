import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../services/user_service.dart';
import '../../../utils/logger.dart';
import '../../../utils/utils.dart';
// import '../../../routes/app_routes.dart';

/// 登录页面控制器
class LoginController extends GetxController {
  final UserService _userService = Get.find<UserService>();

  // 表单控制器
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController nameController = TextEditingController();

  // 表单焦点
  final FocusNode emailFocus = FocusNode();
  final FocusNode passwordFocus = FocusNode();
  final FocusNode nameFocus = FocusNode();

  // 是否显示密码
  final RxBool obscurePassword = true.obs;

  // 是否正在加载
  final RxBool isLoading = false.obs;

  // 是否是注册模式
  final RxBool isRegisterMode = false.obs;

  // 表单验证状态
  final RxBool isEmailValid = false.obs;
  final RxBool isPasswordValid = false.obs;
  final RxBool isNameValid = false.obs;

  @override
  void onInit() {
    super.onInit();
    Logger.d('LoginController initialized');

    // 添加监听器
    emailController.addListener(_validateEmail);
    passwordController.addListener(_validatePassword);
    nameController.addListener(_validateName);
  }

  @override
  void onClose() {
    // 释放资源
    emailController.dispose();
    passwordController.dispose();
    nameController.dispose();

    emailFocus.dispose();
    passwordFocus.dispose();
    nameFocus.dispose();

    super.onClose();
  }

  /// 切换密码可见性
  void togglePasswordVisibility() {
    obscurePassword.value = !obscurePassword.value;
  }

  /// 切换登录/注册模式
  void toggleMode() {
    isRegisterMode.value = !isRegisterMode.value;

    // 清空表单
    if (isRegisterMode.value) {
      // 保留邮箱，清空密码
      passwordController.clear();
    } else {
      // 清空名称
      nameController.clear();
    }
  }

  /// 验证邮箱
  void _validateEmail() {
    final email = emailController.text.trim();
    isEmailValid.value = GetUtils.isEmail(email);
  }

  /// 验证密码
  void _validatePassword() {
    final password = passwordController.text;
    isPasswordValid.value = password.length >= 6;
  }

  /// 验证名称
  void _validateName() {
    final name = nameController.text.trim();
    isNameValid.value = name.length >= 2;
  }

  /// 表单是否有效
  bool get isFormValid {
    if (isRegisterMode.value) {
      return isEmailValid.value && isPasswordValid.value && isNameValid.value;
    } else {
      return isEmailValid.value && isPasswordValid.value;
    }
  }

  /// 登录
  Future<void> login() async {
    if (!isFormValid) {
      Utils.showSnackbar('错误', '请填写正确的邮箱和密码', isError: true);
      return;
    }

    try {
      isLoading.value = true;

      final email = emailController.text.trim();
      final password = passwordController.text;

      final success = await _userService.login(email, password);

      if (success) {
        Utils.showSnackbar('成功', '登录成功');

        // 跳转到首页
        Get.offAllNamed('/home');
      } else {
        Utils.showSnackbar('错误', '登录失败，请检查邮箱和密码', isError: true);
      }
    } catch (e) {
      Logger.e('Login error: $e');
      Utils.showSnackbar('错误', '登录时出错: $e', isError: true);
    } finally {
      isLoading.value = false;
    }
  }

  /// 注册
  Future<void> register() async {
    if (!isFormValid) {
      Utils.showSnackbar('错误', '请填写正确的信息', isError: true);
      return;
    }

    try {
      isLoading.value = true;

      final email = emailController.text.trim();
      final password = passwordController.text;
      final name = nameController.text.trim();

      final success = await _userService.register(email, password, name);

      if (success) {
        Utils.showSnackbar('成功', '注册成功');

        // 跳转到首页
        Get.offAllNamed('/home');
      } else {
        Utils.showSnackbar('错误', '注册失败，请稍后重试', isError: true);
      }
    } catch (e) {
      Logger.e('Register error: $e');
      Utils.showSnackbar('错误', '注册时出错: $e', isError: true);
    } finally {
      isLoading.value = false;
    }
  }

  /// 忘记密码
  void forgotPassword() {
    // TODO: 实现忘记密码功能
    Utils.showSnackbar('提示', '忘记密码功能尚未实现');
  }

  /// 第三方登录 - Google
  void loginWithGoogle() {
    // TODO: 实现Google登录
    Utils.showSnackbar('提示', 'Google登录功能尚未实现');
  }

  /// 第三方登录 - Apple
  void loginWithApple() {
    // TODO: 实现Apple登录
    Utils.showSnackbar('提示', 'Apple登录功能尚未实现');
  }

  /// 返回
  void goBack() {
    Get.back();
  }
}
