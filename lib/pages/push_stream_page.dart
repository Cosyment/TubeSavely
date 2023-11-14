import 'dart:async';

import 'package:downloaderx/utils/exit.dart';
import 'package:downloaderx/widget/live_type_item.dart';
import 'package:downloaderx/widget/platform_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:url_launcher/url_launcher.dart';

import '../network/http_api.dart';
import '../network/http_utils.dart';
import '../utils/event_bus.dart';
import 'login_page.dart';
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
    // {'title': 'YouTobe', 'icon': 'youtobe.png'},
  ];
  List<dynamic> liveType = [
    {'title': '催眠直播', 'icon': 'iconspdy.png', 'type': 0},
    {'title': '音乐直播', 'icon': 'iconspbilibili.png', 'type': 1},
    {'title': '电影直播', 'icon': 'icon_sp_acfun.png', 'type': 2},
  ];
  var currentPlatformIndex = 0;
  var currentLiveIndex = 0;
  bool isCircular = false;
  int status = -1;
  var countdown = 0;
  var controllerHost = TextEditingController(text: "");
  var controllerSecretKey = TextEditingController(text: "");
  var controllerLiveUrl = TextEditingController(text: "");

  @override
  void initState() {
    super.initState();
    loadPushStreamInfo();
    EventBus.getDefault().register(this, (event) {
      if (event.toString() == "refresh_push_stream") {
        loadPushStreamInfo();
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    EventBus.getDefault().unregister(this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: const Text(
          "直播推流",
        ),
      ),
      body: Container(
        margin: EdgeInsets.all(30.w),
        child: CustomScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          slivers: [
            SliverToBoxAdapter(
              child: Container(
                alignment: Alignment.centerLeft,
                margin: EdgeInsets.fromLTRB(0, 0, 0, 25.w),
                child: Text(
                  "选择推流平台",
                  style:
                      TextStyle(fontWeight: FontWeight.bold, fontSize: 30.sp),
                ),
              ),
            ),
            SliverGrid.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 10.w,
                  mainAxisSpacing: 10.w,
                  childAspectRatio: 2.2),
              itemCount: platform.length,
              itemBuilder: (BuildContext context, int index) {
                return PlatFormItem(
                  item: platform[index],
                  isSelected: index == currentPlatformIndex,
                  onItemClick: onItemClick,
                );
              },
            ),
            buildInputContainer(
                "服务器地址:",
                'rtmp://live-push.bilivideo.com/live-bvc/',
                controllerHost,
                context),
            buildInputContainer(
                "串流秘钥:",
                '?streamname=live_1395106275_52446772&key=353e0970a59ad30ebb317984e0f6b348&schedule=rtmp&pflag=1',
                controllerSecretKey,
                context),
            buildInputContainer("直播间地址:", 'http://live.bilibili.com/27521273',
                controllerLiveUrl, context),
            SliverToBoxAdapter(
              child: Container(
                alignment: Alignment.centerLeft,
                margin: EdgeInsets.fromLTRB(0, 0, 0, 25.w),
                child: Text(
                  "直播类型",
                  style:
                      TextStyle(fontWeight: FontWeight.bold, fontSize: 30.sp),
                ),
              ),
            ),
            SliverGrid.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 10.w,
                  mainAxisSpacing: 10.w,
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
            SliverToBoxAdapter(
              child: Container(
                margin: EdgeInsets.symmetric(vertical: 50.w, horizontal: 0),
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: onTap,
                      child: AnimatedContainer(
                        duration: Duration(milliseconds: 600),
                        curve: Curves.linear,
                        width: isCircular ? 100.h : 600.w,
                        height: isCircular ? 100.h : 80.h,
                        decoration: BoxDecoration(
                            borderRadius:
                                BorderRadius.circular(isCircular ? 50.h : 40.h),
                            color: Theme.of(context).primaryColor),
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
                                status == -1
                                    ? '开始推流'
                                    : status == 0
                                        ? "正在排队中..."
                                        : "正在直播中",
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 30.sp,
                                    fontWeight: FontWeight.bold),
                              )),
                        // child: isCircular
                        //     ? ClipOval(child: Container(color: Colors.blue))
                        //     : null,
                      ),
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  void onTap() async {
    var host = controllerHost.value.text;
    var secretKey = controllerSecretKey.value.text;
    var liveUrl = controllerLiveUrl.value.text;
    var plat = platform[currentPlatformIndex]['title'];
    var type = liveType[currentLiveIndex]['type'];
    if (await UserExit.isLogin() == null) {
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => const LoginPage()));
      return;
    }
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
    if (isCircular) {
      return;
    }
    if (status == 0) {
      ToastExit.show("正在排队推流中");
      return;
    } else if (status == 1) {
      jumpLaunchUrl(liveUrl);
      return;
    }

    setState(() {
      countdown = 0;
      isCircular = !isCircular;
    });
    var map = <String, dynamic>{};
    map['liveHost'] = host;
    map['secretKey'] = secretKey;
    map['liveUrl'] = liveUrl;
    map['platform'] = plat;
    map['liveType'] = type;
    var respond = await HttpUtils.instance.requestNetWorkAy(
        Method.post, HttpApi.submitLiveStream,
        queryParameters: map);
    if (respond != null) {
      await Future.delayed(Duration(milliseconds: 400));
      status = 0;
      startTimer();
    }
    print(">>>>>>>>>>>>>>>${respond}");
  }

  void startTimer() {
    ToastExit.show("已提交,正在排队等候推流中~");
    countdown = 9;
    Timer.periodic(const Duration(seconds: 1), (Timer timer) {
      if (countdown == 1) {
        timer.cancel();
        setState(() {
          isCircular = false;
          status = 0;
        });
      } else {
        setState(() {
          countdown--;
        });
      }
    });
  }

  void loadPushStreamInfo() async {
    if (await UserExit.isLogin() != null) {
      var respond = await HttpUtils.instance
          .requestNetWorkAy(Method.get, HttpApi.getStreamInfo);
      print(">>>>>>loadPushStreamInfo>>>>>>>>${respond}");
      if (respond != null) {
        setState(() {
          controllerHost.text = respond['liveHost'];
          controllerSecretKey.text = respond['secretKey'];
          controllerLiveUrl.text = respond['liveUrl'];
          status = respond['status'];
          currentPlatformIndex = platform
              .indexWhere((element) => element['title'] == respond['platform']);
          currentLiveIndex = liveType
              .indexWhere((element) => element['type'] == respond['liveType']);
        });
      }
    }
  }

  Future<void> jumpLaunchUrl(webUrl) async {
    final Uri uri = Uri.parse(webUrl);
    if (!await launchUrl(uri)) {
      throw Exception('Could not launch $uri');
    }
  }

  void onItemClick(item) {
    currentPlatformIndex = platform.indexOf(item);
    setState(() {});
  }

  void onLiveItemClick(item) {
    currentLiveIndex = liveType.indexOf(item);
    setState(() {});
  }
}

SliverToBoxAdapter buildInputContainer(String title, String hitText,
    TextEditingController controller, BuildContext context) {
  return SliverToBoxAdapter(
    child: Container(
      width: double.infinity,
      margin: EdgeInsets.fromLTRB(0, 25.w, 0, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const TutorialPage()));
            },
            child: Row(
              children: [
                Text(
                  title,
                  style:
                      TextStyle(fontWeight: FontWeight.bold, fontSize: 30.sp),
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
    ),
  );
}
