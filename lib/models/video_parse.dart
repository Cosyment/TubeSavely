import 'package:downloaderx/utils/json_utils.dart';

import '../models/video_info.dart';

class VideoParse {
  VideoParse({
    required this.title,
    this.size,
    this.totalBytes,
    required this.author,
    required this.cover,
    required this.createTime,
    required this.videoList,
    required this.parseUrl,
  });

  String title;
  String author;
  String cover;
  int createTime;
  int? totalBytes;
  String? size;
  String parseUrl;
  List<VideoInfo> videoList;

  factory VideoParse.fromJson(Map<String, dynamic> json) => VideoParse(
        title: json['title'] as String,
        size: json['size'] as String,
        totalBytes: json['totalBytes'] as int,
        author: json['author'] as String,
        cover: json['cover'] as String,
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
        'author': author,
        'createTime': createTime,
        'parseUrl': parseUrl,
        'videoList': videoList.map((e) => e.toJson()).toList()
      };
}
