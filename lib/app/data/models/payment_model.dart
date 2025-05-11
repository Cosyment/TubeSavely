import 'package:flutter/foundation.dart';

/// 支付方式枚举
enum PaymentMethod {
  applePay,
  googlePay,
  stripe,
  alipay,
  wechatPay,
}

/// 商品类型枚举
enum ProductType {
  membership, // 会员
  points, // 积分
  feature, // 功能
}

/// 商品模型
class ProductModel {
  final String id;
  final String title;
  final String description;
  final double price;
  final String currency;
  final ProductType type;
  final Map<String, dynamic>? metadata;

  ProductModel({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.currency,
    required this.type,
    this.metadata,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      price: json['price'].toDouble(),
      currency: json['currency'],
      type: ProductType.values.firstWhere(
        (e) => e.toString().split('.').last == json['type'],
        orElse: () => ProductType.points,
      ),
      metadata: json['metadata'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'price': price,
      'currency': currency,
      'type': type.toString().split('.').last,
      'metadata': metadata,
    };
  }
}

/// 订单模型
class OrderModel {
  final String id;
  final String productId;
  final String userId;
  final double amount;
  final String currency;
  final String status; // pending, completed, failed, canceled
  final PaymentMethod paymentMethod;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final DateTime? completedAt;
  final String? transactionId;
  final String? errorMessage;

  OrderModel({
    required this.id,
    required this.productId,
    required this.userId,
    required this.amount,
    required this.currency,
    required this.status,
    required this.paymentMethod,
    required this.createdAt,
    this.updatedAt,
    this.completedAt,
    this.transactionId,
    this.errorMessage,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: json['id'],
      productId: json['product_id'],
      userId: json['user_id'],
      amount: json['amount'].toDouble(),
      currency: json['currency'],
      status: json['status'],
      paymentMethod: PaymentMethod.values.firstWhere(
        (e) => e.toString().split('.').last == json['payment_method'],
        orElse: () => PaymentMethod.stripe,
      ),
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
      completedAt: json['completed_at'] != null
          ? DateTime.parse(json['completed_at'])
          : null,
      transactionId: json['transaction_id'],
      errorMessage: json['error_message'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'product_id': productId,
      'user_id': userId,
      'amount': amount,
      'currency': currency,
      'status': status,
      'payment_method': paymentMethod.toString().split('.').last,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'completed_at': completedAt?.toIso8601String(),
      'transaction_id': transactionId,
      'error_message': errorMessage,
    };
  }
}
