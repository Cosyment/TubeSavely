import 'dart:ui';

import 'package:animated_notch_bottom_bar/animated_notch_bottom_bar/animated_notch_bottom_bar.dart';
import 'package:downloaderx/pages/home_page.dart';
import 'package:downloaderx/pages/mine_page.dart';
import 'package:downloaderx/pages/push_stream_page.dart';
import 'package:downloaderx/pages/splash_page.dart';
import 'package:downloaderx/utils/event_bus.dart';
import 'package:downloaderx/utils/exit.dart';
import 'package:downloaderx/utils/pub_method.dart';
import 'package:downloaderx/widget/agreement_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';

import 'data/local_storage_service.dart';
import 'generated/l10n.dart';

void main() async {
  await ScreenUtil.ensureScreenSize();
  _loadShader();
  runApp(MyApp());
  AssetPicker.registerObserve();
  LocalStorageService().init();
}

Future<void> _loadShader() async {
  return FragmentProgram.fromAsset('assets/shaders/shader.frag').then(
      (FragmentProgram prgm) {
    SplashPage.shader = prgm.fragmentShader();
  }, onError: (Object error, StackTrace stackTrace) {
    FlutterError.reportError(
        FlutterErrorDetails(exception: error, stack: stackTrace));
  });
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool isDarkMode = true;

  @override
  void initState() {
    super.initState();
    initTheme();
    EventBus.getDefault().register(this, (event) {
      print(">>>>>EventBus>>>>initState>>${isDarkMode}");
      initTheme();
    });
  }

  initTheme() async {
    isDarkMode = await ThemeExit.isDark();
    setState(() {});
  }

  @override
  void dispose() {
    super.dispose();
    EventBus.getDefault().unregister(this);
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context, designSize: const Size(750, 1378));
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeExit.get(isDarkMode),
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
  const MainPage({Key? key}) : super(key: key);

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  final _controller = NotchBottomBarController(index: 0);
  var currentPageIndex = 0;

  @override
  void dispose() {
    super.dispose();
  }

  final List<Widget> bottomBarPages = [
    const HomePage(),
    const PushStreamPage(),
    const MinePage(),
  ];

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 600), () {
      PubMethodUtils.getSharedPreferences("isAgree").then((value) {
        if (value == null) {
          showGeneralDialog(
              context: context,
              barrierDismissible: false,
              barrierLabel: '',
              transitionDuration: const Duration(milliseconds: 400),
              pageBuilder: (BuildContext context, Animation<double> animation,
                  Animation<double> secondaryAnimation) {
                return AgreementDialog(onAgreeClick: onAgreeClick);
              });
        } else {
          PubMethodUtils.umengCommonSdkInit();
        }
      });
    });
  }

  void onAgreeClick() {
    PubMethodUtils.putSharedPreferences("isAgree", "1");
    PubMethodUtils.umengCommonSdkInit();
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context, designSize: const Size(750, 1378));
    return Scaffold(
        resizeToAvoidBottomInset: false,
        body: IndexedStack(
          index: currentPageIndex,
          children: List.generate(
              bottomBarPages.length, (index) => bottomBarPages[index]),
        ),
        extendBody: true,
        bottomNavigationBar: AnimatedNotchBottomBar(
          notchBottomBarController: _controller,
          color: Theme.of(context).scaffoldBackgroundColor,
          showLabel: false,
          notchColor: Theme.of(context).scaffoldBackgroundColor,
          removeMargins: false,
          bottomBarWidth: 0,
          durationInMilliSeconds: 300,
          bottomBarItems: const [
            BottomBarItem(
              inActiveItem: Icon(
                Icons.home_filled,
                color: Colors.grey,
              ),
              activeItem: Icon(
                Icons.home_filled,
                color: Colors.grey,
              ),
              itemLabel: 'Page 1',
            ),
            BottomBarItem(
              inActiveItem: Icon(
                Icons.video_call_sharp,
                color: Colors.grey,
              ),
              activeItem: Icon(
                Icons.video_call_sharp,
                color: Colors.grey,
              ),
              itemLabel: 'Page 2',
            ),
            BottomBarItem(
              inActiveItem: Icon(
                Icons.person,
                color: Colors.grey,
              ),
              activeItem: Icon(
                Icons.person,
                color: Colors.grey,
              ),
              itemLabel: 'Page 3',
            ),
          ],
          onTap: (index) {
            currentPageIndex = index;
            setState(() {});
          },
        ));
  }
}
