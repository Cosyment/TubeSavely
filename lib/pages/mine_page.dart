import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lottie/lottie.dart';
import 'package:tubesavely/pages/theme_page.dart';

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
    {
      "icon": Icons.style_outlined,
      "title": "主题切换",
      "type": 5,
    },
    // {
    //   "icon": Icons.help,
    //   "title": "会员",
    //   "type": 6,
    // },
  ];

  var userId = "";

  @override
  void initState() {
    super.initState();
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
                margin: const EdgeInsets.only(),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(400.w),
                    bottomRight: Radius.circular(400.w),
                  ),
                ),
              ),
              Positioned(
                child: InkWell(
                  onTap: () async {},
                  child: Container(
                    width: 140.w,
                    height: 140.w,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(100.r),
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Color(0xFF8983F7),
                            Color(0xFFA3DAFB),
                          ],
                        )),
                    child: userId == ""
                        ? Text(
                            "登录",
                            style: TextStyle(color: Colors.white, fontSize: 28.sp, fontWeight: FontWeight.bold),
                          )
                        : ClipRRect(
                            borderRadius: BorderRadius.circular(100),
                            child: Lottie.asset(
                              'assets/lottie/avatar.json',
                              width: 140.w,
                              height: 140.w,
                              fit: BoxFit.fill,
                            ),
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
                  shadowColor: Theme.of(context).primaryColor,
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
                        color: Theme.of(context).primaryColor.withAlpha(200),
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
                            style: const TextStyle(color: Colors.white),
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
    } else if (type == 1) {
    } else if (type == 2) {
      // EventBus.getDefault().post("clear");
    } else if (type == 3) {
    } else if (type == 4) {
    } else if (type == 5) {
      Navigator.push(context, MaterialPageRoute(builder: (context) => const ThemePage()));
    } else {}
  }
}
