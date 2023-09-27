import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:video_player/video_player.dart';

import '../constants/colors.dart';
import '../data/video_parse.dart';
import '../widget/video_x_widget.dart';

class VideoDetail extends StatefulWidget {
  final VideoParse bean;

  const VideoDetail({super.key, required this.bean});

  @override
  State<VideoDetail> createState() => _VideoDetailState();
}

class _VideoDetailState extends State<VideoDetail> {
  VideoPlayerController? _controller;

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
                child: VideoXWidget(isLoading: false, controller: _controller!!)),
            Text('封面下载')
          ],
        ));
  }
}
