class VideoParse {
  VideoParse(
      {required this.title,
      required this.totalBytes,
      required this.author,
      required this.cover,
      required this.url});

  final String title;
  final int totalBytes;
  final String author;
  final String url;
  final String cover;

  factory VideoParse.fromJson(Map<String, dynamic> json) => VideoParse(
        title: json['title'] as String,
        totalBytes: json['totalBytes'] as int,
        author: json['author'] as String,
        url: json['url'] as String,
        cover: json['cover'] as String,
      );

  Map<String, dynamic> toJson() => {
        'title': title,
        'totalBytes': totalBytes,
        'url': url,
        'cover': cover,
        'author': author
      };
}
