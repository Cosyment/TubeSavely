import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:media_kit/media_kit.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:tubesavely/screen/desktop/main.dart';
import 'package:tubesavely/screen/mobile/pages/feedback_page.dart';
import 'package:tubesavely/screen/mobile/pages/history_page.dart';
import 'package:tubesavely/screen/mobile/pages/home_page.dart';
import 'package:tubesavely/screen/mobile/pages/more_page.dart';
import 'package:tubesavely/screen/mobile/pages/splash_page.dart';
import 'package:tubesavely/screen/mobile/pages/task_page.dart';
import 'package:tubesavely/storage/storage.dart';
import 'package:tubesavely/theme/app_theme.dart';
import 'package:tubesavely/theme/theme_manager.dart';
import 'package:tubesavely/theme/theme_provider.dart';
import 'package:tubesavely/utils/platform_util.dart';
import 'package:tubesavely/widget/drawer_controller.dart';
import 'package:tubesavely/widget/slide_drawer.dart';
import 'package:window_manager/window_manager.dart';

import 'generated/l10n.dart';
import 'locale/locale_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Storage().init();
  if (PlatformUtil.isMobile) {
    await ScreenUtil.ensureScreenSize();
    MediaKit.ensureInitialized();
    runApp(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => ThemeManager.instance),
          ChangeNotifierProvider(create: (_) => LocaleManager.instance),
        ],
        child: const MyApp(),
      ),
    );
  } else {
    windowManager.ensureInitialized();
    WindowOptions windowOptions = WindowOptions(
      size: const Size(950, 650),
      minimumSize: const Size(800, 600),
      center: true,
      backgroundColor: Colors.transparent,
      windowButtonVisibility: true,
      skipTaskbar: false,
      titleBarStyle:
          PlatformUtil.isMacOS ? TitleBarStyle.hidden : TitleBarStyle.normal,
    );
    windowManager.waitUntilReadyToShow(windowOptions, () async {
      await windowManager.show();
      await windowManager.focus();
    });

    runApp(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => ThemeManager.instance),
          ChangeNotifierProvider(create: (_) => LocaleManager.instance),
        ],
        child: const DesktopApp(),
      ),
    );

    Future.delayed(const Duration(seconds: 20), () {
      _showAppReview();
    });
  }

  if (Storage().getString(StorageKeys.CACHE_DIR_KEY) == null) {
    Storage().set(StorageKeys.CACHE_DIR_KEY,
        (await getApplicationDocumentsDirectory()).path);
  }
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<StatefulWidget> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context, designSize: const Size(750, 1378));
    return Consumer2<ThemeManager, LocaleManager>(
        builder: (context, themeManager, localeManager, _) {
      return MaterialApp(
          debugShowCheckedModeBanner: false,
          themeMode: themeManager.currentTheme,
          theme: ThemeProvider.lightThemeData,
          darkTheme: ThemeProvider.darkThemeData,
          localeResolutionCallback: (locale, supportedLocales) {
            if (locale?.languageCode == 'en') {
              return const Locale('en', 'US');
            } else {
              return locale;
            }
          },
          locale: localeManager.locale,
          localizationsDelegates: const [
            S.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate
          ],
          supportedLocales: S.delegate.supportedLocales,
          builder: EasyLoading.init(),
          home: const SplashPage());
    });
  }
}

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  Widget? screenView;
  DrawerIndex? drawerIndex;

  @override
  void initState() {
    // SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    //     systemNavigationBarColor: Colors.transparent,
    //     statusBarColor: Colors.transparent));

    drawerIndex = DrawerIndex.Home;
    screenView = const HomePage();
    super.initState();
    Future.delayed(const Duration(milliseconds: 600), () {});
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context, designSize: const Size(750, 1378));
    var brightness = MediaQuery.of(context).platformBrightness;
    bool isLightMode = brightness == Brightness.light;
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
        systemNavigationBarColor:
            isLightMode ? AppTheme.nearlyWhite : AppTheme.nearlyBlack,
        statusBarColor: Colors.transparent));

    return SafeArea(
      top: false,
      bottom: false,
      child: Scaffold(
        body: CustomDrawerController(
          screenIndex: drawerIndex,
          drawerWidth: MediaQuery.of(context).size.width * 0.60,
          onDrawerCall: (DrawerIndex drawerIndexData) {
            changeIndex(drawerIndexData);
          },
          screenView: screenView,
        ),
      ),
    );
  }

  void changeIndex(DrawerIndex drawerIndexData) {
    if (drawerIndex != drawerIndexData) {
      drawerIndex = drawerIndexData;
      switch (drawerIndex) {
        case DrawerIndex.Home:
          setState(() {
            screenView = const HomePage();
          });
          break;
        case DrawerIndex.Task:
          setState(() {
            screenView = const TaskPage();
          });
        case DrawerIndex.History:
          setState(() {
            screenView = const HistoryPage();
          });
          break;
        // case DrawerIndex.Help:
        //   setState(() {
        //     screenView = const HelpPage();
        //   });
        //   break;
        case DrawerIndex.FeedBack:
          setState(() {
            screenView = const FeedbackPage();
          });
          break;
        // case DrawerIndex.Invite:
        //   setState(() {
        //     screenView = const InviteFriendPage();
        //   });
        //   break;
        // case DrawerIndex.Settings:
        //   setState(() {
        //     screenView = const SettingPage();
        //   });
        //   break;
        case DrawerIndex.More:
          setState(() {
            screenView = const MorePage();
          });
          break;
        default:
          break;
      }
    }
  }
}

void _showAppReview() async {
  if (!Storage().getBool(StorageKeys.SHOW_APPREVIEW_KEY) &&
      (PlatformUtil.isMobile || PlatformUtil.isMacOS)) {
    if (await InAppReview.instance.isAvailable()) {
      if (PlatformUtil.isIOS || PlatformUtil.isMacOS) {
        InAppReview.instance.openStoreListing(appStoreId: '6503423677');
      } else {
        InAppReview.instance.requestReview();
      }
      Storage().set(StorageKeys.SHOW_APPREVIEW_KEY, true);
    }
  }
}
