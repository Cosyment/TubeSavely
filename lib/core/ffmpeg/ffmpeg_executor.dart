import 'dart:async';
import 'dart:io';

import 'package:ffmpeg_kit_flutter_full_gpl/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter_full_gpl/ffmpeg_kit_config.dart';
import 'package:ffmpeg_kit_flutter_full_gpl/ffprobe_kit.dart';
import 'package:ffmpeg_kit_flutter_full_gpl/media_information.dart';
import 'package:ffmpeg_kit_flutter_full_gpl/media_information_session.dart';
import 'package:ffmpeg_kit_flutter_full_gpl/return_code.dart';
import 'package:flutter/widgets.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:tubesavely/core/callback/callback.dart';
import 'package:tubesavely/model/emuns.dart';
import 'package:tubesavely/storage/storage.dart';

class FFmpegExecutor {
  static const String defaultOutputPath = 'output'; // 获取应用文档目录
  // static const String directory = getDownloadsDirectory().then((value) => value.path); // 获取应用文档目录

  const FFmpegExecutor._();

  static Future<String?> merge(String? videoPath, String? audioPath,
      {String? outputPath, ProgressCallback? progressCallback, FailureCallback? onFailure}) async {
    if (videoPath == null || audioPath == null) {
      debugPrint('merge media failure: videoPath or audioPath is null');
      return null;
    }
    final command =
        '-hide_banner -i "$videoPath" -i "$audioPath" -c:v copy -c:a aac -pix_fmt yuv420p -y "${outputPath ?? defaultOutputPath}"';
    if (await _execute(command, progressType: ProgressType.merge, onProgress: progressCallback, onFailure: onFailure)) {
      return outputPath;
    }
    return null;
  }

  static Future<String?> convert(String videoPath,
      {String? outputPath, ProgressCallback? onProgress, FailureCallback? onFailure}) async {
    outputPath ??= '${Storage().getString(StorageKeys.CACHE_DIR_KEY)}/${path.basename(videoPath)}.mp4';
    File outputFile = File(outputPath);
    if (outputFile.existsSync()) {
      onProgress?.call(ProgressType.convert, 100);
      return outputPath;
    }

    // final command =
    //     '-hide_banner -i "$videoPath" -c:v libx264 -preset slow -progress "$progressLogPath" -crf 23 -c:a copy -y "$outputPath"';
    final command = '-hide_banner -i "$videoPath" -c:v libx264 -preset veryfast -crf 23 -c:a copy -y "$outputPath"';
    if (await _execute(command, progressType: ProgressType.convert, onProgress: onProgress, onFailure: onFailure)) {
      return outputPath;
    }
    return null;
  }

  static Future<String?> extractThumbnail(String videoPath, {String? outputPath, ProgressCallback? onProgress}) async {
    outputPath ??= '${await getApplicationDocumentsDirectory().then((value) => value.path)}/${path.basename(videoPath)}.jpg';
    File thumbnailFile = File(outputPath);
    if (thumbnailFile.existsSync()) {
      return outputPath;
    }
    // final command = '-i "$videoPath" -y -f mjpeg -ss 00:00:03 -vframes 1 -s 320x240 "$outputPath"';
    final command =
        '-hide_banner -i "$videoPath" -ss 00:00:03 -vf scale=w=1280:h=-2:force_original_aspect_ratio=decrease -vframes 1 -y "$outputPath"';
    if (await _execute(command, onProgress: onProgress)) {
      return outputPath;
    }
    return null;
  }

  static Future<String?> extractAudio(String videoPath,
      {String? outputPath, ProgressCallback? onProgress, FailureCallback? onFailure}) async {
    final command = '-hide_banner -i "$videoPath" -y -vn -acodec copy "${path.basename(videoPath)}.mp3"';
    if (await _execute(command, onProgress: onProgress, onFailure: onFailure)) {
      return outputPath;
    }
    return null;
  }

  static Future<Map<String, dynamic>?> extractMediaInformation(String videoPath) async {
    MediaInformationSession session = await FFprobeKit.getMediaInformation(videoPath);
    MediaInformation? mediaInformation = session.getMediaInformation();
    return {'size': num.parse(mediaInformation?.getSize() ?? '0'), 'duration': num.parse(mediaInformation?.getDuration() ?? '0')};
  }

  static Future<String?> recode(String videoPath,
      {String? outputPath, ProgressCallback? onProgress, FailureCallback? onFailure}) async {
    final command = '-hide_banner -i "$videoPath" -err_detect ignore_err -c:v mpeg4 -y "$outputPath"';
    if (await _execute(command, progressType: ProgressType.recode, onProgress: onProgress, onFailure: onFailure)) {
      return outputPath;
    }
    return null;
  }

  static Future<String?> download(String videoUrl,
      {String? outputPath, ProgressCallback? onProgress, FailureCallback? onFailure}) async {
    final command = '-hide_banner -i "$videoUrl" -c copy -bsf:a aac_adtstoasc -y "$outputPath"';
    if (await _execute(command, progressType: ProgressType.download, onProgress: onProgress, onFailure: onFailure)) {
      return outputPath;
    }
    return null;
  }

  static Future<bool> _execute(String command,
      {ProgressType? progressType, ProgressCallback? onProgress, FailureCallback? onFailure}) async {
    num fileSize = 0;
    num totalDuration = 0;
    List<String> commandList = FFmpegKitConfig.parseArguments(command);
    Map<String, dynamic>? mediaInformation = await extractMediaInformation(commandList[2]);
    fileSize = mediaInformation?['size'] ?? 0;
    totalDuration = mediaInformation?['duration'] ?? 0;

    // 使用Completer来创建一个可控制完成的Future
    final completer = Completer<bool>(); // 使用Completer来创建一个可控制完成的Future

    FFmpegKit.executeAsync(command, (session) async {
      ReturnCode? code = await session.getReturnCode();
      if (ReturnCode.isSuccess(code)) {
        debugPrint('ffmpeg execute result : Success $command');
        onProgress?.call(progressType ?? ProgressType.idle, 100);
        completer.complete(true); // 成功时，完成Future并返回true
      } else {
        onFailure?.call(Exception('ffmpeg execute result : Failure $code, $command'));
        debugPrint('ffmpeg execute result : Failure $code, $command');
        completer.complete(false); // 成功时，完成Future并返回true
      }
    }, (log) {
      debugPrint('execute log ${log.getMessage()}');
    }, (statistics) {
      num currentDuration = num.parse((statistics.getTime() / 1000).toStringAsFixed(2));
      num currentSize = statistics.getSize();
      // debugPrint(
      //     'currentDuration $currentDuration, totalDuration $totalDuration, currentSize $currentSize, fileSize $fileSize');

      if (currentDuration > 0 && totalDuration > 0) {
        double progress = (currentDuration / totalDuration) * 100;
        onProgress?.call(progressType ?? ProgressType.idle, progress);
        debugPrint('execute progress : $progress');
      }
    });
    return completer.future;
  }
}
