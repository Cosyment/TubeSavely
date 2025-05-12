import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:get/get.dart';
import 'package:tubesavely/app/data/models/payment_model.dart';
import 'package:tubesavely/app/data/providers/api_provider.dart';
import 'package:tubesavely/app/utils/constants.dart';
import 'package:tubesavely/app/utils/logger.dart';
import 'package:tubesavely/app/utils/utils.dart';

/// Stripe 支付服务
///
/// 负责处理 Stripe 支付相关的业务逻辑
class StripeService extends GetxService {
  final ApiProvider _apiProvider = Get.find<ApiProvider>();

  // Stripe 公钥
  final String _publishableKey = Constants.STRIPE_PUBLISHABLE_KEY;

  // 是否已初始化
  bool _isInitialized = false;

  /// 初始化服务
  Future<StripeService> init() async {
    Logger.d('StripeService initialized');

    try {
      // 初始化 Stripe
      Stripe.publishableKey = _publishableKey;
      await Stripe.instance.applySettings();
      _isInitialized = true;
    } catch (e) {
      Logger.e('Error initializing Stripe: $e');
    }

    return this;
  }

  /// 检查是否已初始化
  bool get isInitialized => _isInitialized;

  /// 检查Google Pay是否可用
  Future<bool> isGooglePaySupported() async {
    try {
      if (!_isInitialized) {
        return false;
      }

      return await Stripe.instance.isPlatformPaySupported();
    } catch (e) {
      Logger.e('Error checking Google Pay support: $e');
      return false;
    }
  }

  /// 创建支付意图
  ///
  /// [amount] 金额（分）
  /// [currency] 货币代码
  /// [productId] 商品ID
  Future<Map<String, dynamic>> createPaymentIntent({
    required int amount,
    required String currency,
    required String productId,
  }) async {
    try {
      // 在开发模式下，模拟创建支付意图
      if (kDebugMode) {
        // 模拟延迟
        await Future.delayed(const Duration(milliseconds: 800));

        // 生成一个模拟的支付意图ID
        final String intentId = 'pi_${DateTime.now().millisecondsSinceEpoch}';

        // 生成一个模拟的客户端密钥
        final String clientSecret =
            '$intentId\_secret_${DateTime.now().millisecondsSinceEpoch}';

        // 返回模拟数据
        return {
          'id': intentId,
          'object': 'payment_intent',
          'amount': amount,
          'currency': currency,
          'client_secret': clientSecret,
          'status': 'requires_payment_method',
          'created': DateTime.now().millisecondsSinceEpoch ~/ 1000,
          'product_id': productId,
          'livemode': false,
        };
      } else {
        // 调用后端 API 创建支付意图
        final response = await _apiProvider.post('/payment/create-intent', {
          'amount': amount,
          'currency': currency,
          'product_id': productId,
        });

        if (response.status.isOk && response.body != null) {
          return response.body;
        } else {
          throw Exception(
              'Failed to create payment intent: ${response.statusText}');
        }
      }
    } catch (e) {
      Logger.e('Error creating payment intent: $e');
      rethrow;
    }
  }

  /// 处理支付
  ///
  /// [order] 订单
  Future<bool> processPayment(OrderModel order) async {
    try {
      if (!_isInitialized) {
        throw Exception('Stripe is not initialized');
      }

      // 创建支付意图
      final paymentIntentResult = await createPaymentIntent(
        amount: (order.amount * 100).toInt(), // 转换为分
        currency: order.currency.toLowerCase(),
        productId: order.productId,
      );

      // 在开发模式下，模拟支付成功
      if (kDebugMode) {
        // 显示一个模拟的支付表单
        await Future.delayed(const Duration(seconds: 1));

        // 模拟用户点击支付按钮
        await Future.delayed(const Duration(seconds: 1));

        // 模拟支付成功
        Logger.d('模拟Stripe支付成功: ${paymentIntentResult['id']}');

        // 返回支付成功
        return true;
      } else {
        // 配置支付表单
        await Stripe.instance.initPaymentSheet(
          paymentSheetParameters: SetupPaymentSheetParameters(
            merchantDisplayName: 'TubeSavely',
            paymentIntentClientSecret: paymentIntentResult['client_secret'],
            style: ThemeMode.system,
            appearance: const PaymentSheetAppearance(
              colors: PaymentSheetAppearanceColors(
                primary: Color(0xFF8B5CF6), // 主色调
              ),
            ),
            googlePay: const PaymentSheetGooglePay(
              merchantCountryCode: 'US',
              testEnv: true,
            ),
          ),
        );

        // 显示支付表单
        await Stripe.instance.presentPaymentSheet();

        // 验证支付
        final verificationData = {
          'payment_intent_id': paymentIntentResult['id'],
          'order_id': order.id,
        };

        final verificationResponse =
            await _apiProvider.verifyPayment(verificationData);

        return verificationResponse.status.isOk;
      }
    } on StripeException catch (e) {
      Logger.e('Stripe error: ${e.error.localizedMessage}');
      Utils.showSnackbar(
        '支付失败',
        e.error.localizedMessage ?? '处理支付时出错',
        isError: true,
      );
      return false;
    } catch (e) {
      Logger.e('Error processing Stripe payment: $e');
      Utils.showSnackbar('支付失败', '处理支付时出错: $e', isError: true);
      return false;
    }
  }

  /// 处理 Google Pay 支付
  ///
  /// [order] 订单
  Future<bool> processGooglePay(OrderModel order) async {
    try {
      if (!_isInitialized) {
        throw Exception('Stripe is not initialized');
      }

      // 在开发模式下，模拟支付成功
      if (kDebugMode) {
        // 显示一个模拟的支付表单
        await Future.delayed(const Duration(seconds: 1));

        // 模拟用户点击支付按钮
        await Future.delayed(const Duration(seconds: 1));

        // 模拟支付成功
        Logger.d('模拟Google Pay支付成功: ${order.id}');

        // 返回支付成功
        return true;
      } else {
        // 检查 Google Pay 是否可用
        final isPlatformPaySupported =
            await Stripe.instance.isPlatformPaySupported();

        if (!isPlatformPaySupported) {
          Utils.showSnackbar('错误', '您的设备不支持 Google Pay', isError: true);
          return false;
        }

        // 创建支付意图
        final paymentIntentResult = await createPaymentIntent(
          amount: (order.amount * 100).toInt(), // 转换为分
          currency: order.currency.toLowerCase(),
          productId: order.productId,
        );

        // 配置支付表单
        await Stripe.instance.initPaymentSheet(
          paymentSheetParameters: SetupPaymentSheetParameters(
            merchantDisplayName: 'TubeSavely',
            paymentIntentClientSecret: paymentIntentResult['client_secret'],
            style: ThemeMode.system,
            appearance: const PaymentSheetAppearance(
              colors: PaymentSheetAppearanceColors(
                primary: Color(0xFF8B5CF6), // 主色调
              ),
            ),
            googlePay: const PaymentSheetGooglePay(
              merchantCountryCode: 'US',
              testEnv: true,
            ),
          ),
        );

        // 显示支付表单
        await Stripe.instance.presentPaymentSheet();

        // 验证支付
        final verificationData = {
          'payment_intent_id': paymentIntentResult['id'],
          'order_id': order.id,
        };

        final verificationResponse =
            await _apiProvider.verifyPayment(verificationData);

        return verificationResponse.status.isOk;
      }
    } on StripeException catch (e) {
      Logger.e('Stripe error: ${e.error.localizedMessage}');
      Utils.showSnackbar(
        '支付失败',
        e.error.localizedMessage ?? '处理支付时出错',
        isError: true,
      );
      return false;
    } catch (e) {
      Logger.e('Error processing Google Pay: $e');
      Utils.showSnackbar('支付失败', '处理支付时出错: $e', isError: true);
      return false;
    }
  }
}
