enum DownloadStatus {
  pending,
  downloading,
  paused,
  completed,
  failed,
  canceled,
}

class DownloadTaskModel {
  final String id;
  final String videoId;
  final String title;
  final String url;
  final String? thumbnail;
  final String? platform;
  final String? quality;
  final String? format;
  final String? savePath;
  final int totalBytes;
  final int downloadedBytes;
  final DownloadStatus status;
  final String? errorMessage;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final DateTime? completedAt;

  DownloadTaskModel({
    required this.id,
    required this.videoId,
    required this.title,
    required this.url,
    this.thumbnail,
    this.platform,
    this.quality,
    this.format,
    this.savePath,
    this.totalBytes = 0,
    this.downloadedBytes = 0,
    this.status = DownloadStatus.pending,
    this.errorMessage,
    required this.createdAt,
    this.updatedAt,
    this.completedAt,
  });

  factory DownloadTaskModel.fromJson(Map<String, dynamic> json) {
    return DownloadTaskModel(
      id: json['id'],
      videoId: json['video_id'],
      title: json['title'],
      url: json['url'],
      thumbnail: json['thumbnail'],
      platform: json['platform'],
      quality: json['quality'],
      format: json['format'],
      savePath: json['save_path'],
      totalBytes: json['total_bytes'] ?? 0,
      downloadedBytes: json['downloaded_bytes'] ?? 0,
      status: DownloadStatus.values.firstWhere(
        (e) => e.toString() == 'DownloadStatus.${json['status']}',
        orElse: () => DownloadStatus.pending,
      ),
      errorMessage: json['error_message'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
      completedAt: json['completed_at'] != null
          ? DateTime.parse(json['completed_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'video_id': videoId,
      'title': title,
      'url': url,
      'thumbnail': thumbnail,
      'platform': platform,
      'quality': quality,
      'format': format,
      'save_path': savePath,
      'total_bytes': totalBytes,
      'downloaded_bytes': downloadedBytes,
      'status': status.toString().split('.').last,
      'error_message': errorMessage,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'completed_at': completedAt?.toIso8601String(),
    };
  }

  DownloadTaskModel copyWith({
    String? id,
    String? videoId,
    String? title,
    String? url,
    String? thumbnail,
    String? platform,
    String? quality,
    String? format,
    String? savePath,
    int? totalBytes,
    int? downloadedBytes,
    DownloadStatus? status,
    String? errorMessage,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? completedAt,
  }) {
    return DownloadTaskModel(
      id: id ?? this.id,
      videoId: videoId ?? this.videoId,
      title: title ?? this.title,
      url: url ?? this.url,
      thumbnail: thumbnail ?? this.thumbnail,
      platform: platform ?? this.platform,
      quality: quality ?? this.quality,
      format: format ?? this.format,
      savePath: savePath ?? this.savePath,
      totalBytes: totalBytes ?? this.totalBytes,
      downloadedBytes: downloadedBytes ?? this.downloadedBytes,
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      completedAt: completedAt ?? this.completedAt,
    );
  }

  double get progress {
    if (totalBytes == 0) return 0;
    return downloadedBytes / totalBytes;
  }

  String get progressText {
    if (totalBytes == 0) return '0%';
    return '${(progress * 100).toStringAsFixed(1)}%';
  }

  String get formattedTotalBytes {
    if (totalBytes < 1024) {
      return '$totalBytes B';
    } else if (totalBytes < 1024 * 1024) {
      return '${(totalBytes / 1024).toStringAsFixed(2)} KB';
    } else if (totalBytes < 1024 * 1024 * 1024) {
      return '${(totalBytes / (1024 * 1024)).toStringAsFixed(2)} MB';
    } else {
      return '${(totalBytes / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB';
    }
  }

  String get formattedDownloadedBytes {
    if (downloadedBytes < 1024) {
      return '$downloadedBytes B';
    } else if (downloadedBytes < 1024 * 1024) {
      return '${(downloadedBytes / 1024).toStringAsFixed(2)} KB';
    } else if (downloadedBytes < 1024 * 1024 * 1024) {
      return '${(downloadedBytes / (1024 * 1024)).toStringAsFixed(2)} MB';
    } else {
      return '${(downloadedBytes / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB';
    }
  }

  String get statusText {
    switch (status) {
      case DownloadStatus.pending:
        return '等待中';
      case DownloadStatus.downloading:
        return '下载中';
      case DownloadStatus.paused:
        return '已暂停';
      case DownloadStatus.completed:
        return '已完成';
      case DownloadStatus.failed:
        return '下载失败';
      case DownloadStatus.canceled:
        return '已取消';
    }
  }
}
