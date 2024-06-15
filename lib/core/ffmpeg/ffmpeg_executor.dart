import 'package:ffmpeg_kit_flutter_full_gpl/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter_full_gpl/ffmpeg_session.dart';
import 'package:ffmpeg_kit_flutter_full_gpl/return_code.dart';
import 'package:flutter/widgets.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

enum VideoFormat { MOV, AVI, MKV, MP4, FLV, WMV, RMVB, _3GP, MPG, MPE, M4V }

class FFmpegExecutor {
  static const String defaultOutputPath = 'output'; // 获取应用文档目录
  // static const String directory = getDownloadsDirectory().then((value) => value.path); // 获取应用文档目录

  const FFmpegExecutor._();

  static Future<String?> merge(String videoPath, String audioPath, {String? outputPath}) async {
    final command = '-i "$videoPath" -i "$audioPath" -c:v copy -c:a aac -pix_fmt yuv420p -y "${outputPath ?? defaultOutputPath}"';
    if (await _execute(command)) {
      return outputPath;
    }
    return null;
  }

  static Future<String?> convertToFormat(String videoPath, VideoFormat format, {String? outputPath}) async {
    outputPath ??=
        '${await getApplicationDocumentsDirectory().then((value) => value.path)}/${path.basename(videoPath)}.${format.name}';
    final command = '-i "$videoPath" -c:v libx264 -preset slow -crf 23 -c:a copy "$outputPath"';
    if (await _execute(command)) {
      return outputPath;
    }
    return null;
  }

  static Future<String?> extractThumbnail(String videoPath, {String? outputPath}) async {
    outputPath ??= '${await getApplicationDocumentsDirectory().then((value) => value.path)}/${path.basename(videoPath)}.jpg';
    // final command = '-i "$videoPath" -y -f mjpeg -ss 00:00:03 -vframes 1 -s 320x240 "$outputPath"';
    final command =
        '-i "$videoPath" -ss 00:00:03 -vf scale=w=1280:h=-2:force_original_aspect_ratio=decrease -vframes 1 -y "$outputPath"';
    if (await _execute(command)) {
      return outputPath;
    }
    return null;
  }

  static Future<String?> extractAudio(String videoPath, {String? outputPath}) async {
    final command = '-i "$videoPath" -y -vn -acodec copy "${path.basename(videoPath)}.mp3"';
    if (await _execute(command)) {
      return outputPath;
    }
    return null;
  }

  static Future<String?> reEncode(String videoPath, {String? outputPath}) async {
    final command = '-i "$videoPath" -err_detect ignore_err -c:v mpeg4 -y "${outputPath ?? defaultOutputPath}"';
    if (await _execute(command)) {
      return outputPath;
    }
    return null;
  }

  static Future<String?> downloadM3U8(String m3u8Url, {String? outputPath}) async {
    final command = '-i "$m3u8Url" -c copy -bsf:a aac_adtstoasc -y "$outputPath"';
    if (await _execute(command)) {
      return outputPath;
    }
    return null;
  }

  static Future<bool> _execute(String command) async {
    FFmpegSession session = await FFmpegKit.execute(command);
    ReturnCode? code = await session.getReturnCode();
    // session.getState().then((onValue) {
    //   debugPrint('-------->>>>getState ${onValue}');
    // });
    // session.getDuration().then((onValue) {
    //   debugPrint('--------->>>getDuration  ${onValue}');
    // });
    //
    // session.getLogsAsString().then((onValue) {
    //   debugPrint('--------->>>getLogsAsString  ${onValue}');
    // });
    //
    // session.getStatistics().then((onValue) {
    //   debugPrint('--------->>>getStatistics  ${onValue.length}');
    // });
    //
    // session.getAllStatistics().then((onValue) {
    //   debugPrint('--------->>>getAllStatistics  ${onValue.length}');
    // });
    //
    // session.getEndTime().then((onValue) {
    //   debugPrint('--------->>>getEndTime  ${onValue}');
    // });
    if (ReturnCode.isSuccess(code)) {
      debugPrint('ffmpeg execute result : Success $command');
      return true;
    } else {
      debugPrint('ffmpeg execute result : Failure $code, $command ${await session.getFailStackTrace()}');
      return false;
    }
  }
}
