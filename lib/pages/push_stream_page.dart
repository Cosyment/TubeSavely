import 'dart:async';

import 'package:downloaderx/utils/exit.dart';
import 'package:downloaderx/widget/live_type_item.dart';
import 'package:downloaderx/widget/platform_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

import '../constants/colors.dart';
import 'tutorial_page.dart';

class PushStreamPage extends StatefulWidget {
  const PushStreamPage({super.key});

  @override
  State<PushStreamPage> createState() => _PushStreamPageState();
}

class _PushStreamPageState extends State<PushStreamPage>
    with SingleTickerProviderStateMixin {
  List<dynamic> platform = [
    {'title': '抖音', 'icon': 'douyin.png'},
    {'title': '快手', 'icon': 'ks.png'},
    {'title': '哔哩', 'icon': 'bili.png'},
    {'title': '微博', 'icon': 'weibo.png'},
    {'title': '知乎', 'icon': 'zhihu.png'},
    {'title': 'YouTobe', 'icon': 'youtobe.png'},
  ];
  List<dynamic> liveType = [
    {'title': '催眠直播', 'icon': 'iconspdy.png'},
    {'title': '音乐直播', 'icon': 'iconspbilibili.png'},
    {'title': '电影直播', 'icon': 'icon_sp_acfun.png'},
  ];
  var currentIndex = 0;
  var currentLiveIndex = 0;
  bool isCircular = false;
  var countdown = 0;
  var btnStr = "开始推流";
  var controllerHost = TextEditingController();
  var controllerSecretKey = TextEditingController();
  var controllerLiveUrl = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        backgroundColor: primaryColor,
        title: const Text(
          "直播推流",
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Column(
        children: [
          Container(
            alignment: Alignment.centerLeft,
            margin: EdgeInsets.fromLTRB(20.w, 20.w, 20.w, 0),
            child: Text(
              "选择推流平台",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30.sp),
            ),
          ),
          Container(
            height: 200.h,
            margin: EdgeInsets.all(20.w),
            child: GridView.builder(
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 5,
                  mainAxisSpacing: 5,
                  childAspectRatio: 2.0),
              itemCount: platform.length,
              itemBuilder: (BuildContext context, int index) {
                return PlatFormItem(
                  item: platform[index],
                  isSelected: index == currentIndex,
                  onItemClick: onItemClick,
                );
              },
            ),
          ),
          buildInputContainer(
              "服务器地址:", '请输入服务器地址(rtmp://)', controllerHost, context),
          buildInputContainer("串流秘钥:", '请输入串流秘钥', controllerSecretKey, context),
          buildInputContainer(
              "直播间地址:", '请输入直播间地址(https://)', controllerLiveUrl, context),
          Container(
            alignment: Alignment.centerLeft,
            margin: EdgeInsets.fromLTRB(20.w, 0, 20.w, 0),
            child: Text(
              "直播类型",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30.sp),
            ),
          ),
          Container(
            height: 100.h,
            margin: EdgeInsets.all(20.w),
            child: GridView.builder(
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 5,
                  mainAxisSpacing: 5,
                  childAspectRatio: 2.6),
              itemCount: liveType.length,
              itemBuilder: (BuildContext context, int index) {
                return LiveTypeItem(
                  item: liveType[index],
                  isSelected: index == currentLiveIndex,
                  onItemClick: onLiveItemClick,
                );
              },
            ),
          ),
          GestureDetector(
            onTap: onTap,
            child: AnimatedContainer(
              duration: Duration(milliseconds: 600),
              curve: Curves.linear,
              width: isCircular ? 100.h : 600.w,
              height: isCircular ? 100.h : 80.h,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(isCircular ? 50.h : 40.h),
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFFFC6AEC),
                      Color(0xFF7776FF),
                    ],
                  )),
              alignment: Alignment.center,
              child: isCircular
                  ? countdown > 0
                      ? Stack(
                          alignment: Alignment.center,
                          children: [
                            LoadingAnimationWidget.threeArchedCircle(
                              color: Colors.white,
                              size: 60.h,
                            ),
                            Text(
                              "${countdown}s",
                              style: TextStyle(color: Colors.white),
                            )
                          ],
                        )
                      : LoadingAnimationWidget.hexagonDots(
                          color: Colors.white,
                          size: 60.h,
                        )
                  : Center(
                      child: Text(
                      btnStr,
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 30.sp,
                          fontWeight: FontWeight.bold),
                    )),
              // child: isCircular
              //     ? ClipOval(child: Container(color: Colors.blue))
              //     : null,
            ),
          )
        ],
      ),
    );
  }

  void onTap() {
    var host = controllerHost.value.text;
    var secretKey = controllerSecretKey.value.text;
    var liveUrl = controllerLiveUrl.value.text;
    var plat = platform[currentIndex];
    var type = liveType[currentLiveIndex];
    if (host.isEmpty) {
      ToastExit.show('请输入服务器地址');
      return;
    }
    if (secretKey.isEmpty) {
      ToastExit.show('请输入秘钥地址');
      return;
    }
    if (liveUrl.isEmpty) {
      ToastExit.show('请输入直播地址');
      return;
    }
    setState(() {
      countdown = 0;
      isCircular = !isCircular;
    });
    Future.delayed(Duration(seconds: 5), () {
      startTimer();
    });
  }

  void startTimer() {
    countdown = 9;
    Timer.periodic(const Duration(seconds: 1), (Timer timer) {
      if (countdown == 1) {
        timer.cancel();
        setState(() {
          isCircular = false;
          btnStr = "正在直播中";
        });
      } else {
        setState(() {
          countdown--;
        });
      }
    });
  }

  void onItemClick(item) {
    currentIndex = platform.indexOf(item);
    setState(() {});
  }

  void onLiveItemClick(item) {
    currentLiveIndex = liveType.indexOf(item);
    setState(() {});
  }
}

Container buildInputContainer(String title, String hitText,
    TextEditingController controller, BuildContext context) {
  return Container(
    width: double.infinity,
    margin: EdgeInsets.fromLTRB(20.w, 6.h, 20.w, 6.h),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () {
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => const TutorialPage()));
          },
          child: Row(
            children: [
              Text(
                title,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30.sp),
              ),
              const Icon(
                Icons.help,
                color: Colors.grey,
                size: 16,
              ),
            ],
          ),
        ),
        Container(
          height: 80.w,
          width: double.infinity,
          child: TextField(
            maxLines: 1,
            keyboardType: TextInputType.url,
            textAlignVertical: TextAlignVertical.center,
            controller: controller,
            textInputAction: TextInputAction.done,
            style: const TextStyle(color: Colors.black),
            decoration: InputDecoration(
              hintText: hitText,
              hintStyle: const TextStyle(color: Colors.grey),
              border: const OutlineInputBorder(borderSide: BorderSide.none),
              focusedBorder:
                  const OutlineInputBorder(borderSide: BorderSide.none),
              enabledBorder: const OutlineInputBorder(
                borderSide: BorderSide.none,
              ),
              contentPadding: EdgeInsets.symmetric(horizontal: 0.w),
            ),
          ),
        ),
      ],
    ),
  );
}
