import 'package:downloaderx/constants/colors.dart';
import 'package:downloaderx/constants/constant.dart';
import 'package:downloaderx/pages/video_montage_page.dart';
import 'package:downloaderx/utils/download_utils.dart';
import 'package:downloaderx/utils/parse/youtobe.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:video_player/video_player.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';

import '../models/video_info.dart';
import '../utils/parse/other.dart';
import 'voide_parse_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController textController = TextEditingController(
      text:
          'https://www.youtube.com/watch?v=Ek1QD7AH9XQ'); //https://www.youtube.com/watch?v=Ek1QD7AH9XQ
  List<VideoInfo> videoList = [];
  late VideoPlayerController _controller;
  bool isLoading = false;
  bool isDownloading = false;
  double percent = 0.0;
  int currentIndex = 0;
  bool isNeedVPN = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _controller?.dispose();
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
            child: Padding(
              padding: EdgeInsets.all(20.w),
              child: Text(
                "视频剪辑工具",
                style: TextStyle(fontSize: 40.sp),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: InkWell(
              child: Container(
                child: Text('视频去水印'),
              ),
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>  VideoParePage()));
              },
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
        mainAxisSpacing: 20.w,
        crossAxisSpacing: 20.w,
        childAspectRatio: 1,
      ),
      delegate: SliverChildBuilderDelegate(
        (BuildContext context, int index) {
          var item = Constant.meList[index];
          return InkWell(
            onTap: () async {
              final List<AssetEntity>? result =
                  await AssetPicker.pickAssets(context,
                      pickerConfig: AssetPickerConfig(
                        themeColor: primaryColor,
                        maxAssets: 1,
                        requestType: item['type'] as RequestType,
                      ));
              var file2 = await result![0].file;
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => VideoMontagePage(
                            file: file2!,
                            title: item['title'].toString(),
                          )));
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
                    size: 80.w,
                  ),
                  Text(item['title'].toString()),
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
