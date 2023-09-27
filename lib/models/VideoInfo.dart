class VideoInfo {
  VideoInfo({
    required this.label,
    required this.size,
    required this.totalBytes,
    required this.url,
  });

  String label;
  String size;
  int totalBytes;
  String url;

  factory VideoInfo.fromJson(Map<dynamic, dynamic> json) => VideoInfo(
        label: json['label'] as String,
        size: json['size'] as String,
        totalBytes: json['totalBytes'] as int,
        url: json['url'] as String,
      );

  Map<String, dynamic> toJson() => {
        'label': label,
        'size': size,
        'totalBytes': totalBytes,
        'url': url,
      };
}
