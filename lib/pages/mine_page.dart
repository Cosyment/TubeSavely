import 'package:downloaderx/pages/feedback_page.dart';
import 'package:downloaderx/pages/history_page.dart';
import 'package:downloaderx/utils/pub_method.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../constants/colors.dart';
import '../plugin/method_plugin.dart';
import 'login_page.dart';
import 'setting_page.dart';
import 'tutorial_page.dart';

class MinePage extends StatefulWidget {
  const MinePage({super.key});

  @override
  State<MinePage> createState() => _MinePageState();
}

class _MinePageState extends State<MinePage> {
  List<dynamic> itemList = [
    {
      "icon": Icons.help,
      "title": "常见问题",
      "type": 0,
    },
    // {
    //   "icon": Icons.share,
    //   "title": "分享好友",
    //   "type": 1,
    // },
    {
      "icon": Icons.feedback,
      "title": "意见反馈",
      "type": 2,
    },
    {
      "icon": Icons.history,
      "title": "解析记录",
      "type": 3,
    },
    {
      "icon": Icons.settings,
      "title": "设置",
      "type": 4,
    },
  ];

  var userId = "";

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((tim) {
      PubMethodUtils.getSharedPreferences("userId").then((value) {
        setState(() {
          userId = value ?? "";
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: null,
      body: Column(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: double.infinity,
                height: 400.w,
                margin: EdgeInsets.only(),
                decoration: BoxDecoration(
                  color: primaryColor,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(400.w),
                    bottomRight: Radius.circular(400.w),
                  ),
                ),
              ),
              Positioned(
                child: InkWell(
                  onTap: () async {
                    var userIds =
                        await PubMethodUtils.getSharedPreferences("userId");
                    if (userIds == null) {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => LoginPage())).then((value) {
                        if (value != null) {
                          userId = value;
                          setState(() {});
                        }
                      });
                    }
                  },
                  child: Container(
                    width: 140.w,
                    height: 140.w,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(100.r),
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Color(0xFFFC6AEC),
                            Color(0xFF7776FF),
                          ],
                        )),
                    child: Text(
                      userId == "" ? "登录" : "已登录",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 28.sp,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              )
            ],
          ),
          Container(
            margin: EdgeInsets.fromLTRB(0, 40.w, 0, 0),
            child: Column(
              children: List.generate(itemList.length, (index) {
                var item = itemList[index];
                return Card(
                  elevation: 5,
                  margin: EdgeInsets.fromLTRB(40.w, 30.w, 40.w, 0),
                  shadowColor: primaryColor,
                  clipBehavior: Clip.hardEdge,
                  child: InkWell(
                    onTap: () {
                      onItemClick(item['type']);
                    },
                    child: Container(
                      height: 100.w,
                      padding: EdgeInsets.fromLTRB(30.w, 0, 30.w, 0),
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: primaryColor.withAlpha(200),
                        borderRadius: BorderRadius.circular(20.r),
                      ),
                      child: Row(
                        children: [
                          // Image(image: image),
                          Icon(
                            item['icon'],
                            color: Colors.white,
                          ),
                          SizedBox(
                            width: 30.w,
                          ),
                          Text(
                            item['title'],
                            style: TextStyle(color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  void onItemClick(int type) async {
    if (type == 0) {
      // Navigator.push(
      //     context, MaterialPageRoute(builder: (context) => const ChewieDemo()));
      Navigator.push(context,
          MaterialPageRoute(builder: (context) => const TutorialPage()));
    } else if (type == 1) {
      MethodPlugin.sikpPlay();
    } else if (type == 2) {
      Navigator.push(context,
          MaterialPageRoute(builder: (context) => const FeedBackPage()));
      // EventBus.getDefault().post("clear");
    } else if (type == 3) {
      Navigator.push(context,
          MaterialPageRoute(builder: (context) => const HistoryPage()));
    } else if (type == 4) {
      Navigator.push(
              context, MaterialPageRoute(builder: (context) => SettingPage()))
          .then((value) {
        PubMethodUtils.getSharedPreferences("userId").then((value) {
          setState(() {
            userId = value ?? "";
          });
        });
      });
    } else {}
  }
}
