import 'dart:ffi';

class VideoParse {
  VideoParse(
      {required this.title,
      this.size,
      this.totalBytes,
      required this.author,
      required this.cover,
      this.url,
      this.label,
      required this.createTime});

  String title;
  int? totalBytes;
  String? size;
  String author;
  String? url;
  String? label;
  String cover;
  int createTime;

  factory VideoParse.fromJson(Map<String, dynamic> json) => VideoParse(
        title: json['title'] as String,
        size: json['size'] as String,
        totalBytes: json['totalBytes'] as int,
        author: json['author'] as String,
        url: json['url'] as String,
        cover: json['cover'] as String,
        label: json['label'] as String,
        createTime: json['createTime'] as int,
      );

  Map<String, dynamic> toJson() => {
        'title': title,
        'size': size,
        'totalBytes': totalBytes,
        'url': url,
        'cover': cover,
        'author': author,
        'label': label,
        'createTime': createTime
      };
}
