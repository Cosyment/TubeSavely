import 'package:flutter/foundation.dart';

/// 开发工具类
///
/// 提供与开发相关的工具方法
class DevUtils {
  DevUtils._();

  /// 是否处于开发模式
  ///
  /// 在以下情况下返回true：
  /// 1. 在调试模式下运行（kDebugMode）
  /// 2. 在配置文件中明确设置为开发模式
  static bool get isDevMode {
    // 在调试模式下始终返回true
    if (kDebugMode) {
      return true;
    }

    // 在发布模式下，可以通过配置文件来控制是否启用开发模式
    // 这里可以添加其他判断逻辑，例如读取配置文件或环境变量
    return false;
  }
}
