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
  var currentIndex = 0;

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
            margin: EdgeInsets.all(20.w),
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
          buildInputContainer("服务器地址:", 'rtmp://pswb.live.weibo.com/alicdn/'),
          buildInputContainer("串流秘钥:",
              '4954246133318227?auth_key=1697963786-0-0-f3468703707378afe5aa4f6bc8c3b9af'),
          buildInputContainer("联系方式:", 'wx11111'),
          Icon(
            Icons.add,
            size: 200.w,
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
}

Container buildInputContainer(String title, String hitText) {
  return Container(
    margin: EdgeInsets.fromLTRB(20.w, 6.h, 20.w, 6.h),
    child: Row(
      children: [
        Text(
          title,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        Container(
          height: 90.w,
          width: 500.w,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8.r),
            border: Border.all(color: primaryColor, width: 1.0),
          ),
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
