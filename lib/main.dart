import 'package:animated_notch_bottom_bar/animated_notch_bottom_bar/animated_notch_bottom_bar.dart';
import 'package:downloaderx/pages/home_page.dart';
import 'package:downloaderx/pages/mine_page.dart';
import 'package:downloaderx/pages/push_stream_page.dart';
import 'package:downloaderx/pages/video_parse_page.dart';
import 'package:downloaderx/utils/pub_method.dart';
import 'package:downloaderx/widget/agreement_dialog.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';

import 'constants/colors.dart';
import 'generated/l10n.dart';

void main() async {
  await ScreenUtil.ensureScreenSize();
  runApp(const MyApp());
  AssetPicker.registerObserve();
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
        // scaffoldBackgroundColor: Colors.black,
        appBarTheme: AppBarTheme(
          centerTitle: true,
          color: primaryColor,
          iconTheme: const IconThemeData(
            color: Colors.white, // 设置AppBar返回按钮的颜色为红色
          ),
          titleTextStyle: TextStyle(
            color: Colors.white,
            fontSize: 20.sp,
          ),
        ),
      ),
      localizationsDelegates: const [
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        S.delegate,
      ],
      supportedLocales: S.delegate.supportedLocales,
      home: const MainPage(),
    );
  }
}

class MainPage extends StatefulWidget {
  const MainPage({Key? key}) : super(key: key);

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> with WidgetsBindingObserver {
  final _controller = NotchBottomBarController(index: 0);
  var currentPageIndex = 0;

  @override
  void dispose() {
    WidgetsBinding.instance?.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      getPaste();
    }
  }

  final List<Widget> bottomBarPages = [
    const HomePage(),
    const PushStreamPage(),
    const MinePage(),
  ];

  getPaste() async {
    ClipboardData? data = await Clipboard.getData(Clipboard.kTextPlain);
      if (data != null) {
        showCupertinoDialog(
          barrierDismissible: true,
          context: context,
          builder: (context) {
            return CupertinoAlertDialog(
              title: Text("提示"),
              content: Text("提取剪贴板中的链接吗？"),
              actions: [
                CupertinoDialogAction(
                  child: const Text("取消"),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                CupertinoDialogAction(
                  child: const Text("提取"),
                  onPressed: () {
                    Navigator.of(context).pop();
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => VideoParePage(
                                  link: data.text,
                                )));
                    Clipboard.setData(const ClipboardData(text: ''));
                  },
                ),
              ],
            );
          },
        );
      }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance?.addObserver(this);
    getPaste();
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
          color: Colors.white,
          showLabel: false,
          notchColor: Colors.white,
          removeMargins: false,
          bottomBarWidth: 50.w,
          durationInMilliSeconds: 300,
          bottomBarItems: const [
            BottomBarItem(
              inActiveItem: Icon(
                Icons.home_filled,
                color: Colors.grey,
              ),
              activeItem: Icon(
                Icons.home_filled,
                color: primaryColor,
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
                color: primaryColor,
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
                color: primaryColor,
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
