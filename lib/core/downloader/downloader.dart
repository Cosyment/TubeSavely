import 'dart:async';
import 'dart:io';

import 'package:background_downloader/background_downloader.dart';
import 'package:flutter/material.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:tubesavely/core/callback/callback.dart';
import 'package:tubesavely/core/ffmpeg/ffmpeg_executor.dart';
import 'package:tubesavely/generated/l10n.dart';
import 'package:tubesavely/model/emuns.dart';
import 'package:tubesavely/storage/storage.dart';
import 'package:tubesavely/utils/platform_util.dart';
import 'package:tubesavely/utils/toast_util.dart';

class Downloader {
  static Future<String> get baseOutputPath async =>
      Storage().getString(StorageKeys.CACHE_DIR_KEY) ?? (await getTemporaryDirectory()).path;

  static start(String videoUrl, String fileName,
      {String? audioUrl,
      String? resolution,
      ProgressCallback? onProgress,
      SuccessCallback? onSuccess,
      FailureCallback? onFailure}) async {
    debugPrint('video url $videoUrl');

    if (videoUrl.isEmpty) {
      ToastUtil.error(S.current.toastDownloadInvalid);
      onFailure?.call(Exception('Download url is empty'));
      return;
    }

    if (videoUrl.contains('.m3u8')) {
      _downloadM3U8(videoUrl, fileName, onProgress, onSuccess, onFailure);
      return;
    }

    final videoFileName = resolution != null && resolution != '' ? "$fileName-$resolution.mp4" : '$fileName.mp4';
    final recode = Storage().getBool(StorageKeys.AUTO_RECODE_KEY);
    String? videoPath = await downloadVideo(videoUrl, videoFileName,
        onProgress: onProgress, onSuccess: onSuccess, onFailure: onFailure, manualSave: audioUrl != null || recode);

    if (Storage().getBool(StorageKeys.AUTO_MERGE_AUDIO_KEY) && audioUrl != null) {
      final audioFileName = "$fileName.m4a";
      String? audioPath = await downloadAudio(audioUrl, audioFileName,
          onProgress: onProgress, onSuccess: onSuccess, onFailure: onFailure, manualSave: true);
      if (audioPath != null) {
        String outputPath = "${(await baseOutputPath)}/$fileName.mp4";
        File file = File(outputPath);
        if (file.existsSync()) {
          debugPrint('merge delete exists file : ${file.path}');
          await file.delete(recursive: true);
          debugPrint('merge exists file : ${await file.exists()}');
        }

        String? savePath = await FFmpegExecutor.merge(videoPath, audioPath, outputPath: outputPath);

        //合并成功保存合并后视频
        if (savePath?.isNotEmpty == true) {
          _save(outputPath, fileName: videoFileName, onSuccess: onSuccess, onFailure: onFailure);
        } else {
          //合并失败，只保存视频
          _save(videoPath, fileName: videoFileName, onSuccess: onSuccess, onFailure: onFailure);
        }
      }
      //音频文件下载失败，只保存视频
      else {
        _save(videoPath, fileName: videoFileName, onSuccess: onSuccess, onFailure: onFailure);
      }
    }

    //启动下载重编码
    if (recode) {
      final videoFileName = resolution != null && resolution != '' ? "$fileName-$resolution-recode.mp4" : '$fileName-recode.mp4';
      final recodeOutputPath = "${(await baseOutputPath)}/$videoFileName";
      //部分视频在ios设备无法播放，因此保存前先用ffmpeg对视频重编码为MPEG-4以便支持ios设备
      final savePath = await FFmpegExecutor.recode(videoPath ?? '',
          outputPath: recodeOutputPath, onProgress: onProgress, onFailure: onFailure);

      //重编码成功后删除原视频
      if (savePath != null) {
        File file = File(videoPath ?? '');
        if (file.existsSync()) {
          file.deleteSync();
        }
        _save(savePath, fileName: videoFileName, onSuccess: onSuccess, onFailure: onFailure);
      }
    }
  }

  static Future<String?> downloadVideo(
    String url,
    String fileName, {
    ProgressCallback? onProgress,
    SuccessCallback? onSuccess,
    FailureCallback? onFailure,
    bool manualSave = false,
  }) async {
    String path = await _download(url, fileName, onProgress: onProgress, onSuccess: onSuccess, onFailure: onFailure);
    if (path.isNotEmpty) {
      if (!manualSave) {
        _save(path, fileName: fileName, onSuccess: onSuccess, onFailure: onFailure);
      }
      return path;
    } else {
      ToastUtil.error(S.current.toastDownloadFailed);
      return null;
    }
  }

  static downloadAudio(String url, String fileName,
      {ProgressCallback? onProgress, SuccessCallback? onSuccess, FailureCallback? onFailure, bool manualSave = false}) async {
    String path = await _download(url, fileName, onProgress: onProgress, onSuccess: onSuccess, onFailure: onFailure);
    File file = File(path);
    if (file.existsSync()) {
      if (!manualSave) {
        final result = await OpenFile.open(path);
        if (result.type == ResultType.done) {
          onSuccess?.call(path);
          ToastUtil.success(S.current.toastDownloadSuccess);
        } else {
          onFailure?.call(Exception('Download file not exists'));
          ToastUtil.error(S.current.toastDownloadFailed);
        }
      }
    } else {
      onFailure?.call(Exception('Download file not exists'));
      ToastUtil.error(S.current.toastDownloadFailed);
    }
  }

  static _downloadM3U8(String m3u8Url, String fileName, ProgressCallback? onProgress, SuccessCallback? onSuccess,
      FailureCallback? onFailure) async {
    String outputPath = "${(await baseOutputPath)}/$fileName.mp4";

    String savePath = await _ffmpegDownloader(m3u8Url, fileName,
        outputPath: outputPath, onProgress: onProgress, onSuccess: onSuccess, onFailure: onFailure);
    if (savePath.isNotEmpty) {
      _save(savePath, fileName: fileName, onSuccess: onSuccess, onFailure: onFailure);
    } else {
      ToastUtil.error(S.current.toastDownloadFailed);
    }
  }

  static Future<String> _download(String? url, String? fileName,
      {String? outputPath, ProgressCallback? onProgress, SuccessCallback? onSuccess, FailureCallback? onFailure}) async {
    String savePath = '';
    savePath = await _ffmpegDownloader(url, fileName,
        outputPath: outputPath, onProgress: onProgress, onSuccess: onSuccess, onFailure: onFailure);

    // savePath = await _fileDownloader(url, fileName,
    //     outputPath: outputPath, onProgress: onProgress, onSuccess: onSuccess, onFailure: onFailure);
    return Future.value(savePath);
  }

  static Future<String> _fileDownloader(String? url, String? fileName,
      {String? outputPath, ProgressCallback? onProgress, SuccessCallback? onSuccess, FailureCallback? onFailure}) async {
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

    final completer = Completer<String>();

    final result = await FileDownloader().download(task,
        onProgress: (progress) => {
              debugPrint('Download Task Progress: ${progress * 100}% ${task.filename}'),
              onProgress?.call(ProgressType.download, progress * 100)
            },
        onStatus: (status) async => {
              debugPrint('Download Task Status: $status'),
              if (status == TaskStatus.complete)
                {onSuccess?.call(await task.filePath()), completer.complete(await task.filePath())}
              else if (status == TaskStatus.failed)
                {
                  onFailure?.call(Exception('Download failure')),
                  ToastUtil.error(S.current.toastDownloadFailed),
                }
            });

    debugPrint('_download result $result');
    return completer.future;
  }

  static Future<String> _ffmpegDownloader(String? url, String? fileName,
      {String? outputPath, ProgressCallback? onProgress, SuccessCallback? onSuccess, FailureCallback? onFailure}) async {
    outputPath ??= "${(await baseOutputPath)}/$fileName";
    File file = File(outputPath);
    if (file.existsSync()) {
      debugPrint('ffmpeg download delete exists file : ${file.path}');
      file.deleteSync();
      debugPrint('ffmpeg download exists file : ${await file.exists()}');
    }
    String? savePath =
        await FFmpegExecutor.download(url ?? '', outputPath: outputPath, onProgress: onProgress, onFailure: onFailure);

    final completer = Completer<String>();
    if (savePath?.isNotEmpty == true) {
      completer.complete(savePath);
    } else {
      onFailure?.call(Exception('Download url is empty'));
    }
    return completer.future;
  }

  static _save(String? path, {String? fileName = 'videoplayback', SuccessCallback? onSuccess, FailureCallback? onFailure}) async {
    if (path == null) {
      onFailure?.call(Exception('file path is empty'));
      return;
    }
    String outputPath = "${(await baseOutputPath)}/$fileName";

    if (PlatformUtil.isMobile) {
      dynamic result = await ImageGallerySaver.saveFile(outputPath, name: fileName, isReturnPathOfIOS: true);
      debugPrint('save result $result');
      if (result['isSuccess']) {
        onSuccess?.call(outputPath);
        ToastUtil.success(S.current.toastDownloadSuccess);
      } else {
// onFailure?.call();
        final result = await OpenFile.open(outputPath);
        if (result.type == ResultType.done) {
          onSuccess?.call(outputPath);
          ToastUtil.success(S.current.toastDownloadSuccess);
        } else {
          onFailure?.call(Exception('save file failure'));
          ToastUtil.error(S.current.toastDownloadFailed);
        }
      }
    } else {
      onSuccess?.call(outputPath);
      ToastUtil.success(S.current.toastDownloadSuccess);
    }
  }

//*********************************************Example*****************************************************//
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
            ToastUtil.success(S.current.toastDownloadSuccess);
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
