import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:media_kit/media_kit.dart';
import 'package:tubesavely/pages/feedback_page.dart';
import 'package:tubesavely/pages/help_page.dart';
import 'package:tubesavely/pages/history_page.dart';
import 'package:tubesavely/pages/home_page.dart';
import 'package:tubesavely/pages/invite_page.dart';
import 'package:tubesavely/pages/more_page.dart';
import 'package:tubesavely/pages/splash_page.dart';
import 'package:tubesavely/pages/task_page.dart';
import 'package:tubesavely/theme/app_theme.dart';
import 'package:tubesavely/widget/drawer_controller.dart';
import 'package:tubesavely/widget/slide_drawer.dart';

import 'generated/l10n.dart';

void main() async {
  await ScreenUtil.ensureScreenSize();
  _loadShader();
  MediaKit.ensureInitialized();
  runApp(const MyApp());

  // DbManager().createTable();
}

Future<void> _loadShader() async {
  return FragmentProgram.fromAsset('assets/shaders/shader.frag').then((FragmentProgram prgm) {
    SplashPage.shader = prgm.fragmentShader();
  }, onError: (Object error, StackTrace stackTrace) {
    FlutterError.reportError(FlutterErrorDetails(exception: error, stack: stackTrace));
  });
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<StatefulWidget> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool isDarkMode = true;

  @override
  void initState() {
    super.initState();
  }

  initTheme() async {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context, designSize: const Size(750, 1378));
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      localizationsDelegates: const [
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        S.delegate,
      ],
      supportedLocales: S.delegate.supportedLocales,
      home: const SplashPage(),
    );
  }
}

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> with WidgetsBindingObserver {
  late String title;
  var currentPageIndex = 0;

  Widget? screenView;
  DrawerIndex? drawerIndex;

  @override
  void dispose() {
    super.dispose();
    WidgetsBinding.instance.removeObserver(this);
  }

  @override
  void initState() {
    title = "TubeSavely";
    drawerIndex = DrawerIndex.Home;
    screenView = const HomePage();
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    Future.delayed(const Duration(milliseconds: 600), () {});
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && currentPageIndex == 0) {}
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context, designSize: const Size(750, 1378));
    var brightness = MediaQuery.of(context).platformBrightness;
    bool isLightMode = brightness == Brightness.light;
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
        systemNavigationBarColor: isLightMode ? AppTheme.nearlyWhite : AppTheme.nearlyBlack, statusBarColor: Colors.transparent));

    return SafeArea(
      top: false,
      bottom: false,
      child: Scaffold(
        // backgroundColor: AppTheme.white,
        body: CustomDrawerController(
          screenIndex: drawerIndex,
          drawerWidth: MediaQuery.of(context).size.width * 0.60,
          onDrawerCall: (DrawerIndex drawerIndexData) {
            changeIndex(drawerIndexData);
            //callback from drawer for replace screen as user need with passing DrawerIndex(Enum index)
          },
          screenView: screenView,
          //we replace screen view as we need on navigate starting screens like MyHomePage, HelpScreen, FeedbackScreen, etc...
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
        case DrawerIndex.Help:
          setState(() {
            screenView = const HelpPage();
          });
          break;
        case DrawerIndex.FeedBack:
          setState(() {
            screenView = const FeedbackPage();
          });
          break;
        case DrawerIndex.Invite:
          setState(() {
            screenView = const InviteFriendPage();
          });
          break;
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
