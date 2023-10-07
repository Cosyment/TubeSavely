import 'dart:convert';
import 'dart:io';
import 'dart:math';

import '../../data/db_manager.dart';
import '../../data/video_parse.dart';
import '../../models/video_info.dart';
import '../event_bus.dart';

class Other {
  static Other? _instance;
  late HttpClient http;

  factory Other.get() {
    return _instance ??= Other._init();
  }

  Other._init() {
    http = HttpClient();
  }

  void close() {
    http.close();
  }

  Future<void> parse(String parseUrl, Function onResult) async {
    List<VideoInfo> videoList = [];
    Uri uri = Uri.parse('https://tenapi.cn/v2/video?url=${parseUrl}');
    HttpClientRequest request = await http.getUrl(uri);
    request.headers.set('Content-Type', 'application/json');
    HttpClientResponse response = await request.close();
    String responseBody = await response.transform(utf8.decoder).join();
    if (responseBody != null && responseBody.length > 0) {
      print(">>>>>>>responseBody>>>>>>>>${responseBody}");
      Map<String, dynamic> res = json.decode(responseBody);
      if (res['code'] != 200) {
        onResult(null);
        return;
      }
      var data = res['data'];
      videoList.add(VideoInfo(
          label: '视频(高清)',
          size: '${(0.5 + Random().nextDouble() * (0.9)).toStringAsFixed(2)}M',
          totalBytes: 0,
          url: data['url']));
      videoList.add(VideoInfo(
          label: '封面(高清)',
          size: '${(0.1 + Random().nextDouble() * (0.5)).toStringAsFixed(2)}M',
          totalBytes: 0,
          url: data['cover']));
      var videoParse = VideoParse(
          videoUrl: data['url'],
          parseUrl: parseUrl,
          title: data['title'],
          author: data['author'],
          createTime: DateTime.now().millisecondsSinceEpoch,
          size: '',
          totalBytes: 0,
          cover: data['cover'],
          videoList: videoList);
      EventBus.getDefault().post(videoParse);
      DbManager.instance().add(videoParse);
      onResult(videoList);
    } else {
      onResult(null);
    }
  }
}
