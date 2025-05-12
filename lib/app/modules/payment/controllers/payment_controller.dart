import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tubesavely/app/data/models/payment_model.dart';
import 'package:tubesavely/app/data/models/user_model.dart';
import 'package:tubesavely/app/data/repositories/payment_repository.dart';
import 'package:tubesavely/app/services/stripe_service.dart';
import 'package:tubesavely/app/services/user_service.dart';
import 'package:tubesavely/app/utils/logger.dart';
import 'package:tubesavely/app/utils/utils.dart';

/// 支付控制器
class PaymentController extends GetxController
    with GetSingleTickerProviderStateMixin {
  final PaymentRepository _paymentRepository = Get.find<PaymentRepository>();
  final UserService _userService = Get.find<UserService>();
  final StripeService _stripeService = Get.find<StripeService>();

  // 标签控制器
  late TabController tabController;

  // 商品列表
  final RxList<ProductModel> membershipProducts = <ProductModel>[].obs;
  final RxList<ProductModel> pointsProducts = <ProductModel>[].obs;

  // 选中的商品
  final Rx<ProductModel?> selectedProduct = Rx<ProductModel?>(null);

  // 选中的支付方式
  final Rx<PaymentMethod> selectedPaymentMethod = Rx<PaymentMethod>(
    Platform.isIOS ? PaymentMethod.applePay : PaymentMethod.stripe,
  );

  // 当前订单
  final Rx<OrderModel?> currentOrder = Rx<OrderModel?>(null);

  // 是否正在加载
  final RxBool isLoading = false.obs;

  // 用户信息
  final Rx<UserModel?> userInfo = Rx<UserModel?>(null);

  // 是否支持Google Pay
  final RxBool isGooglePaySupported = false.obs;

  @override
  void onInit() {
    super.onInit();
    Logger.d('PaymentController initialized');

    // 初始化标签控制器
    tabController = TabController(length: 2, vsync: this);

    // 检查是否有初始标签参数
    if (Get.arguments != null && Get.arguments is Map) {
      final args = Get.arguments as Map;
      if (args.containsKey('initialTab')) {
        final initialTab = args['initialTab'] as int;
        if (initialTab >= 0 && initialTab < tabController.length) {
          tabController.index = initialTab;
        }
      }
    }

    // 加载商品列表
    loadProducts();

    // 加载用户信息
    loadUserInfo();

    // 检查Google Pay是否可用
    if (Platform.isAndroid) {
      checkGooglePaySupport();
    }
  }

  /// 检查Google Pay是否可用
  Future<void> checkGooglePaySupport() async {
    try {
      isGooglePaySupported.value = await _stripeService.isGooglePaySupported();
      Logger.d('Google Pay supported: ${isGooglePaySupported.value}');
    } catch (e) {
      Logger.e('Error checking Google Pay support: $e');
      isGooglePaySupported.value = false;
    }
  }

  /// 加载商品列表
  Future<void> loadProducts() async {
    try {
      isLoading.value = true;

      final products = await _paymentRepository.getProducts();

      // 分类商品
      membershipProducts.value = products
          .where((product) => product.type == ProductType.membership)
          .toList();

      pointsProducts.value = products
          .where((product) => product.type == ProductType.points)
          .toList();

      // 默认选中第一个商品
      if (membershipProducts.isNotEmpty) {
        selectedProduct.value = membershipProducts.first;
      } else if (pointsProducts.isNotEmpty) {
        selectedProduct.value = pointsProducts.first;
      }
    } catch (e) {
      Logger.e('Error loading products: $e');
      Utils.showSnackbar('错误', '加载商品列表失败: $e', isError: true);
    } finally {
      isLoading.value = false;
    }
  }

  /// 加载用户信息
  Future<void> loadUserInfo() async {
    try {
      // 先检查用户是否已登录
      if (_userService.isLoggedIn.value) {
        // 如果已登录，获取当前用户信息
        userInfo.value = _userService.currentUser.value;

        // 如果当前用户信息为空，尝试从服务器获取
        if (userInfo.value == null) {
          userInfo.value = await _userService.getUserInfo();
        }
      } else {
        // 如果未登录，清空用户信息
        userInfo.value = null;
      }
    } catch (e) {
      Logger.e('Error loading user info: $e');
    }
  }

  /// 选择商品
  void selectProduct(ProductModel product) {
    selectedProduct.value = product;
  }

  /// 选择支付方式
  void selectPaymentMethod(PaymentMethod method) {
    selectedPaymentMethod.value = method;
  }

  /// 创建订单
  Future<void> createOrder() async {
    if (selectedProduct.value == null) {
      Utils.showSnackbar('错误', '请选择商品', isError: true);
      return;
    }

    try {
      isLoading.value = true;

      OrderModel? order;

      // 在开发模式下，模拟创建订单
      if (kDebugMode) {
        // 模拟订单创建
        await Future.delayed(const Duration(seconds: 1));

        // 创建模拟订单
        order = OrderModel(
          id: 'order_${DateTime.now().millisecondsSinceEpoch}',
          productId: selectedProduct.value!.id,
          userId: userInfo.value?.id ?? 'user_123',
          amount: selectedProduct.value!.price,
          currency: selectedProduct.value!.currency,
          status: 'pending',
          paymentMethod: selectedPaymentMethod.value,
          createdAt: DateTime.now(),
        );
      } else {
        // 正常调用创建订单
        order = await _paymentRepository.createOrder(
          selectedProduct.value!.id,
          selectedPaymentMethod.value,
        );
      }

      if (order != null) {
        currentOrder.value = order;

        // 处理支付
        await processPayment(order);
      } else {
        Utils.showSnackbar('错误', '创建订单失败', isError: true);
      }
    } catch (e) {
      Logger.e('Error creating order: $e');
      Utils.showSnackbar('错误', '创建订单时出错: $e', isError: true);
    } finally {
      isLoading.value = false;
    }
  }

  /// 处理支付
  Future<void> processPayment(OrderModel order) async {
    try {
      isLoading.value = true;

      // 处理支付
      bool success;

      // 检查是否选择了Stripe支付方式
      if (order.paymentMethod == PaymentMethod.stripe) {
        // 使用Stripe支付
        success = await _paymentRepository.processPayment(order);
      } else if (kDebugMode) {
        // 在开发模式下，模拟其他支付方式的支付成功
        await Future.delayed(const Duration(seconds: 2));
        success = true;

        // 模拟更新用户信息
        if (success && userInfo.value != null) {
          final user = userInfo.value!;

          // 根据商品类型更新用户信息
          if (order.productId.contains('membership')) {
            // 会员商品
            int level = 1; // 默认高级会员
            if (order.productId.contains('pro')) {
              level = 2; // 专业会员
            }

            // 计算会员到期时间
            DateTime? expiry;
            if (user.membershipExpiry != null &&
                user.membershipExpiry!.isAfter(DateTime.now())) {
              // 如果当前会员未过期，则在当前到期时间基础上延长
              expiry = user.membershipExpiry;
            } else {
              // 如果当前会员已过期，则从现在开始计算
              expiry = DateTime.now();
            }

            // 根据商品ID确定会员时长
            int days = 30; // 默认30天
            if (order.productId.contains('quarterly')) {
              days = 90;
            } else if (order.productId.contains('yearly')) {
              days = 365;
            }

            // 更新会员到期时间
            expiry = expiry!.add(Duration(days: days));

            // 更新用户信息
            final updatedUser = user.copyWith(
              level: level,
              membershipExpiry: expiry,
            );

            // 更新用户服务中的用户信息
            await _userService.mockUpdateUser(updatedUser);
          } else if (order.productId.contains('points')) {
            // 积分商品
            int points = 0;
            if (order.productId.contains('100')) {
              points = 100;
            } else if (order.productId.contains('300')) {
              points = 330;
            } else if (order.productId.contains('500')) {
              points = 600;
            } else if (order.productId.contains('1000')) {
              points = 1300;
            }

            // 更新用户信息
            final updatedUser = user.copyWith(
              points: user.points + points,
            );

            // 更新用户服务中的用户信息
            await _userService.mockUpdateUser(updatedUser);
          }
        }
      } else {
        // 正常调用支付处理
        success = await _paymentRepository.processPayment(order);
      }

      if (success) {
        // 支付成功，更新用户信息
        await loadUserInfo();

        // 导航到支付结果页面
        Get.toNamed('/payment-result', arguments: {
          'isSuccess': true,
          'order': order,
        });
      } else {
        // 导航到支付结果页面
        Get.toNamed('/payment-result', arguments: {
          'isSuccess': false,
          'order': order,
          'errorMessage': '支付处理失败，请稍后重试',
        });
      }
    } catch (e) {
      Logger.e('Error processing payment: $e');

      // 导航到支付结果页面
      Get.toNamed('/payment-result', arguments: {
        'isSuccess': false,
        'order': order,
        'errorMessage': '处理支付时出错: $e',
      });
    } finally {
      isLoading.value = false;
    }
  }

  /// 查看交易记录
  void viewTransactionHistory() {
    Get.toNamed('/transaction-history');
  }

  /// 获取订单状态
  Future<void> getOrderStatus(String orderId) async {
    try {
      isLoading.value = true;

      final order = await _paymentRepository.getOrderStatus(orderId);

      if (order != null) {
        currentOrder.value = order;

        // 如果订单已完成，更新用户信息
        if (order.status == 'completed') {
          await loadUserInfo();
          Utils.showSnackbar('成功', '支付成功');
        }
      }
    } catch (e) {
      Logger.e('Error getting order status: $e');
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    tabController.dispose();
    super.onClose();
  }
}
