import 'package:downloaderx/utils/json_utils.dart';

import '../models/video_info.dart';

class VideoParse {
  VideoParse({
    required this.title,
    this.size,
    this.totalBytes,
    required this.author,
    required this.cover,
    this.label,
    required this.createTime,
    required this.videoList,
    required this.url,
  });

  String title;
  String author;
  String cover;
  int createTime;
  String? label;
  int? totalBytes;
  String? size;
  String? url = "";
  List<VideoInfo> videoList;

  factory VideoParse.fromJson(Map<String, dynamic> json) => VideoParse(
        title: json['title'] as String,
        size: json['size'] as String,
        totalBytes: json['totalBytes'] as int,
        author: json['author'] as String,
        cover: json['cover'] as String,
        label: json['label'] as String,
        url: json['url'] as String,
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
        'label': label,
        'createTime': createTime,
        'url': url,
        'videoList': videoList.map((e) => e.toJson()).toList()
      };
}
