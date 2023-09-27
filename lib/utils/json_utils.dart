import 'dart:convert';

extension MapExit on Map? {
  List<T>? asList<T>(String key, [Function(Map json)? toBean]) {
    try {
      Object? obj = this![key];
      if (toBean != null && obj != null) {
        if (obj is List) {
          return obj.map((v) => toBean(v)).toList().cast<T>();
        } else if (obj is String) {
          List _list = jsonDecode(obj);
          return _list.map((v) => toBean(v)).toList().cast<T>();
        }
      } else if (obj != null) {
        if (obj is List) {
          return List<T>.from(obj);
        } else if (obj is String) {
          List _list = jsonDecode(obj);
          return List<T>.from(_list);
        }
      }
    } catch (e) {
      print(e);
    }
    return null;
  }
}
