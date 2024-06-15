import 'package:flutter/material.dart';
import 'package:tubesavely/utils/platform_util.dart';
import 'package:window_manager/window_manager.dart';

import '../../../theme/app_theme.dart';

class DesktopDialogWrapper extends StatelessWidget {
  const DesktopDialogWrapper({
    super.key,
    required this.child,
    this.width = 450,
  });

  final Widget child;
  final double width;

  @override
  Widget build(BuildContext context) {
    var brightness = MediaQuery.of(context).platformBrightness;
    bool isLightMode = brightness == Brightness.light;

    return Dialog(
        child: Container(
            constraints: BoxConstraints(minWidth: 350, maxWidth: width),
            padding: const EdgeInsets.only(left: 0, right: 0, bottom: 10),
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10), color: isLightMode ? AppTheme.nearlyWhite : AppTheme.nearlyBlack),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: PlatformUtil.isMacOS ? MainAxisAlignment.start : MainAxisAlignment.end,
                  children: [
                    WindowCaptionButton.close(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                  child: child,
                )
              ],
            )));
  }
}
