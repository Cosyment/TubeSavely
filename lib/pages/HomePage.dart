import 'dart:convert';

import 'package:downloaderx/constants/colors.dart';
import 'package:downloaderx/data/DbManager.dart';
import 'package:downloaderx/utils/DownloadUtils.dart';
import 'package:downloaderx/widget/VideoXWidget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_player/video_player.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';
import 'package:percent_indicator/percent_indicator.dart';
import '../data/VideoParse.dart';
import '../models/CoverInfo.dart';
import '../models/ParseInfo.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController textController = TextEditingController(
      text: 'https://www.youtube.com/watch?v=Ek1QD7AH9XQ');
  List<ParseInfo> videoList = [];
  VideoPlayerController _controller = VideoPlayerController.asset('')
    ..initialize().then((_) {});
  bool isLoading = false;
  bool isDownloading = false;
  double percent = 0.0;
  int currentIndex = 0;

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
        backgroundColor: primaryColor,
        title: const Text(
          "DownloaderX",
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            height: 20.h,
          ),
          Row(
            children: [
              Container(
                margin: EdgeInsets.all(30.w),
                width: MediaQuery.of(context).size.width - 30,
                height: 90.w,
                decoration: BoxDecoration(
                  color: primaryColor,
                  borderRadius: BorderRadius.circular(8.r), // 圆角半径
                ),
                child: Center(
                  child: TextField(
                    maxLines: 1,
                    textAlignVertical: TextAlignVertical.center,
                    controller: textController,
                    textInputAction: TextInputAction.done,
                    onSubmitted: (value) => startParse(),
                    style: TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: "请输入视频地址",
                      hintStyle: TextStyle(color: Colors.white),
                      border: OutlineInputBorder(borderSide: BorderSide.none),
                      focusedBorder:
                          OutlineInputBorder(borderSide: BorderSide.none),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: EdgeInsets.symmetric(horizontal: 15.w),
                    ),
                  ),
                ),
              ),
            ],
          ),
          Row(
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
                  child:  Text(
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
                          child:  Text(
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
          ),

          // const Image(
          //   width: 400,
          //   height: 140,
          //   image: AssetImage('assets/banner.png'),
          // ),
          Container(
              margin: EdgeInsets.all(30.w),
              child:
                  VideoXWidget(isLoading: isLoading, controller: _controller)),

          Container(
            height: 170.w,
            margin:  EdgeInsets.all(15.r),
            child: GridView.builder(
              physics:  NeverScrollableScrollPhysics(),
              gridDelegate:  SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 5,
                  mainAxisSpacing: 5,
                  childAspectRatio: 3.2),
              itemCount: videoList.length,
              itemBuilder: (BuildContext context, int index) {
                return gridItemWidget(context, index, videoList[index]);
              },
            ),
          ),
          isDownloading
              ? Container(
                  child: CircularPercentIndicator(
                  radius: 35.0.r,
                  lineWidth: 4.0,
                  percent: percent,
                  backgroundColor: primaryColor,
                  center: Text(
                    "${(percent * 100).toStringAsFixed(0)}%",
                    style: const TextStyle(color: primaryColor),
                  ),
                  progressColor: progressColor,
                ))
              : InkWell(
                  child: Container(
                    width: 140.w,
                    height: 140.w,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(100.r),
                        gradient:  LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Color(0xFFFC6AEC),
                            Color(0xFF7776FF),
                          ],
                        )),
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
                    download(info.url.toString(), info.totalBytes);
                    setState(() {});
                  },
                ),
        ],
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  gridItemWidget(BuildContext context, index, ParseInfo info) {
    return InkWell(
      child: Container(
        decoration: BoxDecoration(
            gradient: currentIndex == index
                ? const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFFFC6AEC),
                      Color(0xFF7776FF),
                    ],
                  )
                : null,
            border: Border.all(color: primaryColor, width: 1.0),
            borderRadius: const BorderRadius.all(Radius.circular(4))),
        child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                info.label,
                style: TextStyle(
                    fontSize: 20.sp,
                    color: currentIndex == index ? Colors.white : Colors.black),
              ),
              Text(info.size,
                  style: TextStyle(
                      fontSize: 20.sp,
                      color:
                          currentIndex == index ? Colors.white : Colors.black))
            ]),
      ),
      onTap: () {
        currentIndex = index;
        isDownloading = false;
        setState(() {});
        // download(info.url.toString(), info.totalBytes);
      },
    );
  }

  Future<void> startParse() async {
    setState(() {
      videoList.clear();
      isLoading = true;
    });

    final yt = YoutubeExplode();

    var video =
        await yt.videos.get(textController.text); // Returns a Video instance.
    var title = video.title;
    var author = video.author;
    var thumbnails = video?.watchPage?.playerResponse?.root['videoDetails']
        ['thumbnail']['thumbnails'];
    List<dynamic> itemList = thumbnails;
    List<CoverInfo> coverInfoList = [];
    for (var element in itemList) {
      var coverInfo = CoverInfo.fromJson(element);
      coverInfoList.add(coverInfo);
    }
    var manifest =
        await yt.videos.streamsClient.getManifest(textController.text);
    var list = manifest.streams
        .where((element) => element.container == StreamContainer.mp4)
        .sortByBitrate();
    for (var element in list) {
      if (element.qualityLabel.endsWith('1080p')) {
        videoList.add(ParseInfo('1080p(mp4,不带音频)', element.size.totalBytes,
            element.size.toString(), element.url.toString()));
      } else if (element.qualityLabel.endsWith('720p') &&
          element is MuxedStreamInfo) {
        videoList.add(ParseInfo('720p(mp4,带音频)', element.size.totalBytes,
            element.size.toString(), element.url.toString()));
      } else if (element.qualityLabel.endsWith('480p')) {
        videoList.add(ParseInfo('480p(mp4,不带音频)', element.size.totalBytes,
            element.size.toString(), element.url.toString()));
      } else if (element.qualityLabel.endsWith('360p') &&
          element is MuxedStreamInfo) {
        videoList.add(ParseInfo('360p(mp4,带音频)', element.size.totalBytes,
            element.size.toString(), element.url.toString()));
      } else if (element.qualityLabel.endsWith('240p')) {
        videoList.add(ParseInfo('240p(mp4,不带音频)', element.size.totalBytes,
            element.size.toString(), element.url.toString()));
      } else if (element.qualityLabel.endsWith('144p')) {
        videoList.add(ParseInfo('144p(mp4,带音频)', element.size.totalBytes,
            element.size.toString(), element.url.toString()));
      }
    }
    VideoStreamInfo info = manifest.muxed.bestQuality;

    DbManager.instance().add(VideoParse(
        title: video.title,
        author: video.author,
        totalBytes: info.size.totalBytes,
        cover: coverInfoList.last.url,
        url: info.url.toString()));
    setState(() {
      _controller = VideoPlayerController.networkUrl(
        info.url,
        videoPlayerOptions: VideoPlayerOptions(mixWithOthers: true),
      )..initialize().then((_) {
          _controller.play();
          isLoading = false;
          _controller.addListener(() {
            setState(() {});
          });
          setState(() {});
        });
      // yt.close();
    });

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

  void pasteText() async {
    ClipboardData? data = await Clipboard.getData(Clipboard.kTextPlain);
    if (data != null && data.text != null) {
      String text = data.text!;
      textController.text = text;
      textController.selection = TextSelection.fromPosition(
          TextPosition(offset: textController.text.length));
    }
  }

  Future<void> download(String url, int fileSize) async {
    DownloadUtils.downloadVideo(url, "mp4", fileSize, handleProgressUpdate);
  }

  void handleProgressUpdate(double progress) {
    percent = progress;
    if (percent == 1.0) {
      isDownloading = false;
    }
    setState(() {});
  }
}
