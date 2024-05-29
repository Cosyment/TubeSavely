import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:tubesavely/models/Pair.dart';
import 'package:tubesavely/models/video_info.dart';
import 'package:tubesavely/network/http_request.dart';
import 'package:tubesavely/storage/database.dart';
import 'package:tubesavely/theme/app_theme.dart';
import 'package:tubesavely/utils/common_util.dart';
import 'package:tubesavely/utils/constants.dart';
import 'package:tubesavely/utils/resolution_util.dart';
import 'package:tubesavely/widget/iconed_button.dart';
import 'package:tubesavely/widget/radio_group.dart';

import '../downloader/downloader.dart';
import '../widget/progress_button.dart';

class VideoDetailPage extends StatefulWidget {
  final String? url;

  const VideoDetailPage({super.key, required this.url});

  @override
  State<StatefulWidget> createState() => _VideoDetailPagePageState();
}

class _VideoDetailPagePageState extends State<VideoDetailPage> with SingleTickerProviderStateMixin {
  VideoInfo? videoInfo;
  ButtonState stateOnlyText = ButtonState.idle;

  List<FormatInfo>? videoList;
  List<FormatInfo>? audioList;

  late final _player = Player();
  late final _videoController = VideoController(_player);
  late AnimationController _controller;
  late Animation<double> _marginTopAnimation;
  late Animation<double> _videoHeightAnimation;
  double videoHeight = 200;
  double videoMarginTop = 150;
  int videoTypeIndex = 0;
  int downloadTypeIndex = 0;

  void _extractVideo(String url) async {
    videoInfo = await HttpRequest.request<VideoInfo>(
        Urls.shortVideoParse,
        params: {'url': url},
        (jsonData) => VideoInfo.fromJson(jsonData),
        exception: (e) => {debugPrint('parse exception $e')});

    setState(() {
      //过滤全部全部视频
      videoList = videoInfo?.formats?.where((value) => value.video_ext == 'mp4').toList();
      //过滤全部m3u8视频（主要处理类似youtube返回相同分辨率的mp4和m3u8场景）
      videoList = (videoList?.every((element) => element.protocol == 'm3u8_native') ?? false)
          ? videoList
          : videoList?.where((element) => element.protocol != 'm3u8_native').toList();
      //根据分辨率去重
      videoList = [
        ...{for (var person in videoList as Iterable) person?.resolution: person}.values
      ];

      audioList = videoInfo?.formats
          ?.where((value) => (value.audio_ext == 'm4a' || value.audio_ext == 'webm') && value.protocol != 'm3u8_native')
          .toList();

      // DbManager.db?.add(videoInfo);
      if (videoInfo != null) {
        // DbManager.insert(widget.url ?? '', videoInfo!);
        DatabaseHelper().insert(widget.url ?? '', videoInfo!).then((onValue) => {debugPrint('------->>>>onValue ${onValue}')});
      }

      _initPlayer(url: videoList?.first.url ?? '');
    });
  }

  _initAnimation() {
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 200));
    _marginTopAnimation = Tween<double>(begin: videoMarginTop, end: 0).animate(_controller); // 开始高度和结束高度
    _videoHeightAnimation = Tween<double>(begin: videoHeight, end: 500).animate(_controller); // 开始高度和结束高度
    // _controller.forward(); // 开始动画
  }

  _initPlayer({String? url}) {
    _player.open(Media(url ?? ''), play: url?.isNotEmpty == true);
    if (url?.isNotEmpty == true) {
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
  }

  _handleDownloadResult(bool success) {
    if (success) {
      setState(() {
        stateOnlyText = ButtonState.success;
      });
    } else {
      setState(() {
        stateOnlyText = ButtonState.fail;
      });
    }
  }

  onPressedDownload() {
    switch (stateOnlyText) {
      case ButtonState.idle:
        if (videoList == null || videoList?.first == null) return;
        setState(() {
          stateOnlyText = ButtonState.loading;
        });
        if (downloadTypeIndex == 0) {
          Downloader.combineDownload(videoList?[videoTypeIndex].url ?? '', videoInfo?.title ?? '',
              audioUrl: audioList?.length == 0 ? null : audioList?.first.url,
              resolution: VideoResolutionUtil.format(videoList?[videoTypeIndex].resolution ?? ''), onSuccess: () {
            _handleDownloadResult(true);
          }, onFailure: () {
            _handleDownloadResult(false);
          });
        } else {
          Downloader.downloadAudio(
              audioList?.length == 0 ? videoInfo?.music ?? '' : audioList?.first.url ?? '', videoInfo?.title ?? '',
              onSuccess: () {
            _handleDownloadResult(true);
          }, onFailure: () {
            _handleDownloadResult(false);
          });
        }
        break;
      case ButtonState.loading:
        setState(() {
          stateOnlyText = ButtonState.loading;
        });
        break;
      case ButtonState.success:
        setState(() {
          stateOnlyText = ButtonState.idle;
        });
        break;
      case ButtonState.fail:
        setState(() {
          stateOnlyText = ButtonState.idle;
        });
        break;
    }
  }

  @override
  void initState() {
    super.initState();
    _extractVideo(widget.url ?? '');
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
    SystemChrome.setSystemUIOverlayStyle(
        const SystemUiOverlayStyle(systemNavigationBarColor: Colors.red, statusBarColor: Colors.red));

    return SafeArea(
        top: false,
        bottom: false,
        child: Scaffold(
          appBar: AppBar(
              leading: IconButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  icon: const Icon(Icons.close)),
              title: Text(videoInfo?.title ?? '', style: const TextStyle(color: Colors.white70)),
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
              height: 10,
            ),
            if ((videoList?.length ?? 0) > 1)
              Padding(
                padding: const EdgeInsets.all(10),
                child: Row(
                  children: [
                    const Text(
                      'Resolution：',
                      style: TextStyle(color: Colors.white70, fontSize: 16),
                    ),
                    RadioGroup(
                        items: videoList
                            ?.where((element) => element.resolution != null)
                            .map((e) =>
                                Pair(VideoResolutionUtil.format(e.resolution ?? ''), CommonUtil.formatSize(e.filesize ?? 0)))
                            .toList(),
                        onItemSelected: (index) {
                          videoTypeIndex = index;
                          _player.open(Media(videoList?[index].url ?? ''), play: true);
                        }),
                  ],
                ),
              ),
            if ((audioList?.length ?? 0) >= 1 || videoInfo?.music?.isNotEmpty == true)
              Padding(
                padding: const EdgeInsets.all(10),
                child: Row(
                  children: [
                    const Text(
                      'Download Option：',
                      style: TextStyle(color: Colors.white70, fontSize: 16),
                    ),
                    RadioGroup(
                        items: [Pair('Video', null), Pair('Audio', null)],
                        onItemSelected: (index) {
                          downloadTypeIndex = index;
                        })
                  ],
                ),
              ),
            const SizedBox(height: 30),
            _buildButton(),
          ]),
        ));
  }

  Widget _buildButton() {
    var progressTextButton = ProgressButton.icon(
      iconedButtons: {
        ButtonState.idle: const IconedButton(
          text: "Download",
          icon: Icon(Icons.download, color: Colors.white),
          color: AppTheme.accentColor,
        ),
        ButtonState.loading: const IconedButton(text: "Downloading", color: AppTheme.accentColor),
        ButtonState.fail: IconedButton(
            text: "Download Failure", icon: const Icon(Icons.cancel, color: Colors.white), color: Colors.red.shade300),
        ButtonState.success: IconedButton(
          text: "Download Success",
          icon: const Icon(
            Icons.check_circle,
            color: Colors.white,
          ),
          color: Colors.green.shade400,
        )
      },
      // stateColors: {
      //   ButtonState.idle: Colors.grey.shade400,
      //   ButtonState.loading: Colors.blue.shade300,
      //   ButtonState.fail: Colors.red.shade300,
      //   ButtonState.success: Colors.green.shade400,
      // },
      onPressed: onPressedDownload,
      state: stateOnlyText,
      padding: const EdgeInsets.all(8.0),
    );
    return progressTextButton;
  }
}
