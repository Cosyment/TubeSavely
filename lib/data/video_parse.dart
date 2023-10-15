import 'package:downloaderx/utils/json_utils.dart';

import '../models/video_info.dart';

class VideoParse {
  VideoParse({
    required this.title,
    this.size,
    this.totalBytes,
    required this.author,
    required this.cover,
    required this.videoUrl,
    required this.createTime,
    required this.videoList,
    required this.parseUrl,
    required this.type,
  });

  String title;
  String author;
  String cover;
  int type = 0; //0视频2图片
  int createTime;
  String videoUrl;
  int? totalBytes;
  String? size;
  String parseUrl;
  List<VideoInfo> videoList;

  factory VideoParse.fromJson(Map<String, dynamic> json) => VideoParse(
        title: json['title'] as String,
        size: json['size'] as String,
        type: json['type'] as int,
        totalBytes: json['totalBytes'] as int,
        author: json['author'] as String,
        cover: json['cover'] as String,
        videoUrl: json['videoUrl'] as String,
        parseUrl: json['parseUrl'] as String,
        createTime: json['createTime'] as int,
        videoList:
            json.asList<VideoInfo>('videoList', (v) => VideoInfo.fromJson(v)) ??
                [],
      );

  Map<String, dynamic> toJson() => {
        'title': title,
        'size': size,
        'totalBytes': totalBytes,
        'cover': cover,
        'type': type,
        'author': author,
        'videoUrl': videoUrl,
        'createTime': createTime,
        'parseUrl': parseUrl,
        'videoList': videoList.map((e) => e.toJson()).toList()
      };
}
