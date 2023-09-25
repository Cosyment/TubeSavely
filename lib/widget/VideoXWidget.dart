import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import 'ControlsOverlay.dart';

class VideoXWidget extends StatefulWidget {
  const VideoXWidget(
      {super.key, required this.isLoading, required this.controller});

  final bool isLoading;
  final VideoPlayerController controller;

  @override
  State<VideoXWidget> createState() => _VideoXWidgetState();
}

class _VideoXWidgetState extends State<VideoXWidget> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 180,
      color: Colors.black,
      child: Stack(children: [
        VideoPlayer(widget.controller),
        widget.isLoading
            ? const Positioned(
                top: 0,
                right: 0,
                bottom: 0,
                left: 0,
                child: Align(
                  child: CircularProgressIndicator(
                    strokeWidth: 3.0,
                  ),
                ))
            : const SizedBox(),
        ControlsOverlay(controller: widget.controller),
        // VideoProgressIndicator(widget.controller, allowScrubbing: true),
      ]),
    );
  }
}
