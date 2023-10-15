import 'dart:convert';
import 'dart:io';
import 'dart:math';

import '../../data/db_manager.dart';
import '../../data/video_parse.dart';
import '../../models/video_info.dart';

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
    Uri uri = Uri.parse(
        'https://proxy.layzz.cn/lyz/getAnalyse?token=rzwewdzrckc-auther-523ddd&link=${parseUrl}');

    HttpClientRequest request = await http.getUrl(uri);
    request.headers.set('Content-Type', 'application/json');
    HttpClientResponse response = await request.close();
    String responseBody = await response.transform(utf8.decoder).join();
    print(">>>>>>>>>${responseBody}");
    if (responseBody != null && responseBody.length > 0) {
      Map<String, dynamic> res = json.decode(responseBody);
      if (res['code'] == '0001') {
        var data = res['data'];
        if (data['type'] == 2) {
          var images = data['pics'];
          for (var i = 0; i < images.length; i++) {
            videoList.add(VideoInfo(
                label: '第${i + 1}张图片',
                size:
                    '${(0.5 + Random().nextDouble() * (0.9)).toStringAsFixed(2)}M',
                totalBytes: 0,
                url: images[i]));
          }
        } else {
          videoList.add(VideoInfo(
              label: '视频(高清)',
              size:
                  '${(0.5 + Random().nextDouble() * (0.9)).toStringAsFixed(2)}M',
              totalBytes: 0,
              url: data['playAddr']));
        }
        if (data['music'] != null) {
          videoList.add(VideoInfo(
              label: '音频',
              size:
                  '${(0.1 + Random().nextDouble() * (0.5)).toStringAsFixed(2)}M',
              totalBytes: 0,
              url: data['music']));
        }
        if (data['cover'] != null) {
          videoList.add(VideoInfo(
              label: '封面(高清)',
              size:
                  '${(0.1 + Random().nextDouble() * (0.5)).toStringAsFixed(2)}M',
              totalBytes: 0,
              url: data['cover']));
        }
        var videoParse = VideoParse(
            videoUrl: data['playAddr'] ?? "",
            parseUrl: parseUrl,
            title: data['desc'],
            author: "",
            type: data['type'] ?? 0,
            createTime: DateTime.now().millisecondsSinceEpoch,
            size: '',
            totalBytes: 0,
            cover: data['cover'],
            videoList: videoList);
        DbManager.instance().add(videoParse);
        onResult(videoParse);
      } else {
        onResult(null);
      }
    } else {
      onResult(null);
    }

    // Uri uri = Uri.parse('https://tenapi.cn/v2/video?url=${parseUrl}');
    // HttpClientRequest request = await http.getUrl(uri);
    // request.headers.set('Content-Type', 'application/json');
    // HttpClientResponse response = await request.close();
    // String responseBody = await response.transform(utf8.decoder).join();
    // if (responseBody != null && responseBody.length > 0) {
    //   print(">>>>>>>responseBody>>>>>>>>${responseBody}");
    //   Map<String, dynamic> res = json.decode(responseBody);
    //   if (res['code'] != 200) {
    //     onResult(null);
    //     return;
    //   }
    //   var data = res['data'];
    //   videoList.add(VideoInfo(
    //       label: '视频(高清)',
    //       size: '${(0.5 + Random().nextDouble() * (0.9)).toStringAsFixed(2)}M',
    //       totalBytes: 0,
    //       url: data['url']));
    //   videoList.add(VideoInfo(
    //       label: '封面(高清)',
    //       size: '${(0.1 + Random().nextDouble() * (0.5)).toStringAsFixed(2)}M',
    //       totalBytes: 0,
    //       url: data['cover']));
    //   var videoParse = VideoParse(
    //       videoUrl: data['url'],
    //       parseUrl: parseUrl,
    //       title: data['title'],
    //       author: data['author'],
    //       createTime: DateTime.now().millisecondsSinceEpoch,
    //       size: '',
    //       totalBytes: 0,
    //       cover: data['cover'],
    //       videoList: videoList);
    //   EventBus.getDefault().post(videoParse);
    //   DbManager.instance().add(videoParse);
    //   onResult(videoList);
    // } else {
    //   onResult(null);
    // }
  }
}
