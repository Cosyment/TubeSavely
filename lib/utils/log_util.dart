import 'dart:convert' as convert;

import 'package:flutter/cupertino.dart';

/// 输出Log工具类
class Log {
  static const String tag = 'TubeSaverX-LOG';
  static bool _inProduction = true;

  static init(bool inProduction) {
    _inProduction = inProduction;
    // LogUtil.init(isDebug: !_inProduction);
  }

  static d(String msg, {tag = tag}) {
    if (!_inProduction) {
      // LogUtil.v(msg, tag: tag);
      debugPrint(msg);
    }
  }

  static e(String msg, {tag = tag}) {
    if (!_inProduction) {
      debugPrint(msg);
    }
  }

  static json(String msg, {tag = tag}) {
    if (!_inProduction) {
      var data = convert.json.decode(msg);
      if (data is Map) {
        _printMap(data);
      } else if (data is List) {
        _printList(data);
      } else {
        debugPrint(msg);
      }
    }
  }

  static void _printMap(Map data, {tag = tag, int tabs = 1, bool isListItem = false, bool isLast = false}) {
    final bool isRoot = tabs == 1;
    final initialIndent = _indent(tabs);
    tabs++;

    if (isRoot || isListItem) debugPrint('$initialIndent{');

    data.keys.toList().asMap().forEach((index, key) {
      final isLast = index == data.length - 1;
      var value = data[key];
      if (value is String) value = '"$value"';
      if (value is Map) {
        if (value.isEmpty) {
          debugPrint('${_indent(tabs)} $key: $value${!isLast ? ',' : ''}');
        } else {
          debugPrint('${_indent(tabs)} $key: {');
          _printMap(value, tabs: tabs);
        }
      } else if (value is List) {
        if (value.isEmpty) {
          debugPrint('${_indent(tabs)} $key: ${value.toString()}');
        } else {
          debugPrint('${_indent(tabs)} $key: [');
          _printList(value, tabs: tabs);
          debugPrint('${_indent(tabs)} ]${isLast ? '' : ','}');
        }
      } else {
        final msg = value.toString().replaceAll('\n', '');
        debugPrint('${_indent(tabs)} $key: $msg${!isLast ? ',' : ''}');
      }
    });

    debugPrint('$initialIndent}${isListItem && !isLast ? ',' : ''}');
  }

  static void _printList(List list, {tag = tag, int tabs = 1}) {
    list.asMap().forEach((i, e) {
      final isLast = i == list.length - 1;
      if (e is Map) {
        if (e.isEmpty) {
          debugPrint('${_indent(tabs)}  $e${!isLast ? ',' : ''}');
        } else {
          _printMap(e, tabs: tabs + 1, isListItem: true, isLast: isLast);
        }
      } else {
        debugPrint('${_indent(tabs + 2)} $e${isLast ? '' : ','}');
      }
    });
  }

  static String _indent([int tabCount = 1]) => '  ' * tabCount;
}
