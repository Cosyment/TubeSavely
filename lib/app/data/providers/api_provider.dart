import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../../utils/constants.dart';
import '../../utils/logger.dart';

/// API提供者
///
/// 负责与后端API通信，提供各种API请求方法
class ApiProvider extends GetConnect {
  final GetStorage _storage = Get.find<GetStorage>();

  @override
  void onInit() {
    httpClient.baseUrl = Constants.API_BASE_URL;
    httpClient.timeout = const Duration(milliseconds: Constants.API_TIMEOUT);

    // 请求拦截器
    httpClient.addRequestModifier<dynamic>((request) {
      // 添加通用请求头
      request.headers['Accept'] = 'application/json';
      request.headers['Content-Type'] = 'application/json';

      // 添加认证令牌（如果有）
      final token = _storage.read<String>(Constants.STORAGE_USER_TOKEN);
      if (token != null && token.isNotEmpty) {
        request.headers['Authorization'] = 'Bearer $token';
      }

      return request;
    });

    // 响应拦截器
    httpClient.addResponseModifier<dynamic>((request, response) {
      // 处理响应
      if (response.status.isUnauthorized) {
        // 处理401未授权错误
        // 例如：清除本地令牌并重定向到登录页面
        _storage.remove(Constants.STORAGE_USER_TOKEN);
        Get.offAllNamed('/login');
      }

      return response;
    });

    super.onInit();
  }

  // ==================== 视频相关 ====================

  /// 解析视频链接
  ///
  /// [url] 视频链接
  Future<Response<dynamic>> parseVideo(String url) {
    Logger.d('Parsing video: $url');
    return get('/parse', query: {'url': url});
  }

  /// 获取视频信息
  ///
  /// [videoId] 视频ID
  Future<Response<dynamic>> getVideoInfo(String videoId) {
    Logger.d('Getting video info: $videoId');
    return get('/videos/$videoId');
  }

  /// 获取视频下载选项
  ///
  /// [videoId] 视频ID
  Future<Response<dynamic>> getVideoDownloadOptions(String videoId) {
    Logger.d('Getting video download options: $videoId');
    return get('/videos/$videoId/download-options');
  }

  // ==================== 用户相关 ====================

  /// 用户登录
  ///
  /// [email] 邮箱
  /// [password] 密码
  Future<Response<dynamic>> login(String email, String password) {
    Logger.d('User login: $email');
    return post('/auth/login', {
      'email': email,
      'password': password,
    });
  }

  /// 用户注册
  ///
  /// [email] 邮箱
  /// [password] 密码
  /// [name] 用户名
  Future<Response<dynamic>> register(
      String email, String password, String name) {
    Logger.d('User register: $email');
    return post('/auth/register', {
      'email': email,
      'password': password,
      'name': name,
    });
  }

  /// 获取用户信息
  Future<Response<dynamic>> getUserInfo() {
    Logger.d('Getting user info');
    return get('/user');
  }

  /// 获取下载历史
  Future<Response<dynamic>> getDownloadHistory() {
    Logger.d('Getting download history');
    return get('/downloads/history');
  }

  // ==================== 平台相关 ====================

  /// 获取支持的平台
  Future<Response<dynamic>> getSupportedPlatforms() {
    Logger.d('Getting supported platforms');
    return get('/platforms');
  }

  // ==================== 会员相关 ====================

  /// 获取会员套餐
  Future<Response<dynamic>> getMembershipPlans() {
    Logger.d('Getting membership plans');
    return get('/membership/plans');
  }

  /// 获取积分套餐
  Future<Response<dynamic>> getPointsPackages() {
    Logger.d('Getting points packages');
    return get('/points/packages');
  }

  // ==================== 订单相关 ====================

  /// 创建订单
  ///
  /// [packageId] 套餐ID
  /// [paymentMethod] 支付方式
  Future<Response<dynamic>> createOrder(
      String packageId, String paymentMethod) {
    Logger.d('Creating order: $packageId, $paymentMethod');
    return post('/orders', {
      'package_id': packageId,
      'payment_method': paymentMethod,
    });
  }

  /// 获取订单状态
  ///
  /// [orderId] 订单ID
  Future<Response<dynamic>> getOrderStatus(String orderId) {
    Logger.d('Getting order status: $orderId');
    return get('/orders/$orderId');
  }

  /// 验证支付
  ///
  /// [data] 支付验证数据
  Future<Response<dynamic>> verifyPayment(Map<String, dynamic> data) {
    Logger.d('Verifying payment');
    return post('/payment/verify', data);
  }

  /// 获取交易记录
  Future<Response<dynamic>> getTransactions() {
    Logger.d('Getting transactions');
    return get('/transactions');
  }
}
