import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
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
    // 显示忘记密码对话框
    Get.dialog(
      AlertDialog(
        title: const Text('忘记密码'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('请输入您的注册邮箱，我们将向您发送重置密码的链接'),
            const SizedBox(height: 16),
            TextField(
              controller: emailController,
              decoration: const InputDecoration(
                labelText: '邮箱',
                hintText: '请输入您的邮箱',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () => _sendResetPasswordEmail(),
            child: const Text('发送'),
          ),
        ],
      ),
    );
  }

  /// 发送重置密码邮件
  Future<void> _sendResetPasswordEmail() async {
    try {
      // 验证邮箱
      if (emailController.text.isEmpty) {
        Utils.showSnackbar('错误', '请输入邮箱', isError: true);
        return;
      }

      if (!GetUtils.isEmail(emailController.text)) {
        Utils.showSnackbar('错误', '请输入有效的邮箱', isError: true);
        return;
      }

      // 关闭对话框
      Get.back();

      // 显示加载中
      isLoading.value = true;

      // 调用API发送重置密码邮件
      final success =
          await _userService.sendResetPasswordEmail(emailController.text);

      if (success) {
        Utils.showSnackbar('成功', '重置密码邮件已发送，请查收');
      } else {
        Utils.showSnackbar('错误', '发送重置密码邮件失败，请稍后重试', isError: true);
      }
    } catch (e) {
      Logger.e('Send reset password email error: $e');
      Utils.showSnackbar('错误', '发送重置密码邮件时出错: $e', isError: true);
    } finally {
      isLoading.value = false;
    }
  }

  /// 第三方登录 - Google
  void loginWithGoogle() {
    // TODO: 实现Google登录
    Utils.showSnackbar('提示', 'Google登录功能尚未实现');
  }

  /// 第三方登录 - Apple
  Future<void> loginWithApple() async {
    try {
      isLoading.value = true;

      // 检查是否支持 Apple 登录
      final isAvailable = await SignInWithApple.isAvailable();
      if (!isAvailable && Platform.isIOS) {
        Utils.showSnackbar('错误', '您的设备不支持 Apple 登录', isError: true);
        return;
      }

      // 获取 Apple 登录凭证
      final credential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
        // 为 Android 设备提供 webAuthenticationOptions
        webAuthenticationOptions: Platform.isAndroid
            ? WebAuthenticationOptions(
                clientId: 'com.xhx.tubesavely.service',
                redirectUri: Uri.parse(
                  'https://tubesavely-app.firebaseapp.com/__/auth/handler',
                ),
              )
            : null,
      );

      // 获取用户信息
      final String? email = credential.email;
      final String? givenName = credential.givenName;
      final String? familyName = credential.familyName;
      final String? identityToken = credential.identityToken;

      // 如果没有获取到 identityToken，则登录失败
      if (identityToken == null) {
        Utils.showSnackbar('错误', 'Apple 登录失败，请稍后重试', isError: true);
        return;
      }

      // 构建用户名
      String? name;
      if (givenName != null || familyName != null) {
        name = [givenName, familyName].where((n) => n != null).join(' ');
      }

      // 调用服务进行登录
      final success = await _userService.loginWithApple(
        identityToken: identityToken,
        email: email,
        name: name,
      );

      if (success) {
        Utils.showSnackbar('成功', 'Apple 登录成功');

        // 跳转到首页
        Get.offAllNamed('/home');
      } else {
        Utils.showSnackbar('错误', 'Apple 登录失败，请稍后重试', isError: true);
      }
    } catch (e) {
      Logger.e('Apple login error: $e');
      Utils.showSnackbar('错误', 'Apple 登录时出错: $e', isError: true);
    } finally {
      isLoading.value = false;
    }
  }

  /// 返回
  void goBack() {
    Get.back();
  }
}
