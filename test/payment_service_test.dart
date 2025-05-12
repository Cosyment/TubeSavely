import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:tubesavely/app/data/models/payment_model.dart';
import 'package:tubesavely/app/data/providers/api_provider.dart';
import 'package:tubesavely/app/data/providers/storage_provider.dart';
import 'package:tubesavely/app/services/apple_payment_service.dart';
import 'package:tubesavely/app/services/payment_service.dart';
import 'package:tubesavely/app/services/stripe_service.dart';

// 生成Mock类
@GenerateNiceMocks([
  MockSpec<ApiProvider>(),
  MockSpec<StorageProvider>(),
  MockSpec<StripeService>(),
  MockSpec<ApplePaymentService>(),
])
import 'payment_service_test.mocks.dart';

void main() {
  late PaymentService paymentService;
  late MockApiProvider mockApiProvider;
  late MockStorageProvider mockStorageProvider;
  late MockStripeService mockStripeService;
  late MockApplePaymentService mockApplePaymentService;

  setUp(() {
    // 初始化Mock对象
    mockApiProvider = MockApiProvider();
    mockStorageProvider = MockStorageProvider();
    mockStripeService = MockStripeService();
    mockApplePaymentService = MockApplePaymentService();

    // 设置Mock对象的基本行为
    when(mockApiProvider.onInit()).thenReturn(null);
    when(mockStorageProvider.onInit()).thenReturn(null);
    when(mockStripeService.onInit()).thenReturn(null);
    when(mockApplePaymentService.onInit()).thenReturn(null);

    // 设置onStart方法的stub
    when(mockApiProvider.onStart).thenReturn(null);
    when(mockStorageProvider.onStart).thenReturn(null);
    when(mockStripeService.onStart).thenReturn(null);
    when(mockApplePaymentService.onStart).thenReturn(null);

    when(mockStripeService.isInitialized).thenReturn(true);
    when(mockApplePaymentService.isAvailable).thenReturn(RxBool(true));

    // 将Mock对象放入Get依赖注入容器
    Get.put<ApiProvider>(mockApiProvider, permanent: true);
    Get.put<StorageProvider>(mockStorageProvider, permanent: true);
    Get.put<StripeService>(mockStripeService, permanent: true);
    Get.put<ApplePaymentService>(mockApplePaymentService, permanent: true);

    // 初始化支付服务
    paymentService = PaymentService();
  });

  tearDown(() {
    // 清理Get依赖注入容器
    Get.reset();
  });

  group('PaymentService Tests', () {
    test('loadProducts should load products from API', () async {
      // 准备测试数据
      final mockResponse = Response(
        statusCode: 200,
        body: [
          {
            'id': 'product_1',
            'title': 'Test Product 1',
            'description': 'Test Description 1',
            'price': 9.99,
            'currency': 'USD',
            'type': 'points',
            'metadata': {'points': 100},
          },
          {
            'id': 'product_2',
            'title': 'Test Product 2',
            'description': 'Test Description 2',
            'price': 19.99,
            'currency': 'USD',
            'type': 'membership',
            'metadata': {'duration': 30},
          },
        ],
      );

      // 设置Mock行为
      when(mockApiProvider.getPointsPackages())
          .thenAnswer((_) async => mockResponse);

      // 执行测试
      await paymentService.loadProducts();

      // 验证结果
      expect(paymentService.products.length, 2);
      expect(paymentService.products[0].id, 'product_1');
      expect(paymentService.products[0].title, 'Test Product 1');
      expect(paymentService.products[0].price, 9.99);
      expect(paymentService.products[0].type, ProductType.points);
      expect(paymentService.products[1].id, 'product_2');
      expect(paymentService.products[1].title, 'Test Product 2');
      expect(paymentService.products[1].price, 19.99);
      expect(paymentService.products[1].type, ProductType.membership);

      // 验证Mock方法被调用
      verify(mockApiProvider.getPointsPackages()).called(1);
    });

    test('createOrder should create an order', () async {
      // 准备测试数据
      final mockResponse = Response(
        statusCode: 200,
        body: {
          'id': 'order_1',
          'product_id': 'product_1',
          'user_id': 'user_1',
          'amount': 9.99,
          'currency': 'USD',
          'status': 'pending',
          'payment_method': 'stripe',
          'created_at': DateTime.now().toIso8601String(),
        },
      );

      // 设置Mock行为
      when(mockApiProvider.createOrder('product_1', 'stripe'))
          .thenAnswer((_) async => mockResponse);

      // 执行测试
      final order =
          await paymentService.createOrder('product_1', PaymentMethod.stripe);

      // 验证结果
      expect(order, isNotNull);
      expect(order?.id, 'order_1');
      expect(order?.productId, 'product_1');
      expect(order?.userId, 'user_1');
      expect(order?.amount, 9.99);
      expect(order?.currency, 'USD');
      expect(order?.status, 'pending');
      expect(order?.paymentMethod, PaymentMethod.stripe);

      // 验证Mock方法被调用
      verify(mockApiProvider.createOrder('product_1', 'stripe')).called(1);
    });

    test('processPayment with Stripe should call StripeService', () async {
      // 准备测试数据
      final order = OrderModel(
        id: 'order_1',
        productId: 'product_1',
        userId: 'user_1',
        amount: 9.99,
        currency: 'USD',
        status: 'pending',
        paymentMethod: PaymentMethod.stripe,
        createdAt: DateTime.now(),
      );

      // 设置Mock行为
      when(mockStripeService.isInitialized).thenReturn(true);
      when(mockStripeService.processPayment(order))
          .thenAnswer((_) async => true);

      // 执行测试
      final result = await paymentService.processPayment(order);

      // 验证结果
      expect(result, true);

      // 验证Mock方法被调用
      verify(mockStripeService.processPayment(order)).called(1);
    });

    test('processPayment with Apple Pay should call ApplePaymentService',
        () async {
      // 准备测试数据
      final order = OrderModel(
        id: 'order_1',
        productId: 'product_1',
        userId: 'user_1',
        amount: 9.99,
        currency: 'USD',
        status: 'pending',
        paymentMethod: PaymentMethod.applePay,
        createdAt: DateTime.now(),
      );

      // 设置Mock行为
      when(mockApplePaymentService.isAvailable).thenReturn(RxBool(true));
      when(mockApplePaymentService.processPayment(order,
              callback: anyNamed('callback')))
          .thenAnswer((_) async => true);

      // 执行测试
      final result = await paymentService.processPayment(order);

      // 验证结果
      expect(result, true);

      // 验证Mock方法被调用
      verify(mockApplePaymentService.processPayment(order,
              callback: anyNamed('callback')))
          .called(1);
    });
  });
}
