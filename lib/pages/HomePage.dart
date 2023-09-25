import 'dart:io';

import 'package:downloaderx/data/DbManager.dart';
import 'package:downloaderx/utils/DownloadUtils.dart';
import 'package:downloaderx/widget/VideoXWidget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_player/video_player.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

import '../data/VideoParse.dart';
import '../models/ParseInfo.dart';
// import 'package:savely/savely.dart';

//
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
  bool isLoading = true;

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
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text("DownloaderX"),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(
            height: 20,
          ),
          const Image(
            width: 400,
            height: 140,
            image: AssetImage('assets/banner.png'),
          ),
          Row(
            children: [
              Container(
                margin: const EdgeInsets.only(
                    bottom: 15, top: 15, left: 15, right: 15),
                width: MediaQuery.of(context).size.width - 30,
                height: 48,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.inversePrimary,
                  borderRadius: BorderRadius.circular(8), // 圆角半径
                ),
                child: Center(
                  child: TextField(
                    maxLines: 1,
                    textAlignVertical: TextAlignVertical.center,
                    controller: textController,
                    textInputAction: TextInputAction.done,
                    onSubmitted: (value) => startParse(),
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      hintText: "请输入视频地址",
                      hintStyle: TextStyle(color: Colors.white),
                      border: OutlineInputBorder(borderSide: BorderSide.none),
                      focusedBorder:
                          OutlineInputBorder(borderSide: BorderSide.none),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: EdgeInsets.symmetric(horizontal: 15),
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
                  width: 120,
                  height: 44,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.inversePrimary,
                    borderRadius: BorderRadius.circular(8), // 圆角半径
                  ),
                  child: const Text(
                    "粘贴",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold),
                  ),
                ),
                onTap: () {
                  pasteText();
                },
              ),
              SizedBox(
                width: 20,
              ),
              InkWell(
                child: Container(
                  width: 120,
                  height: 44,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.inversePrimary,
                    borderRadius: BorderRadius.circular(8), // 圆角半径
                  ),
                  child: const Text(
                    "解析视频",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold),
                  ),
                ),
                onTap: () {
                  startParse();
                },
              )
            ],
          ),
          Container(
              margin: EdgeInsets.all(15),
              child:
                  VideoXWidget(isLoading: isLoading, controller: _controller)),
          Container(
            height: 65,
            child: GridView.builder(
              physics: NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 0,
                  mainAxisSpacing: 0,
                  childAspectRatio: 3.5),
              itemCount: videoList.length,
              itemBuilder: (BuildContext context, int index) {
                return gridItemWidget(context, videoList[index]);
              },
            ),
          )
        ],
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  gridItemWidget(BuildContext context, ParseInfo info) {
    return InkWell(
      child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              info.label,
              style: const TextStyle(fontSize: 10),
            ),
            Text(info.size, style: const TextStyle(fontSize: 10))
          ]),
      onTap: () {
        download(info.url.toString(), info.totalBytes);
      },
    );
  }

  Future<void> startParse() async {
    setState(() {
      videoList.clear();
      isLoading = true;
    });
    final yt = YoutubeExplode();
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
        title: info.url.authority,
        totalBytes: info.size.totalBytes,
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

  void handleProgressUpdate(double progress) {}
}
