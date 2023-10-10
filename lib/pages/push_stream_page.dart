import 'package:downloaderx/widget/live_type_item.dart';
import 'package:downloaderx/widget/platform_item.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../constants/colors.dart';

class PushStreamPage extends StatefulWidget {
  const PushStreamPage({super.key});

  @override
  State<PushStreamPage> createState() => _PushStreamPageState();
}

class _PushStreamPageState extends State<PushStreamPage> {
  List<dynamic> platform = [
    {'title': '抖音', 'icon': 'iconspdy.png'},
    {'title': 'bili', 'icon': 'iconspbilibili.png'},
    {'title': '微博', 'icon': 'icon_sp_acfun.png'},
    {'title': '知乎', 'icon': 'iconspbaidu.png'},
    {'title': '视频号', 'icon': 'iconspbaidu.png'},
    {'title': 'YouToBe', 'icon': 'iconspyoutube.png'},
  ];
  List<dynamic> liveType = [
    {'title': '催眠直播', 'icon': 'iconspdy.png'},
    {'title': '音乐直播', 'icon': 'iconspbilibili.png'},
    {'title': '电影直播', 'icon': 'icon_sp_acfun.png'},
  ];
  var currentIndex = 0;
  var currentLiveIndex = 0;

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
              style: TextStyle(fontWeight: FontWeight.bold),
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
          buildInputContainer("服务器地址:", '请输入服务器地址(rtmp://)'),
          buildInputContainer("串流秘钥:", '请输入串流秘钥'),
          buildInputContainer("联系方式:", '请输入联系方式'),
          Container(
            alignment: Alignment.centerLeft,
            margin: EdgeInsets.fromLTRB(20.w, 0, 20.w, 0),
            child: Text(
              "直播类型",
              style: TextStyle(fontWeight: FontWeight.bold),
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
          InkWell(
            child: Container(
              width: 540.w,
              height: 80.h,
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
                "开始推流",
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 28.sp,
                    fontWeight: FontWeight.bold),
              ),
            ),
            onTap: () {},
          )
        ],
      ),
    );
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

Container buildInputContainer(String title, String hitText) {
  return Container(
    width: double.infinity,
    margin: EdgeInsets.fromLTRB(20.w, 6.h, 20.w, 6.h),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        Container(
          height: 80.w,
          width: double.infinity,
          child: TextField(
            maxLines: 1,
            textAlignVertical: TextAlignVertical.center,
            controller: TextEditingController(),
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
              contentPadding: EdgeInsets.symmetric(horizontal: 15.w),
            ),
          ),
        ),
      ],
    ),
  );
}
