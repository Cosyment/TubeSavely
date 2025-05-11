import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lottie/lottie.dart';
import 'package:tubesavely/app/data/models/payment_model.dart';
import 'package:tubesavely/app/theme/app_colors.dart';
import 'package:tubesavely/app/theme/app_text_styles.dart';
import 'package:tubesavely/app/utils/utils.dart';

/// 支付结果页面
class PaymentResultView extends StatelessWidget {
  const PaymentResultView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // 获取参数
    final Map<String, dynamic> args = Get.arguments ?? {};
    final bool isSuccess = args['isSuccess'] ?? false;
    final OrderModel? order = args['order'];
    final String? errorMessage = args['errorMessage'];

    return Scaffold(
      appBar: AppBar(
        title: Text(
          '支付结果',
          style: AppTextStyles.titleLarge,
        ),
        centerTitle: true,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16.r),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // 动画
              _buildAnimation(isSuccess),
              SizedBox(height: 24.h),
              // 标题
              Text(
                isSuccess ? '支付成功' : '支付失败',
                style: TextStyle(
                  fontSize: 24.sp,
                  fontWeight: FontWeight.bold,
                  color: isSuccess ? Colors.green : Colors.red,
                ),
              ),
              SizedBox(height: 16.h),
              // 订单信息
              if (order != null) _buildOrderInfo(order),
              // 错误信息
              if (!isSuccess && errorMessage != null)
                Container(
                  margin: EdgeInsets.symmetric(vertical: 16.h),
                  padding: EdgeInsets.all(16.r),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Text(
                    errorMessage,
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: Colors.red,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              SizedBox(height: 32.h),
              // 按钮
              _buildButtons(isSuccess),
            ],
          ),
        ),
      ),
    );
  }

  /// 构建动画
  Widget _buildAnimation(bool isSuccess) {
    return Container(
      width: 120.r,
      height: 120.r,
      decoration: BoxDecoration(
        color: (isSuccess ? Colors.green : Colors.red).withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: isSuccess
            ? Icon(
                Icons.check_circle,
                size: 80.r,
                color: Colors.green,
              )
            : Icon(
                Icons.cancel,
                size: 80.r,
                color: Colors.red,
              ),
      ),
    );
  }

  /// 构建订单信息
  Widget _buildOrderInfo(OrderModel order) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 16.h),
      padding: EdgeInsets.all(16.r),
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
          _buildOrderInfoItem('订单编号', order.id),
          _buildOrderInfoItem('商品', order.productId),
          _buildOrderInfoItem(
              '金额', '${order.amount} ${order.currency.toUpperCase()}'),
          _buildOrderInfoItem('支付方式', _getPaymentMethodName(order.paymentMethod)),
          _buildOrderInfoItem('状态', _getStatusName(order.status)),
          _buildOrderInfoItem('创建时间',
              Utils.formatDateTime(order.createdAt, format: 'yyyy-MM-dd HH:mm')),
          if (order.completedAt != null)
            _buildOrderInfoItem(
                '完成时间',
                Utils.formatDateTime(order.completedAt!,
                    format: 'yyyy-MM-dd HH:mm')),
        ],
      ),
    );
  }

  /// 构建订单信息项
  Widget _buildOrderInfoItem(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14.sp,
              color: Get.theme.colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.bold,
              color: Get.theme.colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }

  /// 构建按钮
  Widget _buildButtons(bool isSuccess) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              // 返回首页
              Get.offAllNamed('/main');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              padding: EdgeInsets.symmetric(vertical: 12.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
            ),
            child: Text(
              '返回首页',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),
        SizedBox(height: 12.h),
        if (!isSuccess)
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () {
                // 重试支付
                Get.back();
              },
              style: OutlinedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 12.h),
                side: BorderSide(color: AppColors.primary),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
              child: Text(
                '重试支付',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ),
          ),
      ],
    );
  }

  /// 获取支付方式名称
  String _getPaymentMethodName(PaymentMethod method) {
    switch (method) {
      case PaymentMethod.applePay:
        return 'Apple Pay';
      case PaymentMethod.googlePay:
        return 'Google Pay';
      case PaymentMethod.stripe:
        return 'Stripe';
      case PaymentMethod.alipay:
        return '支付宝';
      case PaymentMethod.wechatPay:
        return '微信支付';
      default:
        return '未知';
    }
  }

  /// 获取状态名称
  String _getStatusName(String status) {
    switch (status) {
      case 'pending':
        return '待支付';
      case 'completed':
        return '已完成';
      case 'failed':
        return '失败';
      case 'canceled':
        return '已取消';
      default:
        return '未知';
    }
  }
}
