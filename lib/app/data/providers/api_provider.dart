import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import '../../utils/constants.dart';

class ApiProvider extends GetConnect {
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
      final token = Get.find<GetStorage>().read<String>(Constants.STORAGE_USER_TOKEN);
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
        Get.find<GetStorage>().remove(Constants.STORAGE_USER_TOKEN);
        Get.offAllNamed('/login');
      }

      return response;
    });
  }

  // 解析视频链接
  Future<Response> parseVideo(String url) {
    return get('/parse', query: {'url': url});
  }

  // 获取用户信息
  Future<Response> getUserInfo() {
    return get('/user');
  }

  // 获取下载历史
  Future<Response> getDownloadHistory() {
    return get('/downloads/history');
  }

  // 获取支持的平台
  Future<Response> getSupportedPlatforms() {
    return get('/platforms');
  }

  // 获取会员套餐
  Future<Response> getMembershipPlans() {
    return get('/membership/plans');
  }

  // 验证支付
  Future<Response> verifyPayment(Map<String, dynamic> data) {
    return post('/payment/verify', data);
  }
}
