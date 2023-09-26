class CoverInfo {
  int width;
  int height;
  String url;

  CoverInfo({required this.width, required this.height, required this.url});

  factory CoverInfo.fromJson(Map<String, dynamic> json) => CoverInfo(
        width: json['width'] as int,
        height: json['height'] as int,
        url: json['url'] as String,
      );
}
