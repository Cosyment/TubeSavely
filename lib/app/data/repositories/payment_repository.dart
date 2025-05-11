import 'package:get/get.dart';
import 'package:tubesavely/app/data/models/payment_model.dart';
import 'package:tubesavely/app/data/providers/api_provider.dart';
import 'package:tubesavely/app/services/payment_service.dart';
import 'package:tubesavely/app/utils/logger.dart';

/// 支付仓库
///
/// 负责处理支付相关的数据操作
class PaymentRepository {
  final ApiProvider _apiProvider = Get.find<ApiProvider>();
  final PaymentService _paymentService = Get.find<PaymentService>();

  /// 获取商品列表
  Future<List<ProductModel>> getProducts() async {
    try {
      // 如果已经加载过商品列表，直接返回
      if (_paymentService.products.isNotEmpty) {
        return _paymentService.products;
      }

      // 加载商品列表
      await _paymentService.loadProducts();
      return _paymentService.products;
    } catch (e) {
      Logger.e('Error getting products: $e');
      return [];
    }
  }

  /// 创建订单
  ///
  /// [productId] 商品ID
  /// [paymentMethod] 支付方式
  Future<OrderModel?> createOrder(String productId, PaymentMethod paymentMethod) async {
    try {
      return await _paymentService.createOrder(productId, paymentMethod);
    } catch (e) {
      Logger.e('Error creating order: $e');
      return null;
    }
  }

  /// 处理支付
  ///
  /// [order] 订单
  Future<bool> processPayment(OrderModel order) async {
    try {
      return await _paymentService.processPayment(order);
    } catch (e) {
      Logger.e('Error processing payment: $e');
      return false;
    }
  }

  /// 获取订单状态
  ///
  /// [orderId] 订单ID
  Future<OrderModel?> getOrderStatus(String orderId) async {
    try {
      final response = await _apiProvider.getOrderStatus(orderId);
      
      if (response.status.isOk && response.body != null) {
        return OrderModel.fromJson(response.body);
      }
      
      return null;
    } catch (e) {
      Logger.e('Error getting order status: $e');
      return null;
    }
  }

  /// 验证支付
  ///
  /// [data] 支付验证数据
  Future<bool> verifyPayment(Map<String, dynamic> data) async {
    try {
      final response = await _apiProvider.verifyPayment(data);
      return response.status.isOk;
    } catch (e) {
      Logger.e('Error verifying payment: $e');
      return false;
    }
  }
}
