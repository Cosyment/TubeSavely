import 'package:downloaderx/constants/colors.dart';
import 'package:flutter/material.dart';

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
            child: Container(
              width: double.infinity,
              height: 200,
              decoration: BoxDecoration(
                color: primaryColor,
                borderRadius: BorderRadius.circular(600),
              ),
            ),
          ),
          Positioned(
            child: Container(
              margin: EdgeInsets.fromLTRB(0, 220, 0, 0),
              child: Column(
                children: List.generate(itemList.length, (index) {
                  var item = itemList[index];
                  return Card(
                    elevation: 5,
                    margin: EdgeInsets.fromLTRB(15, 15, 15, 0),
                    shadowColor: primaryColor,
                    child: Container(
                      height: 50,
                      padding: EdgeInsets.fromLTRB(15, 0, 15, 0),
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: primaryColor.withAlpha(200),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          // Image(image: image),
                          Icon(
                            Icons.settings,
                            color: Colors.white,
                          ),
                          SizedBox(
                            width: 15,
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
