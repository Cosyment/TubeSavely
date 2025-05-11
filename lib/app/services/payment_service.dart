import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:tubesavely/app/data/models/payment_model.dart';
import 'package:tubesavely/app/data/models/user_model.dart';
import 'package:tubesavely/app/data/providers/api_provider.dart';
import 'package:tubesavely/app/data/providers/storage_provider.dart';
import 'package:tubesavely/app/utils/logger.dart';
import 'package:tubesavely/app/utils/utils.dart';

/// 支付服务
///
/// 负责处理支付相关的业务逻辑，包括获取商品列表、创建订单、处理支付等
class PaymentService extends GetxService {
  final ApiProvider _apiProvider = Get.find<ApiProvider>();
  final StorageProvider _storageProvider = Get.find<StorageProvider>();

  // 商品列表
  final RxList<ProductModel> products = <ProductModel>[].obs;

  // 当前订单
  final Rx<OrderModel?> currentOrder = Rx<OrderModel?>(null);

  // 是否正在加载
  final RxBool isLoading = false.obs;

  // 是否可用
  final RxBool isAvailable = false.obs;

  // In-App Purchase
  late final InAppPurchase _inAppPurchase;
  StreamSubscription<List<PurchaseDetails>>? _subscription;

  /// 初始化服务
  Future<PaymentService> init() async {
    Logger.d('PaymentService initialized');

    // 初始化In-App Purchase
    _inAppPurchase = InAppPurchase.instance;
    isAvailable.value = await _inAppPurchase.isAvailable();

    if (isAvailable.value) {
      // 监听购买更新
      _subscription = _inAppPurchase.purchaseStream.listen(
        _listenToPurchaseUpdated,
        onDone: () {
          _subscription?.cancel();
        },
        onError: (error) {
          Logger.e('Error in purchase stream: $error');
        },
      );

      // 加载商品列表
      await loadProducts();
    } else {
      Logger.w('In-App Purchase is not available');
    }

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
        products.value = data.map((item) => ProductModel.fromJson(item)).toList();
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
  Future<OrderModel?> createOrder(String productId, PaymentMethod paymentMethod) async {
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
        case PaymentMethod.googlePay:
          return await _processInAppPurchase(order);
        case PaymentMethod.stripe:
          return await _processStripePurchase(order);
        case PaymentMethod.alipay:
          return await _processAlipayPurchase(order);
        case PaymentMethod.wechatPay:
          return await _processWechatPayPurchase(order);
        default:
          return false;
      }
    } catch (e) {
      Logger.e('Error processing payment: $e');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  /// 处理In-App Purchase
  Future<bool> _processInAppPurchase(OrderModel order) async {
    try {
      // 查询商品详情
      final ProductDetailsResponse productDetailsResponse =
          await _inAppPurchase.queryProductDetails({order.productId});

      if (productDetailsResponse.error != null) {
        Logger.e('Error querying product details: ${productDetailsResponse.error}');
        return false;
      }

      if (productDetailsResponse.productDetails.isEmpty) {
        Logger.e('No product details found for ${order.productId}');
        return false;
      }

      // 购买商品
      final PurchaseParam purchaseParam = PurchaseParam(
        productDetails: productDetailsResponse.productDetails.first,
        applicationUserName: order.userId,
      );

      if (Platform.isIOS) {
        return await _inAppPurchase.buyConsumable(purchaseParam: purchaseParam);
      } else {
        return await _inAppPurchase.buyNonConsumable(purchaseParam: purchaseParam);
      }
    } catch (e) {
      Logger.e('Error processing In-App Purchase: $e');
      return false;
    }
  }

  /// 处理Stripe支付
  Future<bool> _processStripePurchase(OrderModel order) async {
    // TODO: 实现Stripe支付
    return false;
  }

  /// 处理支付宝支付
  Future<bool> _processAlipayPurchase(OrderModel order) async {
    // TODO: 实现支付宝支付
    return false;
  }

  /// 处理微信支付
  Future<bool> _processWechatPayPurchase(OrderModel order) async {
    // TODO: 实现微信支付
    return false;
  }

  /// 监听购买更新
  void _listenToPurchaseUpdated(List<PurchaseDetails> purchaseDetailsList) {
    for (final purchaseDetails in purchaseDetailsList) {
      if (purchaseDetails.status == PurchaseStatus.pending) {
        // 购买中
        Logger.d('Purchase pending: ${purchaseDetails.productID}');
      } else if (purchaseDetails.status == PurchaseStatus.error) {
        // 购买错误
        Logger.e('Purchase error: ${purchaseDetails.error}');
        Utils.showSnackbar('错误', '购买失败: ${purchaseDetails.error}', isError: true);
      } else if (purchaseDetails.status == PurchaseStatus.purchased ||
          purchaseDetails.status == PurchaseStatus.restored) {
        // 购买成功或恢复购买
        Logger.d('Purchase ${purchaseDetails.status == PurchaseStatus.purchased ? 'purchased' : 'restored'}: ${purchaseDetails.productID}');
        
        // 验证购买
        _verifyPurchase(purchaseDetails);
      } else if (purchaseDetails.status == PurchaseStatus.canceled) {
        // 购买取消
        Logger.d('Purchase canceled: ${purchaseDetails.productID}');
      }

      // 完成购买
      if (purchaseDetails.pendingCompletePurchase) {
        _inAppPurchase.completePurchase(purchaseDetails);
      }
    }
  }

  /// 验证购买
  Future<void> _verifyPurchase(PurchaseDetails purchaseDetails) async {
    try {
      // 构建验证数据
      final Map<String, dynamic> verificationData = {
        'receipt': purchaseDetails.verificationData.serverVerificationData,
        'product_id': purchaseDetails.productID,
        'transaction_id': purchaseDetails.purchaseID,
        'platform': Platform.isIOS ? 'ios' : 'android',
      };

      // 验证购买
      final success = await _apiProvider.verifyPayment(verificationData);

      if (success.status.isOk) {
        Utils.showSnackbar('成功', '购买成功');
        
        // 更新用户信息
        await _updateUserInfo();
      } else {
        Utils.showSnackbar('错误', '购买验证失败', isError: true);
      }
    } catch (e) {
      Logger.e('Error verifying purchase: $e');
      Utils.showSnackbar('错误', '购买验证出错: $e', isError: true);
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

  @override
  void onClose() {
    _subscription?.cancel();
    super.onClose();
  }
}
