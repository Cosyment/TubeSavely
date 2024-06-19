import 'dart:io';

import 'package:background_downloader/background_downloader.dart';
import 'package:flutter/material.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:open_file/open_file.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:tubesavely/core/ffmpeg/ffmpeg_executor.dart';
import 'package:tubesavely/storage/storage.dart';
import 'package:tubesavely/utils/platform_util.dart';
import 'package:tubesavely/utils/toast_util.dart';

class Downloader {
  static Future<String> get baseOutputPath async =>
      Storage().getString(StorageKeys.CACHE_DIR_KEY) ?? (await getTemporaryDirectory()).path;

  static combineDownload(String videoUrl, String title,
      {String? audioUrl,
      String? resolution,
      ProgressCallback? onProgress,
      VoidCallback? onSuccess,
      VoidCallback? onFailure}) async {
    if (videoUrl.isEmpty) {
      ToastUtil.error('下载链接无效！');
    }
    debugPrint('video url $videoUrl');

    if (videoUrl.contains('.m3u8')) {
      _downloadM3U8(videoUrl, title, onProgress, onSuccess, onFailure);
      return;
    }

    final videoFileName = resolution != null && resolution != '' ? "$title-$resolution.mp4" : '$title.mp4';
    Task videoTask = await _download(videoUrl, videoFileName, progressCallback: onProgress);
    Task? audioTask;
    if (audioUrl != null) {
      final audioFileName = "$title.mp3";
      audioTask = await _download(audioUrl, audioFileName, progressCallback: onProgress);
    }
    File videoFile = File(await videoTask.filePath());
    if (audioTask != null) {
      File audioFile = File(await audioTask.filePath());

      String outputPath = "${(await baseOutputPath)}/$title.mp4";
      File file = File(outputPath);
      if (file.existsSync()) {
        debugPrint('merge delete exists file : ${file.path}');
        await file.delete(recursive: true);
        debugPrint('merge exists file : ${await file.exists()}');
      }

      String? savePath = await FFmpegExecutor.merge(videoFile.path, audioFile.path, outputPath: outputPath);

      //合并成功保存合并后视频
      if (savePath?.isNotEmpty == true) {
        _save(outputPath, title: videoFileName, onSuccess: onSuccess, onFailure: onFailure);
      } else {
        //合并失败，只保存视频
        _save(videoFile.path, title: videoFileName, onSuccess: onSuccess, onFailure: onFailure);
      }
    } else {
      _save(videoFile.path, title: videoFileName, onSuccess: onSuccess, onFailure: onFailure);
    }
  }

  static downloadVideo(String url, String title,
      {ProgressCallback? progressCallback, VoidCallback? onSuccess, VoidCallback? onFailure}) async {
    Task task = await _download(url, '$title.mp4', progressCallback: progressCallback);
    _save(await task.filePath(), onSuccess: onSuccess, onFailure: onFailure);
  }

  static downloadAudio(String url, String title,
      {ProgressCallback? progressCallback, VoidCallback? onSuccess, VoidCallback? onFailure}) async {
    DownloadTask task = await _download(url, '$title.mp3', progressCallback: progressCallback);
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

  static _downloadM3U8(
      String m3u8Url, String title, ProgressCallback? progressCallback, VoidCallback? onSuccess, VoidCallback? onFailure) async {
    String outputPath = "${(await baseOutputPath)}/$title.mp4";

    File file = File(outputPath);
    if (file.existsSync()) {
      debugPrint('m3u8 download delete exists file : ${file.path}');
      file.deleteSync();
      debugPrint('m3u8 download exists file : ${await file.exists()}');
    }
    String? savePath = await FFmpegExecutor.download(m3u8Url, outputPath: outputPath, progressCallback: progressCallback);

    if (savePath?.isNotEmpty == true) {
      _save(outputPath, title: path.basename(File(outputPath).path), onSuccess: onSuccess, onFailure: onFailure);
    } else {
      onFailure?.call();
    }
  }

  static Future<DownloadTask> _download(String? url, String? fileName, {ProgressCallback? progressCallback}) async {
    final task = DownloadTask(
      url: url ?? '',
      filename: fileName,
      // directory: 'TubeSavely/Files',
      directory: await baseOutputPath,
      baseDirectory: BaseDirectory.root,
      updates: Updates.statusAndProgress,
      requiresWiFi: false,
      retries: Storage().getInt(StorageKeys.RETRY_COUNT_KEY) ?? 3,
      allowPause: true,
    );

    File file = File(await task.filePath());
    if (file.existsSync()) {
      debugPrint('download delete exists file : ${file.path}');
      file.deleteSync();
      debugPrint('download exists file : ${await file.exists()}');
    }

    final result = await FileDownloader().download(task,
        onProgress: (progress) =>
            {debugPrint('Download Task Progress: ${progress * 100}% ${task.filename}'), progressCallback?.call(progress * 100)},
        onStatus: (status) => debugPrint('Download Task Status: $status'));

    debugPrint('_download result $result');
    return task;
  }

  static _save(String path, {String? title = 'videoplayback', VoidCallback? onSuccess, VoidCallback? onFailure}) async {
    String outputPath = "${(await baseOutputPath)}/$title";

    String? savePath = outputPath;
    if (Storage().getBool(StorageKeys.AUTO_RECODE_KEY)) {
      //部分视频在ios设备无法播放，因此保存前先用ffmpeg对视频重编码为MPEG-4以便支持ios设备
      // await FFmpegKit.execute('-i "$path" -err_detect ignore_err -c:v mpeg4 -y "$outputPath"');
      savePath = await FFmpegExecutor.reEncode(path, outputPath: outputPath);
    }
    if (PlatformUtil.isMobile) {
      dynamic result = await ImageGallerySaver.saveFile(savePath ?? outputPath, name: title, isReturnPathOfIOS: true);
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
    } else {
      onSuccess?.call();
      ToastUtil.success('Download Success');
    }
  }

  //*********************************************example*****************************************************//
  static testDownload(String? url, String? fileName) async {
    if (url?.isEmpty == true) throw Exception('URL can not be empty');

    // DownloadUtils.downloadVideo(url ?? '', (progress) {});
    final task = DownloadTask(
      url: url ?? '',
      filename: '$fileName.mp4',
      // directory: 'TubeSavely/Files',
      // baseDirectory: BaseDirectory.applicationDocuments,
      directory: (await getDownloadsDirectory())?.path ?? '',
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
        if (PlatformUtil.isMacOS) {
          try {
            // 获取文档目录路径
            Directory? appDocDir = await getDownloadsDirectory();

            // 文件名和路径
            String filePath = await task.filePath();

            print('文件名: $fileName');
            print('文件已保存至: $filePath');
          } catch (e) {
            print('保存文件时发生错误: $e');
          }
        }
        if (PlatformUtil.isMobile) {
          var result = await ImageGallerySaver.saveFile(await task.filePath(), name: fileName, isReturnPathOfIOS: true);
          if (result['isSuccess']) {
            ToastUtil.success('Download Success');
          } else {
            ToastUtil.error(result['errorMessage']);
          }
        }
      case TaskStatus.canceled:
        debugPrint('Download was canceled');
      case TaskStatus.paused:
        debugPrint('Download was paused');
      default:
        debugPrint('Download not successful');
    }
  }
}
