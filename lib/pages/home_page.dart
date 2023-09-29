import 'package:downloaderx/constants/colors.dart';
import 'package:downloaderx/constants/constant.dart';
import 'package:downloaderx/utils/download_utils.dart';
import 'package:downloaderx/utils/parse/youtobe.dart';
import 'package:downloaderx/widget/video_x_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:video_player/video_player.dart';

import '../models/video_info.dart';
import '../utils/parse/other.dart';
import '../widget/video_label_item.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController textController = TextEditingController(
      text:
          'https://v.douyin.com/ieccTV51/'); //https://www.youtube.com/watch?v=Ek1QD7AH9XQ
  List<VideoInfo> videoList = [];
  VideoPlayerController _controller = VideoPlayerController.asset('')
    ..initialize().then((_) {});
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
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        backgroundColor: primaryColor,
        title: Text(
          "DownloaderX",
          style: TextStyle(
            color: Colors.white,
          ),
        ),
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: buildContainer(),
          ),
          SliverToBoxAdapter(
            child: buildRow(),
          ),
          SliverToBoxAdapter(
            child: titleWidget(),
          ),
          buildChildLayout(),
        ],
      ),
      //
      // body: Container(
      //   color: bgColor,
      //   height: double.infinity,
      //   child: Column(
      //     crossAxisAlignment: CrossAxisAlignment.center,
      //     children: [
      //       SizedBox(
      //         height: 20.h,
      //       ),
      //       _pingtaiIcon(),
      //       buildContainer(),
      //       buildRow(),
      //       isNeedVPN
      //           ? Column(
      //               children: [
      //                 SizedBox(
      //                   height: 20.h,
      //                 ),
      //                 const Text("海外平台需要网络环境支持",
      //                     style: TextStyle(fontSize: 12)),
      //               ],
      //             )
      //           : SizedBox(
      //               height: 0,
      //             ),
      //       videoList.length > 0
      //           ? Container(
      //               margin: EdgeInsets.all(30.w),
      //               child: VideoXWidget(
      //                   isLoading: isLoading, controller: _controller))
      //           : Spacer(),
      //       videoList.length > 0
      //           ? Container(
      //               height: 170.w,
      //               margin: EdgeInsets.all(20.w),
      //               child: GridView.builder(
      //                 physics: const NeverScrollableScrollPhysics(),
      //                 gridDelegate:
      //                     const SliverGridDelegateWithFixedCrossAxisCount(
      //                         crossAxisCount: 3,
      //                         crossAxisSpacing: 5,
      //                         mainAxisSpacing: 5,
      //                         childAspectRatio: 3.2),
      //                 itemCount: videoList.length,
      //                 itemBuilder: (BuildContext context, int index) {
      //                   return VideoItem(
      //                     item: videoList[index],
      //                     isSelected: index == currentIndex,
      //                     onItemClick: onVideoLabelItemClick,
      //                   );
      //                 },
      //               ),
      //             )
      //           : Spacer(),
      //       videoList.length > 0
      //           ? isDownloading
      //               ? Container(
      //                   width: 140.w,
      //                   height: 140.w,
      //                   child: CircularPercentIndicator(
      //                     radius: 70.0.r,
      //                     lineWidth: 4.0,
      //                     percent: percent,
      //                     backgroundColor: primaryColor,
      //                     center: Text(
      //                       "${(percent * 100).toStringAsFixed(0)}%",
      //                       style: const TextStyle(color: primaryColor),
      //                     ),
      //                     progressColor: progressColor,
      //                   ))
      //               : InkWell(
      //                   child: Container(
      //                     width: 140.w,
      //                     height: 140.w,
      //                     alignment: Alignment.center,
      //                     decoration: BoxDecoration(
      //                         borderRadius: BorderRadius.circular(100.r),
      //                         gradient: LinearGradient(
      //                           begin: Alignment.topLeft,
      //                           end: Alignment.bottomRight,
      //                           colors: [
      //                             Color(0xFFFC6AEC),
      //                             Color(0xFF7776FF),
      //                           ],
      //                         )),
      //                     child: Text(
      //                       "下载",
      //                       style: TextStyle(
      //                           color: Colors.white,
      //                           fontSize: 28.sp,
      //                           fontWeight: FontWeight.bold),
      //                     ),
      //                   ),
      //                   onTap: () {
      //                     isDownloading = true;
      //                     var info = videoList[currentIndex];
      //                     download(info.url.toString());
      //                     setState(() {});
      //                   },
      //                 )
      //           : Spacer(),
      //     ],
      //   ),
      // ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  Row titleWidget() {
    return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                margin: EdgeInsets.all(20.w),
                child: Text(
                  "支持提取的视频平台",
                  style: TextStyle(fontSize: 28.sp),
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
                        color: Colors.grey,
                        style: BorderStyle.solid,
                        width: 1.w),
                    borderRadius: BorderRadius.all(Radius.circular(20.r))),
                child: Text(
                  "免费试用",
                  style: TextStyle(color: Colors.grey, fontSize: 20.sp),
                ),
              ),
            ],
          );
  }

  Row buildRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        InkWell(
          child: Container(
            width: 240.w,
            height: 88.w,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: primaryColor,
              borderRadius: BorderRadius.circular(8.r), // 圆角半径
            ),
            child: Text(
              "粘贴",
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 28.sp,
                  fontWeight: FontWeight.bold),
            ),
          ),
          onTap: () {
            pasteText();
          },
        ),
        const SizedBox(
          width: 20,
        ),
        Container(
          width: 240.w,
          alignment: Alignment.center,
          child: isLoading
              ? const CircularProgressIndicator(
                  strokeWidth: 3.0,
                )
              : InkWell(
                  child: Container(
                    width: 240.w,
                    height: 88.w,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: primaryColor,
                      borderRadius: BorderRadius.circular(8.r), // 圆角半径
                    ),
                    child: Text(
                      "解析视频",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 28.sp,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                  onTap: () {
                    startParse();
                  },
                ),
        )
      ],
    );
  }

  Container buildContainer() {
    return Container(
      height: 90.w,
      width: double.infinity,
      margin: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: primaryColor,
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: TextField(
        maxLines: 1,
        textAlignVertical: TextAlignVertical.center,
        controller: textController,
        textInputAction: TextInputAction.done,
        onSubmitted: (value) => startParse(),
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: "请输入视频地址",
          hintStyle: const TextStyle(color: Colors.white),
          border: const OutlineInputBorder(borderSide: BorderSide.none),
          focusedBorder: const OutlineInputBorder(borderSide: BorderSide.none),
          enabledBorder: const OutlineInputBorder(
            borderSide: BorderSide.none,
          ),
          contentPadding: EdgeInsets.symmetric(horizontal: 15.w),
        ),
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

  void onVideoLabelItemClick(item) {
    currentIndex = videoList.indexOf(item);
    isDownloading = false;
    setState(() {});
  }

  Future<void> startParse() async {
    try {
      if (textController.text.startsWith("https://www.youtube.com")) {
        isNeedVPN = true;
        YouToBe.get().parse(textController.text, onResult);
      } else {
        isNeedVPN = false;
        Other.get().parse(textController.text, onResult);
      }
      setState(() {
        videoList.clear();
        isLoading = true;
      });
    } catch (e) {
      print(">>>>>>>>>>>>>>>${e}");
      isLoading = false;
    }
// var fileName = "${DateTime.now().millisecondsSinceEpoch}.mp4";
// final Directory tempDir = await getTemporaryDirectory();
// String appDocPath = tempDir.path;
// print('Success to load appDocPath>>>>>>>>>>>>: ${appDocPath}');
//
// var stream = yt.videos.streamsClient.get(list.first);
// File file = File('$appDocPath/$fileName');
// var fileStream = file.openWrite();
// await stream.pipe(fileStream);
// await fileStream.flush();
// await fileStream.close();
// final result = await ImageGallerySaver.saveFile(file.path);
// print('result>>>>>>>>>>>>: ${result}');
  }

  void onResult(result) {
    if (result.isNotEmpty) {
      videoList = result;
      _controller = VideoPlayerController.networkUrl(
        Uri.parse(result[0].url),
        videoPlayerOptions: VideoPlayerOptions(mixWithOthers: true),
      )..initialize().then((_) {
          _controller.play();
          isLoading = false;
          _controller.addListener(() {
            setState(() {});
          });
          setState(() {});
        });
      setState(() {});
    }
  }

  void pasteText() async {
    ClipboardData? data = await Clipboard.getData(Clipboard.kTextPlain);
    if (data != null && data.text != null) {
      String text = data.text!;
      textController.text = text;
      textController.selection = TextSelection.fromPosition(
          TextPosition(offset: textController.text.length));
    }
  }

  Future<void> download(String url) async {
    DownloadUtils.downloadVideo(url, handleProgressUpdate);
  }

  void handleProgressUpdate(double progress) {
    percent = progress;
    if (percent == 1.0) {
      isDownloading = false;
      percent = 0;
    }
    setState(() {});
  }
}
