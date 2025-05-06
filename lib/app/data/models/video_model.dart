class VideoModel {
  final String? id;
  final String title;
  final String url;
  final String? thumbnail;
  final String? platform;
  final String? author;
  final String? authorUrl;
  final int? duration; // 视频时长（秒）
  final List<VideoQuality> qualities;
  final List<VideoFormat> formats;
  final DateTime? createdAt;

  VideoModel({
    this.id,
    required this.title,
    required this.url,
    this.thumbnail,
    this.platform,
    this.author,
    this.authorUrl,
    this.duration,
    this.qualities = const [],
    this.formats = const [],
    this.createdAt,
  });

  factory VideoModel.fromJson(Map<String, dynamic> json) {
    return VideoModel(
      id: json['id'],
      title: json['title'] ?? '',
      url: json['url'] ?? '',
      thumbnail: json['thumbnail'],
      platform: json['platform'],
      author: json['author'],
      authorUrl: json['author_url'],
      duration: json['duration'],
      qualities: json['qualities'] != null
          ? List<VideoQuality>.from(
              json['qualities'].map((x) => VideoQuality.fromJson(x)))
          : [],
      formats: json['formats'] != null
          ? List<VideoFormat>.from(
              json['formats'].map((x) => VideoFormat.fromJson(x)))
          : [],
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'url': url,
      'thumbnail': thumbnail,
      'platform': platform,
      'author': author,
      'author_url': authorUrl,
      'duration': duration,
      'qualities': qualities.map((x) => x.toJson()).toList(),
      'formats': formats.map((x) => x.toJson()).toList(),
      'created_at': createdAt?.toIso8601String(),
    };
  }

  VideoModel copyWith({
    String? id,
    String? title,
    String? url,
    String? thumbnail,
    String? platform,
    String? author,
    String? authorUrl,
    int? duration,
    List<VideoQuality>? qualities,
    List<VideoFormat>? formats,
    DateTime? createdAt,
  }) {
    return VideoModel(
      id: id ?? this.id,
      title: title ?? this.title,
      url: url ?? this.url,
      thumbnail: thumbnail ?? this.thumbnail,
      platform: platform ?? this.platform,
      author: author ?? this.author,
      authorUrl: authorUrl ?? this.authorUrl,
      duration: duration ?? this.duration,
      qualities: qualities ?? this.qualities,
      formats: formats ?? this.formats,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  String get formattedDuration {
    if (duration == null) return '';
    final minutes = (duration! ~/ 60).toString().padLeft(2, '0');
    final seconds = (duration! % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }
}

class VideoQuality {
  final String label; // 例如：'1080p', '720p', '480p'
  final int height;
  final int width;
  final int bitrate;
  final String url;

  VideoQuality({
    required this.label,
    required this.height,
    required this.width,
    required this.bitrate,
    required this.url,
  });

  factory VideoQuality.fromJson(Map<String, dynamic> json) {
    return VideoQuality(
      label: json['label'] ?? '',
      height: json['height'] ?? 0,
      width: json['width'] ?? 0,
      bitrate: json['bitrate'] ?? 0,
      url: json['url'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'label': label,
      'height': height,
      'width': width,
      'bitrate': bitrate,
      'url': url,
    };
  }
}

class VideoFormat {
  final String label; // 例如：'mp4', 'webm', 'mp3'
  final String mimeType;
  final String url;
  final int? fileSize;

  VideoFormat({
    required this.label,
    required this.mimeType,
    required this.url,
    this.fileSize,
  });

  factory VideoFormat.fromJson(Map<String, dynamic> json) {
    return VideoFormat(
      label: json['label'] ?? '',
      mimeType: json['mime_type'] ?? '',
      url: json['url'] ?? '',
      fileSize: json['file_size'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'label': label,
      'mime_type': mimeType,
      'url': url,
      'file_size': fileSize,
    };
  }

  String get formattedFileSize {
    if (fileSize == null) return '';
    if (fileSize! < 1024) {
      return '$fileSize B';
    } else if (fileSize! < 1024 * 1024) {
      return '${(fileSize! / 1024).toStringAsFixed(2)} KB';
    } else if (fileSize! < 1024 * 1024 * 1024) {
      return '${(fileSize! / (1024 * 1024)).toStringAsFixed(2)} MB';
    } else {
      return '${(fileSize! / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB';
    }
  }
}
