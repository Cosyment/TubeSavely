import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:media_kit/media_kit.dart';
import 'package:tubesavely/pages/feedback_page.dart';
import 'package:tubesavely/pages/history_page.dart';
import 'package:tubesavely/pages/home_page.dart';
import 'package:tubesavely/pages/more_page.dart';
import 'package:tubesavely/pages/splash_page.dart';
import 'package:tubesavely/pages/task_page.dart';
import 'package:tubesavely/theme/app_theme.dart';
import 'package:tubesavely/widget/drawer_controller.dart';
import 'package:tubesavely/widget/slide_drawer.dart';

void main() async {
  await ScreenUtil.ensureScreenSize();
  _loadShader();
  MediaKit.ensureInitialized();
  runApp(const MyApp());
}

Future<void> _loadShader() async {
  return FragmentProgram.fromAsset('assets/shaders/shader.frag').then((FragmentProgram prgm) {
    SplashPage.shader = prgm.fragmentShader();
  }, onError: (Object error, StackTrace stackTrace) {});
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<StatefulWidget> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool isDarkMode = true;

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context, designSize: const Size(750, 1378));
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.black),
        useMaterial3: true,
      ),
      home: const SplashPage(),
    );
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
        systemNavigationBarColor: isLightMode ? AppTheme.nearlyWhite : AppTheme.nearlyBlack, statusBarColor: Colors.transparent));

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
