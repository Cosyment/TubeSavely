import 'package:chewie/chewie.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:video_player/video_player.dart';

import '../constants/colors.dart';
import '../data/video_parse.dart';
import '../utils/download_utils.dart';

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

  @override
  void initState() {
    super.initState();
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
          backgroundColor: primaryColor,
          title: const Text(
            "详情",
            style: TextStyle(color: Colors.white),
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

  @override
  void dispose() {
    _controller!.dispose();
    _chewieController!.dispose();
    super.dispose();
  }
}
