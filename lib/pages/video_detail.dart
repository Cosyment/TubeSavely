import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:video_player/video_player.dart';

import '../data/video_parse.dart';
import '../utils/download_utils.dart';
import '../widget/video_label_item.dart';

class VideoDetail extends StatefulWidget {
  final VideoParse bean;

  const VideoDetail({super.key, required this.bean});

  @override
  State<VideoDetail> createState() => _VideoDetailState();
}

class _VideoDetailState extends State<VideoDetail> {
  VideoPlayerController? _controller;

  ChewieController? _chewieController;
  int? bufferDelay;
  var videoList = [];
  var currentIndex = 0;

  bool isDownloading = false;

  @override
  void initState() {
    super.initState();
    videoList = widget.bean.videoList;
    _controller = VideoPlayerController.networkUrl(
      Uri.parse(widget.bean.videoList[0].url ?? ""),
      videoPlayerOptions: VideoPlayerOptions(mixWithOthers: true),
    )..initialize().then((_) {
        _controller?.play();
        _controller?.addListener(() {
          setState(() {});
        });
      });
    _chewieController = ChewieController(
      videoPlayerController: _controller!,
      aspectRatio: 16 / 9,
      autoPlay: true,
      looping: true,
      hideControlsTimer: const Duration(seconds: 3),
      // customControls: Container(
      //   color: Colors.blueAccent,
      //   child: Text("sss"),
      // ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text(
            "详情",
          ),
        ),
        body: Column(
          children: [
            Container(
              margin: EdgeInsets.all(30.w),
              height: 400.w,
              child: Center(
                child: _chewieController != null &&
                        _chewieController!
                            .videoPlayerController.value.isInitialized
                    ? Chewie(
                        controller: _chewieController!,
                      )
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(),
                          SizedBox(height: 20),
                          Text('Loading'),
                        ],
                      ),
              ),
            ),
            Container(
              height: 170.w,
              margin: EdgeInsets.all(20.w),
              child: GridView.builder(
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 5,
                    mainAxisSpacing: 5,
                    childAspectRatio: 3.2),
                itemCount: videoList.length,
                itemBuilder: (BuildContext context, int index) {
                  return VideoItem(
                    item: videoList[index],
                    isSelected: index == currentIndex,
                    onItemClick: onVideoLabelItemClick,
                  );
                },
              ),
            ),
            InkWell(
              onTap: () {
                DownloadUtils.downloadVideo(widget.bean.cover, null);
              },
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
                    )),
                child: Text(
                  '封面下载',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 28.sp,
                      fontWeight: FontWeight.bold),
                ),
              ),
            )
          ],
        ));
  }

  void onVideoLabelItemClick(item) {
    currentIndex = videoList.indexOf(item);
    isDownloading = false;
    setState(() {});
  }

  @override
  void dispose() {
    _controller!.dispose();
    _chewieController!.dispose();
    super.dispose();
  }
}
