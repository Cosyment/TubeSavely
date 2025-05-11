import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tubesavely/app/data/models/payment_model.dart';
import 'package:tubesavely/app/theme/app_colors.dart';
import 'package:tubesavely/app/theme/app_text_styles.dart';
import 'package:tubesavely/app/utils/utils.dart';
import '../controllers/payment_controller.dart';

class PaymentView extends GetView<PaymentController> {
  const PaymentView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '会员与积分',
          style: AppTextStyles.titleLarge,
        ),
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.receipt_long),
            onPressed: controller.viewTransactionHistory,
            tooltip: '交易记录',
          ),
        ],
      ),
      body: Column(
        children: [
          _buildUserInfo(),
          _buildTabBar(),
          Expanded(
            child: TabBarView(
              controller: controller.tabController,
              children: [
                _buildMembershipTab(),
                _buildPointsTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 构建用户信息
  Widget _buildUserInfo() {
    return Obx(() {
      final user = controller.userInfo.value;

      return Container(
        padding: EdgeInsets.all(16.r),
        margin: EdgeInsets.all(16.r),
        decoration: BoxDecoration(
          color: Get.theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(12.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 30.r,
                  backgroundColor: AppColors.primary.withOpacity(0.1),
                  child: Text(
                    user?.name?.substring(0, 1).toUpperCase() ?? '?',
                    style: TextStyle(
                      fontSize: 24.sp,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user?.name ?? '未登录',
                        style: AppTextStyles.titleMedium,
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        user?.email ?? '',
                        style: AppTextStyles.bodySmall,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildUserInfoItem(
                  '会员状态',
                  user?.isMembershipActive == true ? '有效' : '无效',
                  user?.isMembershipActive == true ? Colors.green : Colors.red,
                ),
                _buildUserInfoItem(
                  '会员等级',
                  'Lv.${user?.level ?? 0}',
                  AppColors.primary,
                ),
                _buildUserInfoItem(
                  '积分',
                  '${user?.points ?? 0}',
                  Colors.orange,
                ),
              ],
            ),
          ],
        ),
      );
    });
  }

  /// 构建用户信息项
  Widget _buildUserInfoItem(String title, String value, Color color) {
    return Column(
      children: [
        Text(
          title,
          style: AppTextStyles.bodySmall,
        ),
        SizedBox(height: 4.h),
        Text(
          value,
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  /// 构建标签栏
  Widget _buildTabBar() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      decoration: BoxDecoration(
        color: Get.theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: TabBar(
        controller: controller.tabController,
        indicator: BoxDecoration(
          borderRadius: BorderRadius.circular(12.r),
          color: AppColors.primary,
        ),
        labelColor: Colors.white,
        unselectedLabelColor: Get.theme.colorScheme.onSurface,
        tabs: [
          Tab(text: '会员套餐'),
          Tab(text: '积分充值'),
        ],
      ),
    );
  }

  /// 构建会员标签页
  Widget _buildMembershipTab() {
    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }

      if (controller.membershipProducts.isEmpty) {
        return Center(
          child: Text(
            '暂无会员套餐',
            style: AppTextStyles.bodyLarge,
          ),
        );
      }

      return ListView.builder(
        padding: EdgeInsets.all(16.r),
        itemCount: controller.membershipProducts.length,
        itemBuilder: (context, index) {
          final product = controller.membershipProducts[index];
          return _buildProductItem(product);
        },
      );
    });
  }

  /// 构建积分标签页
  Widget _buildPointsTab() {
    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }

      if (controller.pointsProducts.isEmpty) {
        return Center(
          child: Text(
            '暂无积分套餐',
            style: AppTextStyles.bodyLarge,
          ),
        );
      }

      return ListView.builder(
        padding: EdgeInsets.all(16.r),
        itemCount: controller.pointsProducts.length,
        itemBuilder: (context, index) {
          final product = controller.pointsProducts[index];
          return _buildProductItem(product);
        },
      );
    });
  }

  /// 构建商品项
  Widget _buildProductItem(ProductModel product) {
    return Obx(() {
      final isSelected = controller.selectedProduct.value?.id == product.id;

      return GestureDetector(
        onTap: () => controller.selectProduct(product),
        child: Container(
          margin: EdgeInsets.only(bottom: 16.r),
          padding: EdgeInsets.all(16.r),
          decoration: BoxDecoration(
            color: Get.theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(
              color: isSelected ? AppColors.primary : Colors.transparent,
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    product.title,
                    style: AppTextStyles.titleMedium,
                  ),
                  Text(
                    '${product.price} ${product.currency}',
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8.h),
              Text(
                product.description,
                style: AppTextStyles.bodySmall,
              ),
              SizedBox(height: 16.h),
              if (isSelected) _buildPaymentMethods(),
              if (isSelected)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: controller.createOrder,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: EdgeInsets.symmetric(vertical: 12.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                    child: Text(
                      '立即购买',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      );
    });
  }

  /// 构建支付方式
  Widget _buildPaymentMethods() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '选择支付方式',
          style: AppTextStyles.bodyMedium.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 8.h),
        Wrap(
          spacing: 8.w,
          runSpacing: 8.h,
          children: [
            if (Platform.isIOS || Platform.isMacOS)
              _buildPaymentMethodItem(
                'Apple Pay',
                'assets/images/apple_pay.png',
                PaymentMethod.applePay,
              ),
            if (Platform.isAndroid)
              _buildPaymentMethodItem(
                'Google Pay',
                'assets/images/google_pay.png',
                PaymentMethod.googlePay,
              ),
            _buildPaymentMethodItem(
              'Stripe',
              'assets/images/stripe.png',
              PaymentMethod.stripe,
            ),
            _buildPaymentMethodItem(
              '支付宝',
              'assets/images/alipay.png',
              PaymentMethod.alipay,
            ),
            _buildPaymentMethodItem(
              '微信支付',
              'assets/images/wechat_pay.png',
              PaymentMethod.wechatPay,
            ),
          ],
        ),
        SizedBox(height: 16.h),
      ],
    );
  }

  /// 构建支付方式项
  Widget _buildPaymentMethodItem(
      String name, String iconPath, PaymentMethod method) {
    return Obx(() {
      final isSelected = controller.selectedPaymentMethod.value == method;

      return GestureDetector(
        onTap: () => controller.selectPaymentMethod(method),
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: 16.w,
            vertical: 8.h,
          ),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.primary.withOpacity(0.1)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(8.r),
            border: Border.all(
              color: isSelected ? AppColors.primary : Colors.grey.shade300,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 图标
              // Image.asset(
              //   iconPath,
              //   width: 24.w,
              //   height: 24.h,
              // ),
              // SizedBox(width: 8.w),
              Text(
                name,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected ? AppColors.primary : null,
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}
