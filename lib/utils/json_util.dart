import 'dart:convert';

import 'package:flutter/cupertino.dart';

extension MapExit on Map? {
  List<T>? asList<T>(String key, [Function(Map json)? toBean]) {
    try {
      Object? obj = this![key];
      if (toBean != null && obj != null) {
        if (obj is List) {
          return obj.map((v) => toBean(v)).toList().cast<T>();
        } else if (obj is String) {
          List list = jsonDecode(obj);
          return list.map((v) => toBean(v)).toList().cast<T>();
        }
      } else if (obj != null) {
        if (obj is List) {
          return List<T>.from(obj);
        } else if (obj is String) {
          List list0 = jsonDecode(obj);
          return List<T>.from(list0);
        }
      }
    } catch (e) {
      debugPrint(e.toString());
    }
    return null;
  }
}
