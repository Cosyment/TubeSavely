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
import '../widget/banner_widget.dart';
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
  bool isVideType = true;

  @override
  void initState() {
    super.initState();
    isEdit = widget.bean != null && widget.bean?.videoList != null;
    if (isEdit) {
      setState(() {
        textController.text = widget.bean?.parseUrl ?? "";
      });
      onResult(widget.bean!);
    }
  }

  @override
  void dispose() {
    if (_controller != null) {
      _controller.pause();
      _controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context, designSize: const Size(750, 1378));
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: const Text(
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
                      "YouTobe平台需要网络环境支持",
                      style: TextStyle(fontSize: 24.sp),
                    ),
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: videoList.isEmpty && !isLoading ? guideContainer() : null,
            ),
            SliverToBoxAdapter(
                child: Container(
              margin: EdgeInsets.fromLTRB(0, 30.w, 0, 30.w),
              child: isVideType
                  ? videoList.isNotEmpty
                      ? VideoXWidget(
                          isLoading: isVideoLoading,
                          controller: _controller,
                        )
                      : Container()
                  : BannerWidget(
                      width: 340,
                      height: 180,
                      autoDisplayInterval: 6,
                      childWidget: videoList.map((f) {
                        return Image.network(
                          f.url,
                          width: 340,
                          height: 180,
                          fit: BoxFit.fitWidth,
                        );
                      }).toList(),
                      onPageSelected: (int value) {},
                      onPageClicked: (int value) {},
                    ),
            )),
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

  guideContainer() {
    return Container(
      alignment: Alignment.centerLeft,
      margin: EdgeInsets.fromLTRB(0, 30.w, 0, 30.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "抖音、快手、西瓜视频、TikTok、YouTobe、bilibili、小红书、微博、等180个平台",
            style: TextStyle(
                color: primaryColor,
                fontWeight: FontWeight.bold,
                fontSize: 30.sp),
          ),
          SizedBox(
            height: 20.h,
          ),
          Text(
            "复制短视频连接后,点击粘贴或者在输入框内输入,然后点击解析按钮即可",
            style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 32.sp),
          ),
          SizedBox(
            height: 20.h,
          ),
          Text(
            "第一步:点击视频的分享图标",
            style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 32.sp),
          ),
          SizedBox(
            height: 20.h,
          ),
          Image.asset("assets/step1.jpg"),
          SizedBox(
            height: 20.h,
          ),
          Text("第二步:点击复制连接图标",
              style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 32.sp)),
          SizedBox(
            height: 20.h,
          ),
          Image.asset("assets/step2.jpg")
        ],
      ),
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
    var parseUrl = textController.text;
    try {
      if (videoList.isNotEmpty && isVideType) {
        _controller?.pause();
      }
      Match? match =
          RegExp(r'http[s]?:\/\/[\w.]+[\w/]*[\w.]*\??[\w=&:\-+%]*[/]*')
              .firstMatch(parseUrl);
      var url = match?.group(0) ?? '';
      if (!url.contains('http')) {
        ToastExit.show("请输入正确的链接地址");
        return;
      }
      print(">>>>>>>>${url}");
      if (parseUrl.contains("youtu.be") || parseUrl.contains("youtube.com")) {
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

  void onResult(VideoParse? result) {
    // if (result != null) {
    //   Navigator.push(context,
    //       MaterialPageRoute(builder: (context) => VideoDetail(bean: result)));
    // }
    isLoading = false;
    if (result != null && result.videoList.isNotEmpty) {
      isVideType = result.type == 0;
      videoList = result.videoList;
      if (isVideType) {
        _controller = VideoPlayerController.networkUrl(
          Uri.parse(result.videoUrl),
          videoPlayerOptions: VideoPlayerOptions(mixWithOthers: true),
        )..initialize().then((_) {
            _controller.play();
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
      }
      setState(() {});
    } else {
      ToastExit.show("解析失败");
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
