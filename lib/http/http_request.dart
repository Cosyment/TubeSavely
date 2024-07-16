import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:tubesavely/http/request_exception.dart';

import '../utils/constants.dart';
import 'extend_http_client.dart';

class HttpRequest {
  static final SafeHttpClient _httpClient = SafeHttpClient(http.Client());

  static Future<dynamic> request<T>(String url, T Function(dynamic) fromJson,
      {method = 'GET', Map<String, dynamic>? params, Function(RequestException)? exception}) async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    var headers = {
      'appName': packageInfo.appName,
      'platform': Platform.operatingSystem,
      'version': packageInfo.version,
      'buildNumber': packageInfo.buildNumber,
      // 'systemVersion': Platform.operatingSystemVersion,
    };
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

      if (content['code'] == 200) {
        var data = content['data'];
        if (data is List) {
          return List<T>.from(data.map((e) => fromJson(e)));
        } else {
          return fromJson(data);
        }
      } else {
        exception?.call(RequestException(content['code'], errorMessage));
      }
    } catch (e) {
      debugPrint(e.toString());
      errorMessage = 'server internal exception';
      exception?.call(RequestException(-1, errorMessage));
    }
  }
}
