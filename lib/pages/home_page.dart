import 'package:downloaderx/constants/colors.dart';
import 'package:downloaderx/constants/constant.dart';
import 'package:downloaderx/pages/video_montage_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';
import '../utils/pub_method.dart';
import 'scrawl/content_page.dart';
import 'scrawl/scrawl_page.dart';
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
    PubMethodUtils.getSharedPreferences("InAppReview").then((value) {
      if (value == null) {
        PubMethodUtils.putSharedPreferences("InAppReview", "1");
        Future.delayed(const Duration(milliseconds: 1000 * 10), () {
          PubMethodUtils.getInAppReview();
        });
      }
    });
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
            child: SizedBox(
              height: 50.w,
            ),
          ),
          SliverToBoxAdapter(
            child: widgetTop(context),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(20.w),
              child: Text(
                "视频剪辑工具",
                style: TextStyle(
                  fontSize: 40.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          buildChildLayout(),
        ],
      ),
    );
  }

  widgetTop(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        SizedBox(width: 20.w),
        Expanded(
          child: Card(
            elevation: 1,
            clipBehavior: Clip.hardEdge,
            color: primaryColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(20.r)),
            ),
            child: InkWell(
              splashColor: Colors.blue.withAlpha(30),
              child: Container(
                padding: EdgeInsets.all(20.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '视频链接去水印',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 30.sp,
                      ),
                    ),
                    Align(
                      alignment: Alignment.topRight,
                      child: Icon(
                        Icons.link,
                        color: Colors.white,
                        size: 80.w,
                      ),
                    ),
                  ],
                ),
              ),
              onTap: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => VideoParePage()));
              },
            ),
          ),
        ),
        SizedBox(width: 10.w),
        Expanded(
          child: Card(
            elevation: 1,
            clipBehavior: Clip.hardEdge,
            color: primaryColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(20.r)),
            ),
            child: InkWell(
              splashColor: Colors.blue.withAlpha(30),
              child: Container(
                padding: EdgeInsets.all(20.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '图片去水印',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 30.sp,
                      ),
                    ),
                    Align(
                      alignment: Alignment.topRight,
                      child: Icon(
                        Icons.delete,
                        color: Colors.white,
                        size: 80.w,
                      ),
                    ),
                  ],
                ),
              ),
              onTap: () async {
                List<AssetEntity>? result =
                    await AssetPicker.pickAssets(context,
                        pickerConfig: AssetPickerConfig(
                          themeColor: primaryColor,
                          maxAssets: 1,
                          requestType: RequestType.image,
                        ));
                if (result != null) {
                  var file2 = await result[0].file;
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => ContentPage(
                                cover: file2!,
                              )));
                }
              },
            ),
          ),
        ),
        SizedBox(width: 20.w),
      ],
    );
  }

  buildChildLayout() {
    return SliverGrid.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          crossAxisSpacing: 10.w,
          mainAxisSpacing: 10.w,
          childAspectRatio: 1),
      itemCount: Constant.meList.length,
      itemBuilder: (BuildContext context, int index) {
        var item = Constant.meList[index];
        return Card(
          elevation: 1,
          clipBehavior: Clip.hardEdge,
          color: primaryColor,
          child: InkWell(
            splashColor: Colors.blue.withAlpha(30),
            onTap: () async {
              await skipSelectPhoto(context, item);
            },
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Image(
                //   image: AssetImage("assets/images/${item['bg']}"),
                //   width: 100.w,
                //   height: 100.w,
                //   fit: BoxFit.fill,
                // ),
                Icon(
                  item['icon'] as IconData?,
                  color: Colors.white,
                  size: 60.w,
                ),
                Padding(
                  padding: EdgeInsets.only(top: 10.w),
                  child: Text(
                    item['title'].toString(),
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 26.sp,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );

    return SliverGrid(
      gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 200.w,
        mainAxisSpacing: 10.w,
        crossAxisSpacing: 10.w,
        childAspectRatio: 1,
      ),
      delegate: SliverChildBuilderDelegate(
        (BuildContext context, int index) {
          var item = Constant.meList[index];
          return Card(
            elevation: 1,
            clipBehavior: Clip.hardEdge,
            color: primaryColor,
            child: InkWell(
              splashColor: Colors.blue.withAlpha(30),
              onTap: () async {
                await skipSelectPhoto(context, item);
              },
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Image(
                  //   image: AssetImage("assets/images/${item['bg']}"),
                  //   width: 100.w,
                  //   height: 100.w,
                  //   fit: BoxFit.fill,
                  // ),
                  Icon(
                    item['icon'] as IconData?,
                    color: Colors.white,
                    size: 60.w,
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 10.w),
                    child: Text(
                      item['title'].toString(),
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 26.sp,
                      ),
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

  Future<void> skipSelectPhoto(
      BuildContext context, Map<String, Object> item) async {
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
  }
}
