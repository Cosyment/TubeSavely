import 'dart:ffi';

import 'package:downloaderx/pages/image_viewer_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../constants/colors.dart';
import '../constants/constant.dart';

class TutorialPage extends StatefulWidget {
  const TutorialPage({Key? key}) : super(key: key);

  @override
  _TutorialPageState createState() => _TutorialPageState();
}

class _TutorialPageState extends State<TutorialPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "常见问题",
        ),
      ),
      body: ListView(
        children: Constant.tutorialList.map((item) {
          return ExpansionPanelList(
            elevation: 0,
            expandedHeaderPadding: EdgeInsets.zero,
            expansionCallback: (int index, bool isExpanded) {
              setState(() {
                item['isExpanded'] = !isExpanded;
              });
            },
            children: [
              ExpansionPanel(
                headerBuilder: (BuildContext context, bool isExpanded) {
                  return ListTile(
                    title: Text(
                      item['title'].toString(),
                      style: const TextStyle(
                          color: Colors.black, fontWeight: FontWeight.bold),
                    ),
                  );
                },
                body: item['type'] == 1
                    ? Container(
                        margin: EdgeInsets.fromLTRB(30.w, 0, 30.w, 0),
                        child: Column(
                          children: [
                            Text(item['content'].toString(),
                                style: TextStyle(
                                    color: Colors.black87, fontSize: 30.sp)),
                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ImageViewerPage(
                                        imagePath: 'assets/images/step2.jpg',
                                      ),
                                    ));
                              },
                              child: Hero(
                                  tag: 'image',
                                  child: Image.asset(
                                    'assets/images/step2.jpg',
                                    width: 200.w,
                                    height: 200.h,
                                  )),
                            )
                          ],
                        ),
                      )
                    : item['type'] == 2
                        ? Container(
                            margin: EdgeInsets.fromLTRB(30.w, 0, 30.w, 0),
                            child: Column(
                              children: [
                                Text(item['content'].toString(),
                                    style: TextStyle(
                                        color: Colors.black87,
                                        fontSize: 30.sp)),
                                GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => ImageViewerPage(
                                            imagePath: 'assets/eg_live.jpg',
                                          ),
                                        ));
                                  },
                                  child: Hero(
                                      tag: 'image',
                                      child: Image.asset(
                                        'assets/eg_live.jpg',
                                        width: 600.w,
                                        height: 200.h,
                                      )),
                                )
                              ],
                            ),
                          )
                        : ListTile(
                            title: Text(
                              item['content'].toString(),
                              style: TextStyle(
                                  color: Colors.black87, fontSize: 30.sp),
                            ),
                          ),
                isExpanded: item['isExpanded'] == true,
              ),
            ],
          );
        }).toList(),
      ),
      // body: CustomScrollView(
      //   slivers: [
      //     SliverToBoxAdapter(
      //       child: oneWidget(),
      //     ),
      //     SliverToBoxAdapter(
      //       child: titleWidget(),
      //     ),
      //     buildChildLayout(),
      //     bottomList(),
      //   ],
      // ),
    );
  }

  bottomList() {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (BuildContext context, int index) {
          var item = Constant.tutorialList[index];
          return Container(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Image(
                  image: AssetImage("assets/images/step1.jpg"),
                  width: 30.w,
                  height: 30.w,
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        item['title'].toString(),
                        style: TextStyle(
                          fontSize: 38.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(
                        height: 20.w,
                      ),
                      Text(
                        item['content'].toString(),
                        style: TextStyle(fontSize: 30.sp, color: Colors.grey),
                      ),
                      SizedBox(
                        height: 20.w,
                      ),
                    ],
                  ),
                )
              ],
            ),
          );
        },
        childCount: Constant.tutorialList.length,
      ),
    );
  }

  oneWidget() {
    var imgWidth = 20.w;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        SizedBox(width: 10.w),
        Column(
          children: [
            Text(
              "步骤一",
              style: TextStyle(
                fontSize: 24.sp,
                color: primaryColor,
              ),
            ),
            SizedBox(height: 10.w),
            Text(
              "点击分享",
              style: TextStyle(
                fontSize: 30.sp,
              ),
            ),
            SizedBox(height: 10.w),
            Image(
              image: AssetImage("assets/images/step1.jpg"),
              width: imgWidth,
              height: 400.w,
              fit: BoxFit.fill,
            ),
          ],
        ),
        SizedBox(width: 10.w),
        Column(
          children: [
            Text(
              "步骤二",
              style: TextStyle(
                fontSize: 24.sp,
                color: primaryColor,
              ),
            ),
            SizedBox(height: 10.w),
            Text(
              "获取视频连接",
              style: TextStyle(
                fontSize: 30.sp,
              ),
            ),
            SizedBox(height: 10.w),
            Image(
              image: AssetImage("assets/images/step2.jpg"),
              width: imgWidth,
              height: 400.w,
              fit: BoxFit.fill,
            ),
          ],
        ),
        SizedBox(width: 10.w),
        Column(
          children: [
            Text(
              "步骤三",
              style: TextStyle(
                fontSize: 24.sp,
                color: primaryColor,
              ),
            ),
            SizedBox(height: 10.w),
            Text(
              "粘贴视频连接",
              style: TextStyle(
                fontSize: 30.sp,
              ),
            ),
            SizedBox(height: 10.w),
            Image(
              image: AssetImage("assets/images/step3.jpg"),
              width: imgWidth,
              height: 400.w,
              fit: BoxFit.fill,
            ),
          ],
        ),
        SizedBox(width: 10.w),
      ],
    );
  }

  titleWidget() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Container(
          margin: EdgeInsets.all(20.w),
          child: Text(
            "支持提取的视频平台",
            style: TextStyle(
              fontSize: 38.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Container(
          margin: EdgeInsets.all(20.w),
          padding: EdgeInsets.symmetric(
            horizontal: 10.w,
          ),
          decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(
                  color: Colors.grey, style: BorderStyle.solid, width: 1.w),
              borderRadius: BorderRadius.all(Radius.circular(20.r))),
          child: Text(
            "免费试用",
            style: TextStyle(color: Colors.grey, fontSize: 20.sp),
          ),
        ),
      ],
    );
  }

  buildChildLayout() {
    return SliverGrid(
      gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 200.w,
        mainAxisSpacing: 20.w,
        crossAxisSpacing: 20.w,
        childAspectRatio: 1,
      ),
      delegate: SliverChildBuilderDelegate(
        (BuildContext context, int index) {
          var item = Constant.pingtaiList[index];
          return Container(
            margin: EdgeInsets.all(10.w),
            child: Column(
              children: [
                Image(
                  image: AssetImage("assets/images/${item['bg']}"),
                  width: 100.w,
                  height: 100.w,
                  fit: BoxFit.fill,
                ),
                Text(item['title'].toString()),
              ],
            ),
          );
        },
        childCount: Constant.pingtaiList.length,
      ),
    );
  }
}
