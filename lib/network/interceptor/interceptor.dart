import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';

import '../../utils/constants.dart';
import '../../utils/encrypted_util.dart';
import '../../utils/log_util.dart';
import 'error_handle.dart';

class AuthInterceptor extends Interceptor {
  AuthInterceptor();

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    // options.headers['Authorization'] = 'Bearer ${HttpUtils.token ?? ''}';
    var parameters = options.queryParameters;
    var createSign = EncryptedUtil.createSign(parameters);
    options.headers['userId'] = Constants.userId;
    options.headers['Sign'] = createSign;
    options.headers['UserAgent'] = 'mobile';
    options.headers['Channel'] = Constants.appChannelId;
    options.headers['ApiVersion'] = 'v1.0.0'; //服务端api版本号
    options.headers['PackageNames'] = 'com.xhx.video.saver';
    super.onRequest(options, handler);
  }
}

class LoggingInterceptor extends Interceptor {
  late DateTime startTime;
  late DateTime endTime;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    startTime = DateTime.now();
    Log.d('---------- Request Start ----------');
    if (options.queryParameters.isEmpty) {
      Log.d('RequestUrl: ${options.baseUrl}${options.path}');
    } else {
      Log.d('RequestUrl: ${options.baseUrl}${options.path}?${Transformer.urlEncodeMap(options.queryParameters)}');
    }
    Log.d('RequestMethod: ${options.method}');
    Log.d('RequestHeaders:${options.headers}');
    Log.d('RequestContentType: ${options.contentType}');
    Log.d('RequestData: ${options.data.toString()}');
    Log.d('---------- Request End ----------');
    super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    RequestOptions options = response.requestOptions;
    Log.d('---------- Response Start ----------');
    Log.d('ResponseUrl: ${options.baseUrl}${options.path}?${Transformer.urlEncodeMap(options.queryParameters)}');
    debugPrint(
        'ResponseUrl: ${options.baseUrl}${options.path}?${Transformer.urlEncodeMap(options.queryParameters)}  response=${response.data.toString()}');
    endTime = DateTime.now();
    int duration = endTime.difference(startTime).inMilliseconds;
    if (response.statusCode == ExceptionHandle.success) {
      Log.d('ResponseCode: ${response.statusCode}');
    } else {
      Log.e('ResponseCode: ${response.statusCode}');
    }
    if (response.data) {
      var data = json.decode(response.data.toString());
      if (data['err'] == 'Unauthorized' && data['code'] == 401) {
        // LoginState.loginOut();
        return;
      }
    }

    /// 输出结果
    /// Log.json(response.data.toString());
    /// print(response.data.toString());
    Log.d('---------- Response End: $duration 毫秒----------');
    super.onResponse(response, handler);
  }

  @override
  void onError(DioError err, ErrorInterceptorHandler handler) {
    Log.d('----------Error-----------');
    super.onError(err, handler);
  }
}
