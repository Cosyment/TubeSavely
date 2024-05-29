class VideoInfo {
  final String? title;
  final String? uploader;
  final String? url;
  final List<FormatInfo>? formats;
  final String? thumbnail;
  final String? music;
  final num? duration;
  final int? filesize;
  final String? extractor;

  VideoInfo(
      {required this.title,
      required this.uploader,
      required this.formats,
      required this.url,
      required this.thumbnail,
      required this.music,
      required this.duration,
      required this.extractor,
      required this.filesize});

  factory VideoInfo.fromJson(Map<String, dynamic> json) {
    return VideoInfo(
      title: json['title'],
      uploader: json['uploader'],
      url: json['url'],
      formats: FormatInfo.fromListJson(json['formats']),
      thumbnail: json['thumbnail'],
      music: json['music'],
      duration: json['duration'],
      filesize: json['filesize'],
      extractor: json['extractor'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'title': title,
      'uploader': uploader,
      'url': url,
      'formats': FormatInfo.toListJson(formats),
      'thumbnail': thumbnail,
      'music': music,
      'duration': duration,
      'filesize': filesize,
      'extractor': extractor,
    };
    return data;
  }
}

class FormatInfo {
  final String? url;
  final String? ext;
  final String? video_ext;
  final String? audio_ext;
  final String? resolution;
  final num? filesize;
  final String? protocol;
  final String? format;
  final String? format_note;

  FormatInfo(
      {required this.url,
      required this.resolution,
      required this.filesize,
      required this.ext,
      required this.video_ext,
      required this.audio_ext,
      required this.protocol,
      required this.format,
      required this.format_note});

  factory FormatInfo.fromJson(Map<String, dynamic> json) {
    return FormatInfo(
      url: json['url'],
      resolution: json['resolution'],
      filesize: json['filesize'],
      ext: json['ext'],
      video_ext: json['video_ext'],
      audio_ext: json['audio_ext'],
      protocol: json['protocol'],
      format: json['format'],
      format_note: json['format_note'],
    );
  }

  static List<FormatInfo> fromListJson(List json) {
    final format = <FormatInfo>[];
    for (final item in json) {
      format.add(FormatInfo.fromJson(item));
    }
    return format;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'url': url,
      'resolution': resolution,
      'filesize': filesize,
      'ext': ext,
      'video_ext': video_ext,
      'audio_ext': audio_ext,
      'protocol': protocol,
      'format': format,
      'format_note': format_note,
    };

    return data;
  }

  static List<Map<String, dynamic>> toListJson(List<FormatInfo>? formats) {
    final List<Map<String, dynamic>> data = <Map<String, dynamic>>[];
    for (var action in formats!) {
      data.add(action.toJson());
    }
    return data;
  }
}
