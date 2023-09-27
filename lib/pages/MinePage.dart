import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class MinePage extends StatefulWidget {
  const MinePage({super.key});

  @override
  State<MinePage> createState() => _MinePageState();
}

class _MinePageState extends State<MinePage> {
  List<dynamic> itemList = [
    {
      "icon": "",
      "title": "会员限时特价",
      "": "",
    },
    {
      "icon": "",
      "title": "联系客服",
      "": "",
    },
    {
      "icon": "",
      "title": "分享好友",
      "": "",
    },
    {
      "icon": "",
      "title": "兑换VIP",
      "": "",
    },
    {
      "icon": "",
      "title": "清除缓存",
      "": "",
    },
    {
      "icon": "",
      "title": "版本信息",
      "": "",
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("我的"),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: List.generate(itemList.length, (index) {
            var item = itemList[index];
            return Container(
              height: 90.w,
              width: double.infinity,
              margin: EdgeInsets.all(5.w),
              decoration: BoxDecoration(
                color: Colors.blue, // Container的背景色
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Row(
                children: [
                  // Image(image: image),
                  Text(item['title']),
                ],
              ),
            );
          }),
        ),
      ),
    );
  }
}
