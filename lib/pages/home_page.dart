import 'package:downloaderx/constants/colors.dart';
import 'package:downloaderx/constants/constant.dart';
import 'package:downloaderx/pages/video_montage_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';
import '../utils/pub_method.dart';
import 'voide_parse_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    // if (!Application.getStorage.hasData(Constant.isInAppReviewKey)) {
    Future.delayed(const Duration(milliseconds: 1000 * 10), () {
      PubMethodUtils.getInAppReview();
    });
    // }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text(
          "视频去水印",
          style: TextStyle(
            color: Colors.white,
          ),
        ),
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: InkWell(
              child: Container(
                child: Padding(
                  padding: EdgeInsets.all(20.w),
                  child: Text('视频去水印'),
                ),
              ),
              onTap: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => VideoParePage()));
              },
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(20.w),
              child: Text(
                "视频剪辑工具",
                style: TextStyle(fontSize: 40.sp),
              ),
            ),
          ),
          buildChildLayout(),
        ],
      ),
    );
  }

  buildChildLayout() {
    return SliverGrid(
      gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 200.w,
        mainAxisSpacing: 10.w,
        crossAxisSpacing: 20.w,
        childAspectRatio: 1,
      ),
      delegate: SliverChildBuilderDelegate(
        (BuildContext context, int index) {
          var item = Constant.meList[index];
          return InkWell(
            onTap: () async {
              List<AssetEntity>? result = await AssetPicker.pickAssets(context,
                  pickerConfig: AssetPickerConfig(
                    themeColor: primaryColor,
                    maxAssets: 1,
                    requestType: item['type'] as RequestType,
                  ));
              if (result != null) {
                var file2 = await result[0].file;
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => VideoMontagePage(
                              file: file2!,
                              title: item['title'].toString(),
                            )));
              }
            },
            child: Container(
              margin: EdgeInsets.all(10.w),
              child: Column(
                children: [
                  // Image(
                  //   image: AssetImage("assets/images/${item['bg']}"),
                  //   width: 100.w,
                  //   height: 100.w,
                  //   fit: BoxFit.fill,
                  // ),
                  Icon(
                    item['icon'] as IconData?,
                    color: primaryColor,
                    size: 80.w,
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 10.w),
                    child: Text(
                      item['title'].toString(),
                      style: TextStyle(fontSize: 26.sp),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
        childCount: Constant.meList.length,
      ),
    );
  }
}
