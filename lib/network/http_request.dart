import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;

import '../utils/constants.dart';
import '../utils/encrypted_util.dart';
import 'extend_http_client.dart';

class HttpRequest {
  static final SafeHttpClient _httpClient = SafeHttpClient(http.Client());

  static Future<dynamic> request<T>(String url, T Function(dynamic) fromJson,
      {method = 'GET', Map<String, dynamic>? params, Function(Object)? exception}) async {
    var headers = {'Sign': EncryptedUtil.createSign(params ?? <String, String>{})};
    http.Response? response;

    String errorMessage = '';
    try {
      if (method == 'GET') {
        response = await _httpClient.get(Uri.http(Urls.hostname, url, params), headers: headers);
      } else {
        response = await _httpClient.post(Uri.https(Urls.hostname, url), headers: headers, body: params);
      }
      debugPrint("request url： ${response.request?.url} \nheaders：${response.headers} \nparams：${params}");

      Utf8Decoder decoder = const Utf8Decoder();
      var content = jsonDecode(decoder.convert(response.bodyBytes));
      debugPrint("response： ${content}");
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
      print(e);
      errorMessage = 'server internal exception';
      exception?.call(e);
    }
    throw Exception(errorMessage);
  }

  static Future<Map<String, dynamic>> requestJson(String url, {method = 'GET', Map<String, dynamic>? params}) async {
    Uri uri = Uri.parse(url);
    var headers = {'Content-Type': 'application/json'};
    http.Response? response;
    if (method == 'GET') {
      response = await _httpClient.get(uri, headers: headers);
    } else {
      response = await _httpClient.post(uri, headers: headers, body: params);
    }
    if (response.statusCode == 200) {
      Utf8Decoder decoder = const Utf8Decoder();
      return jsonDecode(decoder.convert(response.bodyBytes));
    } else {
      print('Request failed with status: ${response.statusCode}.');
      return {};
    }
  }
}
