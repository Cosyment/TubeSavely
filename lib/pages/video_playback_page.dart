import 'package:flutter/material.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:tubesavely/downloader/downloader.dart';

class VideoPlaybackPage extends StatefulWidget {
  final String? title;
  final String? url;

  const VideoPlaybackPage({super.key, required this.title, required this.url});

  @override
  State<StatefulWidget> createState() => _VideoPlaybackPageState();
}

class _VideoPlaybackPageState extends State<VideoPlaybackPage> with SingleTickerProviderStateMixin {
  late final _player = Player();
  late final _videoController = VideoController(_player);
  late AnimationController _controller;
  late Animation<double> _marginTopAnimation;
  late Animation<double> _videoHeightAnimation;
  double videoHeight = 200;
  double videoMarginTop = 150;

  _initAnimation() {
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 200));
    _marginTopAnimation = Tween<double>(begin: videoMarginTop, end: 0).animate(_controller); // 开始高度和结束高度
    _videoHeightAnimation = Tween<double>(begin: videoHeight, end: 500).animate(_controller); // 开始高度和结束高度
    // _controller.forward(); // 开始动画
  }

  _initPlayer() {
    _player.open(Media(widget.url ?? ''));
    _player.stream.videoParams.listen(
      (value) {
        setState(() {
          if ((value.aspect ?? 0.0) > 0 && (value.aspect ?? 0.0) < 1) {
            videoMarginTop = 0;
            _controller.forward();
          }
        });
      },
    );
  }

  @override
  void initState() {
    super.initState();
    _initAnimation();
    _initPlayer();
  }

  @override
  void dispose() {
    super.dispose();
    _player.dispose();
    _controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          leading: IconButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              icon: const Icon(Icons.close)),
          title: Text(widget.title ?? '', style: const TextStyle(color: Colors.white70)),
          iconTheme: const IconThemeData(color: Colors.white70),
          backgroundColor: Colors.black38),
      backgroundColor: Colors.black,
      body: Column(children: [
        AnimatedBuilder(
            animation: _marginTopAnimation,
            builder: (context, child) {
              return SizedBox(
                height: _marginTopAnimation.value,
              );
            }),
        AnimatedBuilder(
            animation: _videoHeightAnimation,
            builder: (context, child) {
              return SizedBox(
                width: MediaQuery.of(context).size.width,
                height: _videoHeightAnimation.value,
                child: Video(
                  controller: _videoController,
                ),
              );
            }),
        const SizedBox(
          height: 30,
        ),
        Padding(
            padding: const EdgeInsets.only(left: 30, right: 30),
            child: Center(
              child: Container(
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.blue,
                  borderRadius: const BorderRadius.all(Radius.circular(50)),
                  boxShadow: <BoxShadow>[
                    BoxShadow(color: Colors.grey.withOpacity(0.6), offset: const Offset(4, 4), blurRadius: 8.0),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      Downloader.download(widget.url, widget.title);
                    },
                    child: const Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Icon(
                            Icons.save_alt,
                            color: Colors.white,
                            size: 22,
                          ),
                          Padding(
                            padding: EdgeInsets.all(4.0),
                            child: Text(
                              'Download',
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ))
      ]),
    );
  }
}
