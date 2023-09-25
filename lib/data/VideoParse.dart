class VideoParse {
  VideoParse(
      {required this.title, required this.totalBytes, required this.url});

  final String title;
  final int totalBytes;
  final String url;

  factory VideoParse.fromJson(Map<String, dynamic> json) => VideoParse(
        title: json['title'] as String,
        totalBytes: json['totalBytes'] as int,
        url: json['url'] as String,
      );

  Map<String, dynamic> toJson() =>
      {'title': title, 'totalBytes': totalBytes, 'url': url};
}
