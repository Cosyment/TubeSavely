import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:tubesavely/app/data/models/payment_model.dart';
import 'package:tubesavely/app/data/providers/api_provider.dart';
import 'package:tubesavely/app/utils/logger.dart';
import 'package:tubesavely/app/utils/utils.dart';

/// Apple支付服务
///
/// 负责处理Apple In-App Purchase相关的业务逻辑
class ApplePaymentService extends GetxService {
  final ApiProvider _apiProvider = Get.find<ApiProvider>();

  // In-App Purchase
  late final InAppPurchase _inAppPurchase;
  StreamSubscription<List<PurchaseDetails>>? _subscription;

  // 是否可用
  final RxBool isAvailable = false.obs;

  // 当前处理的订单
  OrderModel? _currentOrder;

  // 支付结果回调
  Function(bool success, String? errorMessage)? _paymentCallback;

  /// 初始化服务
  Future<ApplePaymentService> init() async {
    Logger.d('ApplePaymentService initialized');

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
    } else {
      Logger.w('In-App Purchase is not available');
    }

    return this;
  }

  /// 处理Apple支付
  ///
  /// [order] 订单
  /// [callback] 支付结果回调
  Future<bool> processPayment(
    OrderModel order, {
    Function(bool success, String? errorMessage)? callback,
  }) async {
    try {
      if (!isAvailable.value) {
        Logger.e('In-App Purchase is not available');
        callback?.call(false, 'In-App Purchase is not available');
        return false;
      }

      // 保存当前订单和回调
      _currentOrder = order;
      _paymentCallback = callback;

      // 查询商品详情
      final ProductDetailsResponse productDetailsResponse =
          await _inAppPurchase.queryProductDetails({order.productId});

      if (productDetailsResponse.error != null) {
        Logger.e(
            'Error querying product details: ${productDetailsResponse.error}');
        callback?.call(false, 'Error querying product details: ${productDetailsResponse.error}');
        return false;
      }

      if (productDetailsResponse.productDetails.isEmpty) {
        Logger.e('No product details found for ${order.productId}');
        callback?.call(false, 'No product details found for ${order.productId}');
        return false;
      }

      // 购买商品
      final PurchaseParam purchaseParam = PurchaseParam(
        productDetails: productDetailsResponse.productDetails.first,
        applicationUserName: order.userId,
      );

      // 根据商品类型选择购买方式
      final ProductModel? product = _getProductFromOrder(order);
      if (product == null) {
        Logger.e('Product not found for order: ${order.id}');
        callback?.call(false, 'Product not found for order');
        return false;
      }

      if (product.type == ProductType.points) {
        // 积分包是消耗性商品
        return await _inAppPurchase.buyConsumable(purchaseParam: purchaseParam);
      } else {
        // 会员是非消耗性商品
        return await _inAppPurchase.buyNonConsumable(purchaseParam: purchaseParam);
      }
    } catch (e) {
      Logger.e('Error processing Apple payment: $e');
      callback?.call(false, 'Error processing Apple payment: $e');
      return false;
    }
  }

  /// 恢复购买
  Future<bool> restorePurchases() async {
    try {
      if (!isAvailable.value) {
        Logger.e('In-App Purchase is not available');
        return false;
      }

      await _inAppPurchase.restorePurchases();
      return true;
    } catch (e) {
      Logger.e('Error restoring purchases: $e');
      return false;
    }
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
        _paymentCallback?.call(false, 'Purchase error: ${purchaseDetails.error?.message}');
      } else if (purchaseDetails.status == PurchaseStatus.purchased ||
          purchaseDetails.status == PurchaseStatus.restored) {
        // 购买成功或恢复购买
        Logger.d(
            'Purchase ${purchaseDetails.status == PurchaseStatus.purchased ? 'purchased' : 'restored'}: ${purchaseDetails.productID}');

        // 验证购买
        _verifyPurchase(purchaseDetails);
      } else if (purchaseDetails.status == PurchaseStatus.canceled) {
        // 购买取消
        Logger.d('Purchase canceled: ${purchaseDetails.productID}');
        _paymentCallback?.call(false, 'Purchase canceled');
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
        'platform': 'ios',
        'order_id': _currentOrder?.id,
      };

      // 验证购买
      final response = await _apiProvider.verifyPayment(verificationData);

      if (response.status.isOk) {
        Logger.d('Purchase verified successfully');
        _paymentCallback?.call(true, null);
      } else {
        Logger.e('Purchase verification failed: ${response.statusText}');
        _paymentCallback?.call(false, 'Purchase verification failed: ${response.statusText}');
      }
    } catch (e) {
      Logger.e('Error verifying purchase: $e');
      _paymentCallback?.call(false, 'Error verifying purchase: $e');
    }
  }

  /// 从订单中获取商品信息
  ProductModel? _getProductFromOrder(OrderModel order) {
    // 这里应该从商品列表中查找对应的商品
    // 由于我们没有商品列表的引用，这里简单返回null
    // 实际应用中应该从商品仓库或服务中获取
    return null;
  }

  @override
  void onClose() {
    _subscription?.cancel();
    super.onClose();
  }
}
