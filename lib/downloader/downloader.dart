import 'dart:io';

import 'package:background_downloader/background_downloader.dart'; // import 'package:ffmpeg_kit_flutter/ffmpeg_kit.dart';
// import 'package:ffmpeg_kit_flutter/ffmpeg_kit.dart';
// import 'package:ffmpeg_kit_flutter/ffmpeg_session.dart';
// import 'package:ffmpeg_kit_flutter/return_code.dart';
import 'package:ffmpeg_kit_flutter_full_gpl/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter_full_gpl/ffmpeg_session.dart';
import 'package:ffmpeg_kit_flutter_full_gpl/return_code.dart';
import 'package:flutter/material.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:open_file/open_file.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:tubesavely/utils/toast_util.dart';

class Downloader {
  static combineDownload(String videoUrl, String title,
      {String? audioUrl, String? resolution, VoidCallback? onSuccess, VoidCallback? onFailure}) async {
    if (videoUrl.isEmpty) {
      throw Exception('Video URL can not be empty');
    }
    debugPrint('video url $videoUrl');

    if (videoUrl.contains('.m3u8')) {
      _downloadM3U8(videoUrl, title, onSuccess, onFailure);
      return;
    }

    final videoFileName = resolution != null && resolution != '' ? "$title-$resolution.mp4" : '$title.mp4';
    Task videoTask = await _download(videoUrl, videoFileName);
    Task? audioTask;
    if (audioUrl != null) {
      final audioFileName = "$title.mp3";
      audioTask = await _download(audioUrl, audioFileName);
    }
    File videoFile = File(await videoTask.filePath());
    if (audioTask != null) {
      File audioFile = File(await audioTask.filePath());

      // String audioOutPath = '${(await getTemporaryDirectory()).path}/$title.mp3';
      // await FFmpegKit.execute('-i "${audioFile.path}" -c:a aac "$audioOutPath"');

      String outputPath = "${(await getTemporaryDirectory()).path}/$title.mp4";
      File file = File(outputPath);
      if (file.existsSync()) {
        debugPrint('merge delete exists file : ${file.path}');
        await file.delete(recursive: true);
        debugPrint('merge exists file : ${await file.exists()}');
      }

      final command = '-i "${videoFile.path}" -i "${audioFile.path}" -c:v copy -c:a aac -pix_fmt yuv420p -y "$outputPath"';
      // final command =
      //     'ffmpeg -i "${videoFile.path}" -i "${audioFile.path}" -c:v copy -c:a aac -pix_fmt yuv420p -strict experimental -map 0:v:0 -map 1:a:0 -y "$outputPath"';

      FFmpegSession session = await FFmpegKit.execute(command);
      ReturnCode? code = await session.getReturnCode();

      //合并成功保存合并后视频
      if (ReturnCode.isSuccess(code)) {
        debugPrint('merge success');
        _save(outputPath, title: videoFileName, encode: true, onSuccess: onSuccess, onFailure: onFailure);
      } else {
        debugPrint('merge error ${await session.getLogs()}');
        //合并失败，只保存视频
        _save(videoFile.path, title: videoFileName, encode: true, onSuccess: onSuccess, onFailure: onFailure);
      }
    } else {
      _save(videoFile.path, title: videoFileName, encode: true, onSuccess: onSuccess, onFailure: onFailure);
    }
  }

  static downloadVideo(String url, String title, {VoidCallback? onSuccess, VoidCallback? onFailure}) async {
    Task task = await _download(url, '$title.mp4');
    _save(await task.filePath(), onSuccess: onSuccess, onFailure: onFailure);
  }

  static downloadAudio(String url, String title, {VoidCallback? onSuccess, VoidCallback? onFailure}) async {
    DownloadTask task = await _download(url, '$title.mp3');
    File file = File(await task.filePath());
    if (file.existsSync()) {
      final result = await OpenFile.open(await task.filePath());
      if (result.type == ResultType.done) {
        onSuccess?.call();
        ToastUtil.success('Download Success');
      } else {
        onFailure?.call();
        ToastUtil.error('Download error please try again');
      }
    }
  }

  static _downloadM3U8(String m3u8Url, String title, VoidCallback? onSuccess, VoidCallback? onFailure) async {
    String outputPath = "${(await getTemporaryDirectory()).path}/$title.mp4";

    File file = File(outputPath);
    if (file.existsSync()) {
      debugPrint('m3u8 download delete exists file : ${file.path}');
      file.deleteSync();
      debugPrint('m3u8 download exists file : ${await file.exists()}');
    }
    final command = '-i "$m3u8Url" -c copy -bsf:a aac_adtstoasc -y "$outputPath"';
    // final command = '-i "$m3u8Url" -map 0 -s 1280x720 -f mp4 -y $outputPath"';

    FFmpegSession session = await FFmpegKit.execute(command);
    if (ReturnCode.isSuccess(await session.getReturnCode())) {
      _save(outputPath, title: path.basename(File(outputPath).path), encode: false, onSuccess: onSuccess, onFailure: onFailure);
    } else {
      onFailure?.call();
    }
  }

  static Future<DownloadTask> _download(String? url, String? fileName) async {
    final task = DownloadTask(
      url: url ?? '',
      filename: fileName,
      directory: 'TubeSavely/Files',
      baseDirectory: BaseDirectory.temporary,
      updates: Updates.statusAndProgress,
      requiresWiFi: false,
      retries: 5,
      allowPause: true,
    );

    File file = File(await task.filePath());
    if (file.existsSync()) {
      debugPrint('download delete exists file : ${file.path}');
      file.deleteSync();
      debugPrint('download exists file : ${await file.exists()}');
    }

    final result = await FileDownloader().download(task,
        onProgress: (progress) => debugPrint('Download Task Progress: ${progress * 100}% ${task.filename}'),
        onStatus: (status) => debugPrint('Download Task Status: $status'));

    debugPrint('_download result $result');
    return task;
  }

  static _save(String path,
      {String? title = 'videoplayback', bool? encode = true, VoidCallback? onSuccess, VoidCallback? onFailure}) async {
    String outputPath = "${(await getTemporaryDirectory()).path}/$title";

    if (encode == true) {
      //部分视频在ios设备无法播放，因此保存前先用ffmpeg对视频重编码为MPEG-4以便支持ios设备
      await FFmpegKit.execute('-i "$path" -err_detect ignore_err -c:v mpeg4 -y "$outputPath"');
    }
    dynamic result = await ImageGallerySaver.saveFile(outputPath, name: title, isReturnPathOfIOS: true);
    debugPrint('save result $result');
    if (result['isSuccess']) {
      onSuccess?.call();
      ToastUtil.success('Download Success');
    } else {
      // onFailure?.call();
      final result = await OpenFile.open(outputPath);
      if (result.type == ResultType.done) {
        onSuccess?.call();
        ToastUtil.success('Download Success');
      } else {
        onFailure?.call();
        ToastUtil.error('Download error please try again');
      }
    }
  }

  static download(String? url, String? fileName) async {
    if (url?.isEmpty == true) throw Exception('URL can not be empty');

    // DownloadUtils.downloadVideo(url ?? '', (progress) {});
    final task = DownloadTask(
      url: url ?? '',
      filename: '$fileName.mp4',
      directory: 'TubeSavely/Files',
      updates: Updates.statusAndProgress,
      requiresWiFi: false,
      retries: 5,
      allowPause: true,
    );

// Start download, and wait for result. Show progress and status changes
    final result = await FileDownloader().download(task,
        onProgress: (progress) => debugPrint('Progress: ${progress * 100}% ${task.filename}'),
        onStatus: (status) => debugPrint('Status: $status'));

    switch (result.status) {
      case TaskStatus.complete:
        var result = await ImageGallerySaver.saveFile(await task.filePath(), name: fileName, isReturnPathOfIOS: true);
        if (result['isSuccess']) {
          ToastUtil.success('Download Success');
        } else {
          ToastUtil.error(result['errorMessage']);
        }
      case TaskStatus.canceled:
        debugPrint('Download was canceled');
      case TaskStatus.paused:
        debugPrint('Download was paused');
      default:
        debugPrint('Download not successful');
    }
  }

  static Future<String?> _httpDownload(String url) async {
    try {
      final response = await HttpClient().getUrl(Uri.parse(url));
      final httpClientResponse = await response.close();

      final Directory tempDir = await getTemporaryDirectory();
      String appDocPath = tempDir.path;
      int totalBytes = httpClientResponse.contentLength;
      String contentType = httpClientResponse.headers.contentType!.mimeType;
      // int lastDotIndex = url.lastIndexOf(".");
      // String mediaType = url.substring(lastDotIndex);
      String mediaType = contentType.substring(contentType.lastIndexOf("/") + 1);
      var fileName = "${DateTime.now().millisecondsSinceEpoch}.$mediaType";
      debugPrint(
          'Success to load appDocPath>>>>>>>>>>>>: $appDocPath  contentLength=${httpClientResponse.contentLength}   contentType==$contentType');
      File file = File('$appDocPath/$fileName');
      var fileStream = file.openWrite();
      var receivedBytes = 0;
      await for (var data in httpClientResponse) {
        fileStream.add(data);
        receivedBytes += data.length;
        String progress = (receivedBytes / totalBytes).toStringAsFixed(2);
        debugPrint('Download Progress: ${(progress)}>>>>>>>>>>$receivedBytes>>>>>$totalBytes');
        // if (callback != null) {
        //   callback(double.parse(progress));
        // }
      }
      await fileStream.flush();
      await fileStream.close();
      debugPrint('-----------video file exists ${file}--${file.existsSync()}');
      debugPrint('File downloaded successfully');
      // if (PlatformUtils.isAndroidOrIOS) {
      //   final result = await ImageGallerySaver.saveFile(file.path);
      //   debugPrint('Success to ImageGallerySaver>>>>>>>>>>>>:${file.path} , ${result}');
      // }
      return file.path;
    } catch (e) {
      return null;
    }
  }
}
