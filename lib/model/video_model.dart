class VideoModel {
  final String? title;
  final String? uploader;
  final String? url;
  final String? original_url;
  final List<FormatModel>? formats;
  final String? thumbnail;
  final String? music;
  final num? duration;
  final int? filesize;
  final String? extractor;

  VideoModel(
      {required this.title,
      required this.uploader,
      required this.formats,
      required this.url,
      required this.original_url,
      required this.thumbnail,
      required this.music,
      required this.duration,
      required this.extractor,
      required this.filesize});

  factory VideoModel.fromJson(Map<String, dynamic> json) {
    return VideoModel(
      title: json['title'],
      uploader: json['uploader'],
      url: json['url'],
      original_url: json['original_url'],
      formats: FormatModel.fromListJson(json['formats']),
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
      'formats': FormatModel.toListJson(formats),
      'original_url': original_url,
      'thumbnail': thumbnail,
      'music': music,
      'duration': duration,
      'filesize': filesize,
      'extractor': extractor,
    };
    return data;
  }
}

class FormatModel {
  final String? url;
  final String? ext;
  final String? video_ext;
  final String? audio_ext;
  final String? resolution;
  final num? filesize;
  final String? protocol;
  final String? format;
  final String? format_note;

  FormatModel(
      {required this.url,
      required this.resolution,
      required this.filesize,
      required this.ext,
      required this.video_ext,
      required this.audio_ext,
      required this.protocol,
      required this.format,
      required this.format_note});

  factory FormatModel.fromJson(Map<String, dynamic> json) {
    return FormatModel(
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

  static List<FormatModel> fromListJson(List json) {
    final format = <FormatModel>[];
    for (final item in json) {
      format.add(FormatModel.fromJson(item));
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

  static List<Map<String, dynamic>> toListJson(List<FormatModel>? formats) {
    final List<Map<String, dynamic>> data = <Map<String, dynamic>>[];
    for (var action in formats!) {
      data.add(action.toJson());
    }
    return data;
  }
}
