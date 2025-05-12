import 'package:get/get.dart';
import 'package:tubesavely/app/data/models/payment_model.dart';
import 'package:tubesavely/app/data/models/user_model.dart';
import 'package:tubesavely/app/data/providers/api_provider.dart';
import 'package:tubesavely/app/data/providers/storage_provider.dart';
import 'package:tubesavely/app/services/apple_payment_service.dart';
import 'package:tubesavely/app/services/stripe_service.dart';
import 'package:tubesavely/app/utils/logger.dart';
import 'package:tubesavely/app/utils/utils.dart';

/// 支付服务
///
/// 负责处理支付相关的业务逻辑，包括获取商品列表、创建订单、处理支付等
class PaymentService extends GetxService {
  final ApiProvider _apiProvider = Get.find<ApiProvider>();
  final StorageProvider _storageProvider = Get.find<StorageProvider>();
  late final StripeService _stripeService;
  late final ApplePaymentService _applePaymentService;

  // 商品列表
  final RxList<ProductModel> products = <ProductModel>[].obs;

  // 当前订单
  final Rx<OrderModel?> currentOrder = Rx<OrderModel?>(null);

  // 是否正在加载
  final RxBool isLoading = false.obs;

  // 是否可用
  final RxBool isApplePayAvailable = false.obs;
  final RxBool isStripeAvailable = false.obs;

  /// 初始化服务
  Future<PaymentService> init() async {
    Logger.d('PaymentService initialized');

    // 获取Stripe服务
    _stripeService = Get.find<StripeService>();
    isStripeAvailable.value = _stripeService.isInitialized;

    // 获取Apple支付服务
    _applePaymentService = Get.find<ApplePaymentService>();
    isApplePayAvailable.value = _applePaymentService.isAvailable.value;

    // 加载商品列表
    await loadProducts();

    return this;
  }

  /// 加载商品列表
  Future<void> loadProducts() async {
    try {
      isLoading.value = true;

      // 获取商品列表
      final response = await _apiProvider.getPointsPackages();

      if (response.status.isOk && response.body != null) {
        final List<dynamic> data = response.body;
        products.value =
            data.map((item) => ProductModel.fromJson(item)).toList();
      } else {
        Logger.e('Failed to load products: ${response.statusText}');
      }
    } catch (e) {
      Logger.e('Error loading products: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// 创建订单
  ///
  /// [productId] 商品ID
  /// [paymentMethod] 支付方式
  Future<OrderModel?> createOrder(
      String productId, PaymentMethod paymentMethod) async {
    try {
      isLoading.value = true;

      // 创建订单
      final response = await _apiProvider.createOrder(
        productId,
        paymentMethod.toString().split('.').last,
      );

      if (response.status.isOk && response.body != null) {
        final order = OrderModel.fromJson(response.body);
        currentOrder.value = order;
        return order;
      } else {
        Logger.e('Failed to create order: ${response.statusText}');
        return null;
      }
    } catch (e) {
      Logger.e('Error creating order: $e');
      return null;
    } finally {
      isLoading.value = false;
    }
  }

  /// 处理支付
  ///
  /// [order] 订单
  Future<bool> processPayment(OrderModel order) async {
    try {
      isLoading.value = true;

      switch (order.paymentMethod) {
        case PaymentMethod.applePay:
          return await _processApplePay(order);
        case PaymentMethod.googlePay:
          return await _processGooglePay(order);
        case PaymentMethod.stripe:
          return await _processStripePurchase(order);
        case PaymentMethod.alipay:
          return await _processAlipayPurchase(order);
        case PaymentMethod.wechatPay:
          return await _processWechatPayPurchase(order);
      }
    } catch (e) {
      Logger.e('Error processing payment: $e');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  /// 处理Apple支付
  Future<bool> _processApplePay(OrderModel order) async {
    try {
      if (!isApplePayAvailable.value) {
        Logger.e('Apple Pay is not available');
        Utils.showSnackbar('错误', 'Apple Pay不可用', isError: true);
        return false;
      }

      // 使用Apple支付服务处理支付
      return await _applePaymentService.processPayment(
        order,
        callback: (success, errorMessage) {
          if (success) {
            // 支付成功，更新用户信息
            _updateUserInfo();
          } else {
            // 支付失败
            Utils.showSnackbar('错误', errorMessage ?? '支付失败', isError: true);
          }
        },
      );
    } catch (e) {
      Logger.e('Error processing Apple Pay: $e');
      Utils.showSnackbar('错误', '处理Apple Pay支付时出错: $e', isError: true);
      return false;
    }
  }

  /// 处理Google Pay支付
  Future<bool> _processGooglePay(OrderModel order) async {
    try {
      if (!isStripeAvailable.value) {
        Logger.e('Stripe service is not initialized');
        Utils.showSnackbar('错误', 'Stripe服务未初始化', isError: true);
        return false;
      }

      // 使用Stripe服务处理Google Pay支付
      return await _stripeService.processGooglePay(order);
    } catch (e) {
      Logger.e('Error processing Google Pay: $e');
      Utils.showSnackbar('错误', '处理Google Pay支付时出错: $e', isError: true);
      return false;
    }
  }

  /// 处理Stripe支付
  Future<bool> _processStripePurchase(OrderModel order) async {
    try {
      // 检查Stripe服务是否已初始化
      if (!_stripeService.isInitialized) {
        Logger.e('Stripe service is not initialized');
        Utils.showSnackbar('错误', 'Stripe服务未初始化', isError: true);
        return false;
      }

      // 处理Stripe支付
      return await _stripeService.processPayment(order);
    } catch (e) {
      Logger.e('Error processing Stripe payment: $e');
      Utils.showSnackbar('错误', '处理Stripe支付时出错: $e', isError: true);
      return false;
    }
  }

  /// 处理支付宝支付
  Future<bool> _processAlipayPurchase(OrderModel order) async {
    try {
      Logger.d('Processing Alipay payment');

      // 获取支付宝支付参数
      final response = await _apiProvider.getAlipayParams(order.id);

      if (response.status.isOk && response.body != null) {
        // 获取支付参数
        // final String orderInfo = response.body['order_info'];

        // 调用支付宝SDK进行支付
        // 注意：这里需要集成支付宝SDK，这里只是示例代码
        // final AlipayResult result = await Alipay.pay(orderInfo);

        // 模拟支付结果
        await Future.delayed(const Duration(seconds: 2));
        const bool paySuccess = true;

        if (paySuccess) {
          // 支付成功，验证支付结果
          final verificationData = {
            'order_id': order.id,
            'payment_method': 'alipay',
          };

          final verificationResponse =
              await _apiProvider.verifyPayment(verificationData);

          return verificationResponse.status.isOk;
        }
      }

      return false;
    } catch (e) {
      Logger.e('Error processing Alipay payment: $e');
      Utils.showSnackbar('错误', '处理支付宝支付时出错: $e', isError: true);
      return false;
    }
  }

  /// 处理微信支付
  Future<bool> _processWechatPayPurchase(OrderModel order) async {
    try {
      Logger.d('Processing WeChat Pay payment');

      // 获取微信支付参数
      final response = await _apiProvider.getWechatPayParams(order.id);

      if (response.status.isOk && response.body != null) {
        // 获取支付参数
        // final Map<String, dynamic> payParams = response.body;

        // 调用微信SDK进行支付
        // 注意：这里需要集成微信SDK，这里只是示例代码
        // final WechatPayResult result = await WechatPay.pay(payParams);

        // 模拟支付结果
        await Future.delayed(const Duration(seconds: 2));
        const bool paySuccess = true;

        if (paySuccess) {
          // 支付成功，验证支付结果
          final verificationData = {
            'order_id': order.id,
            'payment_method': 'wechat_pay',
          };

          final verificationResponse =
              await _apiProvider.verifyPayment(verificationData);

          return verificationResponse.status.isOk;
        }
      }

      return false;
    } catch (e) {
      Logger.e('Error processing WeChat Pay payment: $e');
      Utils.showSnackbar('错误', '处理微信支付时出错: $e', isError: true);
      return false;
    }
  }

  /// 更新用户信息
  Future<void> _updateUserInfo() async {
    try {
      // 获取用户信息
      final response = await _apiProvider.getUserInfo();

      if (response.status.isOk && response.body != null) {
        final userModel = UserModel.fromJson(response.body);
        await _storageProvider.saveUserInfo(userModel);
      }
    } catch (e) {
      Logger.e('Error updating user info: $e');
    }
  }
}
