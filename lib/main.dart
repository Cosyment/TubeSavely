import 'package:flutter/material.dart';

// import 'package:youtube_explode_dart/youtube_explode_dart.dart';
import 'package:savely/savely.dart';

import 'detail.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'YouToDownloader'),
      routes: {
        "/detail": (context) => const DetailPage(),
      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final TextEditingController textController = TextEditingController();

  // List<VideoStreamInfo> videoList = [];

  List<String> videoList = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            children: [
              Container(
                margin: const EdgeInsets.only(bottom: 15, top: 25, left: 15, right: 15),
                color: Colors.orange,
                width: MediaQuery.of(context).size.width - 30,
                padding: const EdgeInsets.symmetric(horizontal: 5),
                child: TextField(
                  maxLines: null,
                  controller: textController..value = TextEditingValue(text: 'https://www.youtube.com/watch?v=Ek1QD7AH9XQ'),
                  textInputAction: TextInputAction.done,
                  onSubmitted: (value) => startParse(),
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: "请输入视频地址",
                    hintStyle: const TextStyle(color: Colors.white),
                    suffixIcon: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        InkWell(
                          child: Text(
                            "解析",
                            style: TextStyle(color: Colors.white),
                          ),
                          onTap: () {
                            startParse();
                          },
                        )
                      ],
                    ),
                    border: const OutlineInputBorder(borderSide: BorderSide.none),
                    focusedBorder: const OutlineInputBorder(borderSide: BorderSide.none),
                    enabledBorder: const OutlineInputBorder(
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
            ],
          ),
          Container(
            height: 400,
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4, crossAxisSpacing: 10.0, mainAxisSpacing: 10.0, childAspectRatio: 0.8),
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

  gridItemWidget(BuildContext context, String url) {
    return InkWell(
      child: Column(children: [
        Text('info.qualityLabel'),
        Text('info.size.totalMegaBytes.floorToDouble().toString()' + 'M'),
        Text('info.container.name')
      ]),
      onTap: () {
        Navigator.pushNamed(context, "/detail", arguments: <String, String>{
          'url': url,
        });
      },
    );
  }

  Future<void> startParse() async {
    Savely savely = Savely();
    await savely.down(textController.text);
    await savely.down("https://vimeo.com/846209095");
    print('source : ${savely.source}');
    print('title : ${savely.title}');
    print('duration : ${savely.duration}');
    print('thumbnail : ${savely.thumbnail}');
    print('website : ${savely.website}');
    print('data : ${savely.data}');
  }

// gridItemWidget(BuildContext context, VideoStreamInfo info) {
//   return InkWell(
//     child: Column(children: [Text(info.qualityLabel),Text(info.size.totalMegaBytes.floorToDouble().toString()+'M'),  Text(info.container.name)]),
//     onTap: () {
//       Navigator.pushNamed(context, "/detail", arguments: <String, String>{
//         'url': info.url.toString(),
//       });
//     },
//   );
// }
//
// Future<void> startParse() async {
//   final yt = YoutubeExplode();
//   var manifest =
//   await yt.videos.streamsClient.getManifest(textController.text);
//   setState(() {
//     videoList.addAll(manifest.muxed);
//   });
//   yt.close();
// }
//
// Future<void> download() async {
//   final yt = YoutubeExplode();
//   yt.close();
// }
}
