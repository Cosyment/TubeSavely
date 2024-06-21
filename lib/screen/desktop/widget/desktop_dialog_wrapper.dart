import 'package:flutter/material.dart';
import 'package:tubesavely/utils/platform_util.dart';
import 'package:window_manager/window_manager.dart';

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
    Brightness brightness = MediaQuery.of(context).platformBrightness;
    return Dialog(
        child: Container(
            constraints: BoxConstraints(minWidth: 350, maxWidth: width),
            padding: const EdgeInsets.only(left: 0, right: 0, bottom: 10),
            clipBehavior: Clip.antiAlias,
            decoration:
                BoxDecoration(borderRadius: BorderRadius.circular(10), color: Theme.of(context).colorScheme.surfaceContainer),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: PlatformUtil.isMacOS ? MainAxisAlignment.start : MainAxisAlignment.end,
                  children: [
                    WindowCaptionButton.close(
                      brightness: brightness,
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
