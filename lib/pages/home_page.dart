import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:tubesaverx/pages/video_detail_page.dart';

import '../app_theme.dart';
import '../generated/l10n.dart';
import '../utils/event_bus.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  TextEditingController textController = TextEditingController(
      text:
          // 'https://www.youtube.com/watch?v=Ek1QD7AH9XQ' //1080P
          // 'https://www.youtube.com/watch?v=k7dy1B6bOeM' // 4K
          // 'https://www.youtube.com/watch?v=Mi2vTUtKMOg' //8K
          // 'https://www.facebook.com/100000124835838/videos/329176782997696/'
          //  'https://www.tiktok.com/t/ZTRC5xgJp'
          // 'https://m.acfun.cn/v/?ac=39091936&sid=bf02f7d348c84918'
          // 'http://xhslink.com/L8Qwiw'
          // 'https://www.xiaohongshu.com/explore/662b0d07000000000d03227c'
          // 'https://www.kuaishou.com/f/X3WcgZrbGXVcWWa'
          // 'https://www.bilibili.com/video/BV1kf421S7WH/?share_source=copy_web'
          'https://www.douyin.com/video/6961737553342991651');
  bool isLoading = false;
  bool isNeedVPN = false;

  @override
  void initState() {
    super.initState();

    EventBus.getDefault().register(this, (event) {
      if (event.toString() == "parse") {
        getPaste();
      }
    });
  }

  @override
  void dispose() {
    EventBus.getDefault().unregister(this);
    super.dispose();
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
                // leading: const SizedBox(
                //   width: 50,
                //   height: 60,
                // ),
                backgroundColor: isLightMode ? AppTheme.nearlyWhite : AppTheme.nearlyBlack,
                title: Text(
                  S.of(context).videoLinkWatermarkTxt,
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
                    child: actionRow(),
                  ),
                  SliverToBoxAdapter(
                    child: Visibility(
                      visible: isNeedVPN,
                      child: Center(
                        child: Padding(
                          padding: EdgeInsets.only(top: 20.w),
                          child: Text(
                            "该平台需要网络环境支持",
                            style: TextStyle(fontSize: 24.sp),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            )));
  }

  actionRow() {
    return Column(
      children: [
        SizedBox(height: 50.h),
        Align(
          alignment: Alignment.center,
          child: FloatingActionButton(
            backgroundColor: Theme.of(context).primaryColor,
            shape: const CircleBorder(),
            onPressed: () {
              startParse();
            },
            child: isLoading
                ? LoadingAnimationWidget.hexagonDots(
                    color: Colors.white,
                    size: 40.h,
                  )
                : Image.asset(
                    "assets/next.png",
                    fit: BoxFit.fill,
                    width: 40.w,
                    height: 40.w,
                  ),
          ),
        )
      ],
    );
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
                decoration: const InputDecoration(border: InputBorder.none, hintText: 'Paste Your Youtube or Tiktok URL...'),
              ),
            ),
          ),
        ),
      ),
    );
  }

  inputContainer() {
    return Column(
      children: [
        Container(
          height: 90.h,
          width: double.infinity,
          margin: EdgeInsets.all(30.w),
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor,
            borderRadius: BorderRadius.circular(20.r),
          ),
          child: TextField(
            maxLines: 1,
            textAlignVertical: TextAlignVertical.center,
            controller: textController,
            textInputAction: TextInputAction.done,
            onSubmitted: (value) => startParse(),
            style: TextStyle(color: Colors.white, fontSize: 30.sp),
            decoration: InputDecoration(
              hintText: "请输入视频地址",
              hintStyle: const TextStyle(color: Colors.white),
              border: const OutlineInputBorder(borderSide: BorderSide.none),
              focusedBorder: const OutlineInputBorder(borderSide: BorderSide.none),
              enabledBorder: const OutlineInputBorder(
                borderSide: BorderSide.none,
              ),
              contentPadding: EdgeInsets.symmetric(horizontal: 15.w),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> startParse() async {
    var parseUrl = textController.text;
    Match? match = RegExp(r'http[s]?:\/\/[\w.]+[\w/]*[\w.]*\??[\w=&:\-+%]*[/]*').firstMatch(parseUrl);
    var url = match?.group(0) ?? '';
    if (!url.contains('http')) {
      return;
    }

    // Navigator.push(context, MaterialPageRoute(builder: (context) => VideoDetailPage(url: url)));

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

  getPaste() async {
    ClipboardData? data = await Clipboard.getData(Clipboard.kTextPlain);
    if (data?.text?.isNotEmpty == true) {
      showCupertinoDialog(
        barrierDismissible: true,
        context: context,
        builder: (context) {
          return CupertinoAlertDialog(
            title: const Text("提示"),
            content: const Text("提取剪贴板中的链接吗？"),
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
                  textController.text = data?.text ?? "";
                  startParse();
                  Clipboard.setData(const ClipboardData(text: ''));
                },
              ),
            ],
          );
        },
      );
    }
  }
}
