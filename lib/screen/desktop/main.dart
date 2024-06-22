import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:tubesavely/generated/l10n.dart';
import 'package:tubesavely/screen/desktop/pages/about_page.dart';
import 'package:tubesavely/screen/desktop/pages/home_page.dart';
import 'package:tubesavely/screen/desktop/pages/setting_page.dart';
import 'package:tubesavely/screen/desktop/widget/desktop_dialog_wrapper.dart';
import 'package:tubesavely/theme/theme_manager.dart';
import 'package:tubesavely/theme/theme_provider.dart';

class DesktopApp extends StatefulWidget {
  const DesktopApp({super.key});

  @override
  State<StatefulWidget> createState() => _DesktopAppState();
}

class _DesktopAppState extends State<DesktopApp> {
  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (context, themeManager, _) {
      final themeManager = Provider.of<ThemeManager>(context);
      // final localeModel = Provider.of<LocaleModel>(context);
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        themeMode: themeManager.currentTheme,
        theme: ThemeProvider.lightThemeData,
        darkTheme: ThemeProvider.darkThemeData,
        localizationsDelegates: const [
          S.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate
        ],
        supportedLocales: S.delegate.supportedLocales,
        builder: EasyLoading.init(),
        home: const HomePage(),
      );
    });
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
