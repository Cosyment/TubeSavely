import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tubesavely/app/data/models/payment_model.dart';
import 'package:tubesavely/app/data/models/user_model.dart';
import 'package:tubesavely/app/data/repositories/payment_repository.dart';
import 'package:tubesavely/app/services/user_service.dart';
import 'package:tubesavely/app/utils/logger.dart';
import 'package:tubesavely/app/utils/utils.dart';

/// 支付控制器
class PaymentController extends GetxController with GetSingleTickerProviderStateMixin {
  final PaymentRepository _paymentRepository = Get.find<PaymentRepository>();
  final UserService _userService = Get.find<UserService>();

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

  @override
  void onInit() {
    super.onInit();
    Logger.d('PaymentController initialized');

    // 初始化标签控制器
    tabController = TabController(length: 2, vsync: this);

    // 加载商品列表
    loadProducts();

    // 加载用户信息
    loadUserInfo();
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
      userInfo.value = await _userService.getUserInfo();
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

      final order = await _paymentRepository.createOrder(
        selectedProduct.value!.id,
        selectedPaymentMethod.value,
      );

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

      final success = await _paymentRepository.processPayment(order);

      if (success) {
        // 支付成功，更新用户信息
        await loadUserInfo();
      } else {
        Utils.showSnackbar('错误', '支付失败', isError: true);
      }
    } catch (e) {
      Logger.e('Error processing payment: $e');
      Utils.showSnackbar('错误', '处理支付时出错: $e', isError: true);
    } finally {
      isLoading.value = false;
    }
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
