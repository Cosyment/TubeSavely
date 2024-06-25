import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shake_animation_widget/shake_animation_widget.dart';
import 'package:tubesavely/generated/l10n.dart';
import 'package:tubesavely/screen/mobile/pages/video_detail_page.dart';
import 'package:tubesavely/theme/app_theme.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  TextEditingController textController = TextEditingController(text: ''
      // 'https://www.youtube.com/watch?v=Ek1QD7AH9XQ' //1080P
      // 'https://www.youtube.com/watch?v=k7dy1B6bOeM' // 4K
      // 'https://www.youtube.com/watch?v=Mi2vTUtKMOg' //8K
      // 'https://www.facebook.com/100000124835838/videos/329176782997696/'
      // 'https://www.tiktok.com/t/ZTRC5xgJp'
      // 'https://m.acfun.cn/v/?ac=39091936&sid=bf02f7d348c84918'
      // 'http://xhslink.com/L8Qwiw'
      // 'https://www.xiaohongshu.com/explore/662b0d07000000000d03227c'
      // 'https://www.kuaishou.com/f/X3WcgZrbGXVcWWa'
      // 'https://www.bilibili.com/video/BV1kf421S7WH/?share_source=copy_web'
      // 'https://www.douyin.com/video/6961737553342991651'
      );

  final ShakeAnimationController _shakeAnimationController = ShakeAnimationController();

  @override
  void initState() {
    super.initState();

    startShake();
  }

  void startShake() async {
    Future.delayed(const Duration(seconds: 1), () async {
      _shakeAnimationController.start(shakeCount: 1);
      await Future.delayed(const Duration(milliseconds: 2500));
      startShake();
    });
    // Future.delayed(const Duration(seconds: 3), () => {startShake()});
  }

  @override
  Widget build(BuildContext context) {
    var brightness = MediaQuery.of(context).platformBrightness;
    bool isLightMode = brightness == Brightness.light;
    return Container(
        color: isLightMode ? AppTheme.nearlyWhite : AppTheme.nearlyBlack,
        child: SafeArea(
            top: false,
            bottom: false,
            child: Scaffold(
              appBar: AppBar(
                leading: const SizedBox(width: 50),
                backgroundColor: isLightMode ? AppTheme.nearlyWhite : AppTheme.nearlyBlack,
                title: Text(
                  S.current.appName,
                  style: TextStyle(color: isLightMode ? AppTheme.nearlyBlack : AppTheme.white),
                ),
              ),
              backgroundColor: isLightMode ? AppTheme.white : AppTheme.nearlyBlack,
              body: CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: Container(
                      margin: EdgeInsets.all(0.w),
                      child: ClipRRect(
                        child: Container(
                          padding: const EdgeInsets.only(top: 0, left: 16, right: 16),
                          child: Image.asset('assets/images/ic_help.png'),
                        ),
                      ).animate().effect(duration: 3000.ms).effect(delay: 750.ms, duration: 1500.ms).shimmer(),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: _buildInputBox(),
                  ),
                  SliverToBoxAdapter(
                    child: _buildButton(),
                    // child: _buildDownloadButton(),
                  ),
                ],
              ),
            )));
  }

  Widget _buildButton() {
    return ShakeAnimationWidget(
        //抖动控制器
        shakeAnimationController: _shakeAnimationController,
        //微旋转的抖动
        shakeAnimationType: ShakeAnimationType.RoateShake,
        //设置不开启抖动
        isForward: false,
        //默认为 0 无限执行
        shakeCount: 0,
        //抖动的幅度 取值范围为[0,1]
        shakeRange: 0.03,
        //执行抖动动画的子Widget
        child: Container(
            padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 60),
            child: MaterialButton(
              padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 10),
              elevation: 20,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(50), side: const BorderSide(color: Colors.transparent, width: 0)),
              color: AppTheme.accentColor,
              onPressed: () {
                startParse();
              },
              child: const Text(
                'Get Video',
                style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w700),
              ),
            )));
  }

  Widget _buildInputBox() {
    return Padding(
      padding: const EdgeInsets.only(top: 16, left: 32, right: 32),
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.white,
          borderRadius: BorderRadius.circular(50),
          boxShadow: <BoxShadow>[
            BoxShadow(color: Colors.grey.withOpacity(0.3), offset: const Offset(4, 4), blurRadius: 30),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(25),
          child: Container(
            padding: const EdgeInsets.all(4.0),
            color: AppTheme.white,
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(left: 10, right: 10, top: 0, bottom: 0),
              child: TextField(
                maxLines: 1,
                controller: textController,
                onChanged: (String text) {},
                textInputAction: TextInputAction.done,
                onSubmitted: (value) => startParse(),
                style: const TextStyle(
                  fontFamily: AppTheme.fontName,
                  fontSize: 16,
                  color: AppTheme.dark_grey,
                ),
                cursorColor: Colors.blue,
                decoration: const InputDecoration(border: InputBorder.none, hintText: 'Type Video URL...'),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> startParse() async {
    var parseUrl = textController.text;
    Match? match = RegExp(r'http[s]?:\/\/[\w.]+[\w/]*[\w.]*\??[\w=&:\-+%]*[/]*').firstMatch(parseUrl);
    var url = match?.group(0) ?? '';
    if (!url.contains('http')) {
      return;
    }

    Navigator.push(
      context,
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 300),
        pageBuilder: (BuildContext context, _, __) => VideoDetailPage(url: url),
        transitionsBuilder:
            (BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation, Widget child) {
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0.0, 1.0),
              end: Offset.zero, // 结束位置在屏幕原点
            ).animate(animation),
            child: child,
          );
        },
      ),
    );
  }
}
