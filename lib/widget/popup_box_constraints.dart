import 'package:flutter/rendering.dart';
import 'package:tubesavely/utils/platform_util.dart';

class PopupBoxConstraints extends BoxConstraints {
  static BoxConstraints custom({double? width, double? height}) {
    return BoxConstraints(
      minWidth: width ?? (PlatformUtil.isMobile ? 300.0 : 450.0),
      maxWidth: width ?? (PlatformUtil.isMobile ? 300.0 : 450.0),
      minHeight: height ?? (PlatformUtil.isMobile ? 50.0 : 100.0),
      maxHeight: height ?? (PlatformUtil.isMobile ? 180.0 : 230.0),
    );
  }
}
