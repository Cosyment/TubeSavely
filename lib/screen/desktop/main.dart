import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:tubesavely/screen/desktop/pages/about_page.dart';
import 'package:tubesavely/screen/desktop/pages/home_page.dart';
import 'package:tubesavely/screen/desktop/pages/setting_page.dart';
import 'package:tubesavely/screen/desktop/widget/desktop_dialog_wrapper.dart';

import '../../theme/app_theme.dart';

class DesktopApp extends StatefulWidget {
  const DesktopApp({super.key});

  @override
  State<StatefulWidget> createState() => _DesktopAppState();
}

class _DesktopAppState extends State<DesktopApp> {
  @override
  Widget build(BuildContext context) {
    var brightness = MediaQuery.of(context).platformBrightness;
    bool isLightMode = brightness == Brightness.light;
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      color: isLightMode ? AppTheme.nearlyWhite : AppTheme.nearlyBlack,
      builder: EasyLoading.init(),
      home: const HomePage(),
    );
  }
}

showSettingDialog(BuildContext context) {
  return showAdaptiveDialog(
      context: context,
      builder: (context) {
        return const DesktopDialogWrapper(child: SettingPage());
      });
}

showAppAboutDialog(BuildContext context) {
  return showAdaptiveDialog(
    context: context,
    builder: (BuildContext context) {
      return const DesktopDialogWrapper(
        width: 350,
        child: AboutPage(),
      );
    },
  );
}
