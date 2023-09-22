import 'package:flutter/material.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:video_player/video_player.dart';
// import 'package:savely/savely.dart';

//
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController textController = TextEditingController();
  List<VideoStreamInfo> videoList = [];
  late VideoPlayerController _controller;
  bool isLoading = true;
  String currentUrl = "";

  // List<String> videoList = [];
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
                    bottom: 15, top: 25, left: 15, right: 15),
                width: MediaQuery.of(context).size.width - 30,
                height: 60,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.inversePrimary,
                  borderRadius: BorderRadius.circular(8), // 圆角半径
                ),
                child: TextField(
                  maxLines: null,
                  textAlignVertical: TextAlignVertical.center,
                  controller: textController
                    ..value = TextEditingValue(
                        text: 'https://www.youtube.com/watch?v=Ek1QD7AH9XQ'),
                  textInputAction: TextInputAction.done,
                  onSubmitted: (value) => startParse(),
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: "请输入视频地址",
                    hintStyle: const TextStyle(color: Colors.white),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 15),
                  ),
                ),
              ),
            ],
          ),
          Center(
            child: InkWell(
              child: Container(
                width: 200,
                height: 50,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.inversePrimary,
                  borderRadius: BorderRadius.circular(30), // 圆角半径
                ),
                child: const Text(
                  "解析视频",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold),
                ),
              ),
              onTap: () {
                startParse();
              },
            ),
          ),
          Container(
            height: 200,
            margin: EdgeInsets.all(15),
            child: isLoading
                ? Center(
                    child: const SizedBox(
                      width: 50, // 设置指示器的宽度
                      height: 50, // 设置指示器的高度
                      child: CircularProgressIndicator(
                        strokeWidth: 3.0, // 设置指示器的线条宽度
                      ),
                    ),
                  )
                : VideoPlayer(_controller),
          )
          // Container(
          //   height: 200,
          //   child: GridView.builder(
          //     gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          //         crossAxisCount: 4,
          //         crossAxisSpacing: 10.0,
          //         mainAxisSpacing: 10.0,
          //         childAspectRatio: 0.8),
          //     itemCount: videoList.length,
          //     itemBuilder: (BuildContext context, int index) {
          //       return gridItemWidget(context, videoList[index]);
          //     },
          //   ),
          // )
        ],
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  // gridItemWidget(BuildContext context, String url) {
  //   return InkWell(
  //     child: Column(children: [
  //       Text('info.qualityLabel'),
  //       Text('info.size.totalMegaBytes.floorToDouble().toString()' + 'M'),
  //       Text('info.container.name')
  //     ]),
  //     onTap: () {
  //       Navigator.pushNamed(context, "/detail", arguments: <String, String>{
  //         'url': url,
  //       });
  //     },
  //   );
  // }

  // Future<void> startParse() async {
  //   Savely savely = Savely();
  //   await savely.down(textController.text);
  //   print('source : ${savely.source}');
  //   print('title : ${savely.title}');
  //   print('duration : ${savely.duration}');
  //   print('thumbnail : ${savely.thumbnail}');
  //   print('website : ${savely.website}');
  //   print('data : ${savely.data}');
  // }

  gridItemWidget(BuildContext context, VideoStreamInfo info) {
    return InkWell(
      child: Column(children: [Text(info.toString())]),
      onTap: () {
        download(info.url.toString());
      },
    );
  }

  Future<void> startParse() async {
    final yt = YoutubeExplode();
    var manifest =
        await yt.videos.streamsClient.getManifest(textController.text);
    setState(() {
      videoList.addAll(manifest.muxed);
      videoList.addAll(manifest.videoOnly);
      VideoStreamInfo info = manifest.muxed.bestQuality;
      currentUrl = info.url.toString();
      print('currentUrl : ${currentUrl}');
      _controller = VideoPlayerController.networkUrl(Uri.parse(currentUrl))
        ..initialize().then((_) {
          _controller.play();
          setState(() {
            isLoading = false;
          });
        });

      print('data : ${videoList}');
    });
    yt.close();
  }

  Future<void> download(url) async {
    final taskId = await FlutterDownloader.enqueue(
      url: url, // 要下载的文件的 URL
      savedDir: url, // 下载文件保存的目录
      showNotification: true, // 是否显示下载通知
      openFileFromNotification: true, // 下载完成后是否自动打开文件
    );
  }
}
