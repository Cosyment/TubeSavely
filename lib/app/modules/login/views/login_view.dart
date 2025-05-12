import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_text_styles.dart';
import '../controllers/login_controller.dart';

/// 登录页面
class LoginView extends GetView<LoginController> {
  const LoginView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: Container(
            child: Center(
              child: SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24.w),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildHeader(),
                      SizedBox(height: 40.h),
                      _buildForm(),
                      SizedBox(height: 24.h),
                      _buildActionButton(),
                      SizedBox(height: 16.h),
                      _buildToggleModeButton(),
                      SizedBox(height: 32.h),
                      _buildSocialLogin(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// 构建页面头部
  Widget _buildHeader() {
    return Column(
      children: [
        // Logo
        Container(
          width: 100.w,
          height: 100.w,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(26),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Center(
            child: Image.asset(
              'assets/images/ic_logo.png',
              width: 60.w,
              height: 60.w,
            ),
          ),
        ),
        SizedBox(height: 16.h),
        // 标题
        Text(
          'TubeSavely',
          style: AppTextStyles.headlineLarge.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 8.h),
        // 副标题
        Obx(() {
          return Text(
            controller.isRegisterMode.value ? '创建新账号' : '欢迎回来',
            style: AppTextStyles.titleMedium.copyWith(
              color: Colors.white.withAlpha(204),
            ),
          );
        }),
      ],
    );
  }

  /// 构建表单
  Widget _buildForm() {
    return Obx(() {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 名称输入框（仅注册模式显示）
          if (controller.isRegisterMode.value) ...[
            _buildInputLabel('用户名'),
            SizedBox(height: 8.h),
            _buildTextField(
              controller: controller.nameController,
              focusNode: controller.nameFocus,
              hintText: '请输入用户名',
              prefixIcon: Icons.person,
              textInputAction: TextInputAction.next,
              onSubmitted: (_) => controller.emailFocus.requestFocus(),
            ),
            SizedBox(height: 16.h),
          ],

          // 邮箱输入框
          _buildInputLabel('邮箱'),
          SizedBox(height: 8.h),
          _buildTextField(
            controller: controller.emailController,
            focusNode: controller.emailFocus,
            hintText: '请输入邮箱',
            prefixIcon: Icons.email,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            onSubmitted: (_) => controller.passwordFocus.requestFocus(),
          ),
          SizedBox(height: 16.h),

          // 密码输入框
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildInputLabel('密码'),
              if (!controller.isRegisterMode.value)
                GestureDetector(
                  onTap: controller.forgotPassword,
                  child: Text(
                    '忘记密码?',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: Colors.white.withAlpha(204),
                    ),
                  ),
                ),
            ],
          ),
          SizedBox(height: 8.h),
          _buildTextField(
            controller: controller.passwordController,
            focusNode: controller.passwordFocus,
            hintText: '请输入密码',
            prefixIcon: Icons.lock,
            obscureText: controller.obscurePassword.value,
            textInputAction: controller.isRegisterMode.value
                ? TextInputAction.done
                : TextInputAction.done,
            onSubmitted: (_) {
              if (controller.isRegisterMode.value) {
                controller.register();
              } else {
                controller.login();
              }
            },
            suffixIcon: IconButton(
              icon: Icon(
                controller.obscurePassword.value
                    ? Icons.visibility
                    : Icons.visibility_off,
                color: Colors.white.withAlpha(204),
              ),
              onPressed: controller.togglePasswordVisibility,
            ),
          ),
        ],
      );
    });
  }

  /// 构建输入框标签
  Widget _buildInputLabel(String label) {
    return Text(
      label,
      style: AppTextStyles.bodyMedium.copyWith(
        color: Colors.white.withAlpha(204),
      ),
    );
  }

  /// 构建输入框
  Widget _buildTextField({
    required TextEditingController controller,
    required FocusNode focusNode,
    required String hintText,
    required IconData prefixIcon,
    TextInputType keyboardType = TextInputType.text,
    TextInputAction textInputAction = TextInputAction.next,
    bool obscureText = false,
    Widget? suffixIcon,
    Function(String)? onSubmitted,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(26),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        style: AppTextStyles.bodyMedium.copyWith(color: Colors.white),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: AppTextStyles.bodyMedium.copyWith(
            color: Colors.white.withAlpha(128),
          ),
          prefixIcon: Icon(
            prefixIcon,
            color: Colors.white.withAlpha(204),
          ),
          suffixIcon: suffixIcon,
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(
            horizontal: 16.w,
            vertical: 16.h,
          ),
        ),
        keyboardType: keyboardType,
        textInputAction: textInputAction,
        obscureText: obscureText,
        onSubmitted: onSubmitted,
      ),
    );
  }

  /// 构建操作按钮
  Widget _buildActionButton() {
    return Obx(() {
      return ElevatedButton(
        onPressed: controller.isLoading.value
            ? null
            : () {
                if (controller.isRegisterMode.value) {
                  controller.register();
                } else {
                  controller.login();
                }
              },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: AppColors.primary,
          padding: EdgeInsets.symmetric(vertical: 16.h),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
          elevation: 0,
        ),
        child: controller.isLoading.value
            ? SizedBox(
                width: 24.w,
                height: 24.w,
                child: CircularProgressIndicator(
                  strokeWidth: 2.w,
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                ),
              )
            : Text(
                controller.isRegisterMode.value ? '注册' : '登录',
                style: AppTextStyles.titleMedium.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
      );
    });
  }

  /// 构建切换模式按钮
  Widget _buildToggleModeButton() {
    return Obx(() {
      return TextButton(
        onPressed: controller.toggleMode,
        child: Text(
          controller.isRegisterMode.value ? '已有账号? 登录' : '没有账号? 注册',
          style: AppTextStyles.bodyMedium.copyWith(
            color: Colors.white,
          ),
        ),
      );
    });
  }

  /// 构建社交登录
  Widget _buildSocialLogin() {
    return Column(
      children: [
        Text(
          '或者使用以下方式登录',
          style: AppTextStyles.bodySmall.copyWith(
            color: Colors.white.withAlpha(204),
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 16.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildSocialButton(
              icon: Icons.g_mobiledata,
              onTap: controller.loginWithGoogle,
            ),
            SizedBox(width: 24.w),
            _buildSocialButton(
              icon: Icons.apple,
              onTap: controller.loginWithApple,
            ),
          ],
        ),
      ],
    );
  }

  /// 构建社交登录按钮
  Widget _buildSocialButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 50.w,
        height: 50.w,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(26),
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Center(
          child: Icon(
            icon,
            color: AppColors.primary,
            size: 30.sp,
          ),
        ),
      ),
    );
  }
}
