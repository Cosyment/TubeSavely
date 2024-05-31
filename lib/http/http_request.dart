import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;

import '../utils/constants.dart';
import 'extend_http_client.dart';

class HttpRequest {
  static final SafeHttpClient _httpClient = SafeHttpClient(http.Client());

  static Future<dynamic> request<T>(String url, T Function(dynamic) fromJson,
      {method = 'GET', Map<String, dynamic>? params, Function(Object)? exception}) async {
    var headers = {'platform': 'ios'};
    http.Response? response;

    String errorMessage = '';
    try {
      if (method == 'GET') {
        response = await _httpClient.get(Uri.https(Urls.hostname, url, params), headers: headers);
      }
      if (method == 'POST') {
        response = await _httpClient.post(Uri.https(Urls.hostname, url), headers: headers, body: params);
      }
      debugPrint("request url： ${response?.request?.url} \nheaders：${response?.headers} \nparams：$params");

      Utf8Decoder decoder = const Utf8Decoder();
      var content = jsonDecode(decoder.convert(response!.bodyBytes));
      debugPrint("response： $content");
      errorMessage = content['msg'];
      var data = content['data'];
      if (content['code'] == 200 && data != null) {
        if (data is List) {
          return List<T>.from(data.map((e) => fromJson(e)));
        } else {
          return fromJson(data);
        }
      } else {
        return fromJson('');
      }
    } catch (e) {
      debugPrint(e.toString());
      errorMessage = 'server internal exception';
      exception?.call(e);
    }
    throw Exception(errorMessage);
  }
}
