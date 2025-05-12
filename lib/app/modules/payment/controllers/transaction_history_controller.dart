import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:tubesavely/app/data/models/payment_model.dart';
import 'package:tubesavely/app/data/repositories/payment_repository.dart';
import 'package:tubesavely/app/services/user_service.dart';
import 'package:tubesavely/app/utils/logger.dart';
import 'package:tubesavely/app/utils/utils.dart';

/// 交易记录控制器
class TransactionHistoryController extends GetxController {
  final PaymentRepository _paymentRepository = Get.find<PaymentRepository>();
  final UserService _userService = Get.find<UserService>();

  // 交易记录列表
  final RxList<OrderModel> transactions = <OrderModel>[].obs;

  // 是否正在加载
  final RxBool isLoading = false.obs;

  // 是否有更多数据
  final RxBool hasMore = true.obs;

  // 当前页码
  final RxInt currentPage = 1.obs;

  // 每页数量
  final int pageSize = 20;

  @override
  void onInit() {
    super.onInit();
    Logger.d('TransactionHistoryController initialized');

    // 加载交易记录
    loadTransactions();
  }

  /// 加载交易记录
  Future<void> loadTransactions() async {
    try {
      isLoading.value = true;

      // 重置页码
      currentPage.value = 1;

      // 在开发模式下，使用模拟数据
      if (kDebugMode) {
        await _loadMockTransactions();
      } else {
        // 获取交易记录
        final result = await _paymentRepository.getTransactions(
          page: currentPage.value,
          pageSize: pageSize,
        );

        // 更新交易记录
        transactions.assignAll(result.transactions);

        // 更新是否有更多数据
        hasMore.value = result.hasMore;
      }
    } catch (e) {
      Logger.e('Error loading transactions: $e');
      Utils.showSnackbar('错误', '加载交易记录失败: $e', isError: true);
    } finally {
      isLoading.value = false;
    }
  }

  /// 加载模拟交易记录
  Future<void> _loadMockTransactions() async {
    // 模拟加载延迟
    await Future.delayed(const Duration(seconds: 1));

    // 获取当前用户ID
    final userId = _userService.currentUser.value?.id ?? 'user_123';

    // 创建模拟交易记录
    final mockTransactions = [
      OrderModel(
        id: 'order_001',
        productId: 'membership_monthly',
        userId: userId,
        amount: 18.0,
        currency: 'CNY',
        status: 'completed',
        paymentMethod: PaymentMethod.alipay,
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
        completedAt: DateTime.now().subtract(const Duration(days: 2)),
        transactionId: 'tx_001',
      ),
      OrderModel(
        id: 'order_002',
        productId: 'points_500',
        userId: userId,
        amount: 50.0,
        currency: 'CNY',
        status: 'completed',
        paymentMethod: PaymentMethod.wechatPay,
        createdAt: DateTime.now().subtract(const Duration(days: 5)),
        completedAt: DateTime.now().subtract(const Duration(days: 5)),
        transactionId: 'tx_002',
      ),
      OrderModel(
        id: 'order_003',
        productId: 'membership_pro_yearly',
        userId: userId,
        amount: 258.0,
        currency: 'CNY',
        status: 'pending',
        paymentMethod: PaymentMethod.stripe,
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
      ),
      OrderModel(
        id: 'order_004',
        productId: 'points_100',
        userId: userId,
        amount: 10.0,
        currency: 'CNY',
        status: 'failed',
        paymentMethod: PaymentMethod.applePay,
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
        errorMessage: '支付失败，请重试',
      ),
    ];

    // 更新交易记录
    transactions.assignAll(mockTransactions);

    // 设置是否有更多数据
    hasMore.value = false;
  }

  /// 加载更多交易记录
  Future<void> loadMoreTransactions() async {
    if (!hasMore.value || isLoading.value) {
      return;
    }

    try {
      isLoading.value = true;

      // 增加页码
      currentPage.value++;

      // 获取交易记录
      final result = await _paymentRepository.getTransactions(
        page: currentPage.value,
        pageSize: pageSize,
      );

      // 添加交易记录
      transactions.addAll(result.transactions);

      // 更新是否有更多数据
      hasMore.value = result.hasMore;
    } catch (e) {
      Logger.e('Error loading more transactions: $e');
      Utils.showSnackbar('错误', '加载更多交易记录失败: $e', isError: true);

      // 恢复页码
      currentPage.value--;
    } finally {
      isLoading.value = false;
    }
  }

  /// 刷新交易记录
  Future<void> refreshTransactions() async {
    return loadTransactions();
  }
}
