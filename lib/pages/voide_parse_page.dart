import 'package:downloaderx/constants/colors.dart';
import 'package:downloaderx/utils/download_utils.dart';
import 'package:downloaderx/utils/exit.dart';
import 'package:downloaderx/utils/parse/youtobe.dart';
import 'package:downloaderx/widget/video_x_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:video_player/video_player.dart';

import '../data/video_parse.dart';
import '../models/video_info.dart';
import '../utils/parse/other.dart';
import '../widget/video_label_item.dart';

class VideoParePage extends StatefulWidget {
  VideoParePage({super.key, this.bean});

  VideoParse? bean;

  @override
  State<VideoParePage> createState() => _VideoParePageState();
}

class _VideoParePageState extends State<VideoParePage> {
  TextEditingController textController = TextEditingController(
      text: ''); //https://www.youtube.com/watch?v=Ek1QD7AH9XQ
  List<VideoInfo> videoList = [];
  late VideoPlayerController _controller;
  bool isLoading = false;
  bool isVideoLoading = true;
  bool isDownloading = false;
  double percent = 0.0;
  int currentIndex = 0;
  bool isNeedVPN = false;
  bool isEdit = false;

  @override
  void initState() {
    super.initState();
    isEdit = widget.bean != null && widget.bean?.videoList != null;
    if (isEdit) {
      setState(() {
        textController.text = widget.bean?.parseUrl ?? "";
      });
      onResult(widget.bean?.videoList);
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context, designSize: const Size(750, 1378));
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
      body: Container(
        margin: EdgeInsets.fromLTRB(30.w, 30.w, 30.w, 30.w),
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: inputContainer(),
            ),
            SliverToBoxAdapter(
              child: actionRow(),
            ),
            SliverToBoxAdapter(
              child: Visibility(
                visible: isNeedVPN,
                child: Center(
                  child: Padding(
                    padding: EdgeInsets.only(top: 20.w),
                    child: Text(
                      "海外平台需要网络环境支持",
                      style: TextStyle(fontSize: 24.sp),
                    ),
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Container(
                margin: EdgeInsets.fromLTRB(0, 30.w, 0, 30.w),
                child: videoList.isNotEmpty
                    ? VideoXWidget(
                        isLoading: isVideoLoading,
                        controller: _controller,
                      )
                    : Container(),
              ),
            ),
            SliverGrid(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  mainAxisSpacing: 20.w,
                  crossAxisSpacing: 20.w,
                  childAspectRatio: 2.8),
              delegate: SliverChildBuilderDelegate(
                (BuildContext context, int index) {
                  return VideoItem(
                    item: videoList[index],
                    isSelected: index == currentIndex,
                    onItemClick: onVideoLabelItemClick,
                  );
                },
                childCount: videoList.length,
              ),
            ),
            SliverToBoxAdapter(
              child: buildBottom(),
            ),
          ],
        ),
      ),
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

  actionRow() {
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
        SizedBox(
          width: 20.w,
        ),
        Container(
          width: 240.w,
          alignment: Alignment.center,
          child: isLoading
              ? LoadingAnimationWidget.discreteCircle(
                  color: primaryColor,
                  size: 60.h,
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

  inputContainer() {
    return Column(
      children: [
        Container(
          height: 90.w,
          width: double.infinity,
          margin: EdgeInsets.fromLTRB(0, 20.w, 0, 20.w),
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
    );
  }

  buildBottom() {
    return Container(
      margin: EdgeInsets.fromLTRB(0, 30.w, 0, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Visibility(
              visible: videoList.isNotEmpty && !isDownloading,
              child: InkWell(
                child: Container(
                  width: 140.w,
                  height: 140.w,
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
                    ),
                  ),
                  child: Text(
                    "下载",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 28.sp,
                        fontWeight: FontWeight.bold),
                  ),
                ),
                onTap: () {
                  isDownloading = true;
                  var info = videoList[currentIndex];
                  download(info.url.toString());
                  setState(() {});
                },
              )),
          Visibility(
            visible: videoList.isNotEmpty && isDownloading,
            child: SizedBox(
                width: 140.w,
                height: 140.w,
                child: CircularPercentIndicator(
                  radius: 70.0.r,
                  lineWidth: 4.0,
                  percent: percent,
                  backgroundColor: primaryColor,
                  center: Text(
                    "${(percent * 100).toStringAsFixed(0)}%",
                    style: const TextStyle(color: primaryColor),
                  ),
                  progressColor: progressColor,
                )),
          )
        ],
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
      var parseUrl = textController.text;
      Match? match =
          RegExp(r'http[s]?:\/\/[\w.]+[\w/]*[\w.]*\??[\w=&:\-+%]*[/]*')
              .firstMatch(parseUrl);
      var url = match?.group(0) ?? '';
      if (parseUrl.startsWith("https://www.youtube.com")) {
        isNeedVPN = true;
        YouToBe.get().parse(url, onResult);
      } else {
        isNeedVPN = false;
        Other.get().parse(url, onResult);
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
    // if (result != null) {
    //   Navigator.push(context,
    //       MaterialPageRoute(builder: (context) => VideoDetail(bean: result)));
    // }
    if (result != null) {
      videoList = result;
      _controller = VideoPlayerController.networkUrl(
        Uri.parse(result[0].url),
        videoPlayerOptions: VideoPlayerOptions(mixWithOthers: true),
      )..initialize().then((_) {
          _controller.play();
          isLoading = false;
          if (_controller.value.hasError && isEdit) {
            isEdit = false;
            startParse();
          } else {
            isVideoLoading = false;
          }
          _controller.addListener(() {
            setState(() {});
          });
        });
    } else {
      ToastExit.show("解析失败");
      isLoading = false;
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
