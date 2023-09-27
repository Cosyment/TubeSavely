import 'package:downloaderx/constants/colors.dart';
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
      "title": "使用教程",
      "": "",
    },
    {
      "icon": "",
      "title": "分享好友",
      "": "",
    },
    {
      "icon": "",
      "title": "清除缓存",
      "": "",
    },
    {
      "icon": "",
      "title": "设置",
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
      appBar: null,
      body: Stack(
        children: [
          Positioned(
            top: MediaQuery.of(context).padding.top,
            left: 0,
            right: 0,
            child: Container(
              // width: double.infinity,
              height: 400.w,
              decoration: BoxDecoration(
                color: primaryColor,
                borderRadius: BorderRadius.circular(600.r),
              ),
            ),
          ),
          Positioned(
            child: Container(
              margin: EdgeInsets.fromLTRB(0, 460.w, 0, 0),
              child: Column(
                children: List.generate(itemList.length, (index) {
                  var item = itemList[index];
                  return Card(
                    elevation: 5,
                    margin: EdgeInsets.fromLTRB(30.w, 30.w, 30.w, 0),
                    shadowColor: primaryColor,
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
                            Icons.settings,
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
                  );
                }),
              ),
            ),
          )
        ],
      ),
    );
  }
}
