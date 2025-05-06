import 'package:flutter/foundation.dart';

class Logger {
  static const String _tag = 'TubeSavely';
  static bool _isEnabled = true;

  /// 启用日志
  static void enable() {
    _isEnabled = true;
  }

  /// 禁用日志
  static void disable() {
    _isEnabled = false;
  }

  /// 打印调试日志
  static void d(String message, {String? tag}) {
    _log('DEBUG', message, tag);
  }

  /// 打印信息日志
  static void i(String message, {String? tag}) {
    _log('INFO', message, tag);
  }

  /// 打印警告日志
  static void w(String message, {String? tag}) {
    _log('WARN', message, tag);
  }

  /// 打印错误日志
  static void e(String message, {String? tag, dynamic error, StackTrace? stackTrace}) {
    _log('ERROR', message, tag);
    if (error != null) {
      _log('ERROR', 'Error: $error', tag);
    }
    if (stackTrace != null) {
      _log('ERROR', 'StackTrace: $stackTrace', tag);
    }
  }

  /// 打印日志
  static void _log(String level, String message, String? tag) {
    if (!_isEnabled) return;
    if (kDebugMode) {
      final now = DateTime.now();
      final timeString = '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}.${now.millisecond.toString().padLeft(3, '0')}';
      final logTag = tag ?? _tag;
      print('$timeString [$level] [$logTag] $message');
    }
  }
}
