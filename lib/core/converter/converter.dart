import 'dart:io';

import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:tubesavely/utils/toast_util.dart';

import '../../model/emuns.dart';
import '../../storage/storage.dart';
import '../ffmpeg/ffmpeg_executor.dart';

class Converter {
  static Future<String> get baseOutputPath async =>
      '${Storage().getString(StorageKeys.CACHE_DIR_KEY) ?? (await getTemporaryDirectory()).path}/Convert';

  static Future<String?> convertToFormat(String videoPath, VideoFormat format, {ProgressCallback? progressCallback}) async {
    Directory baseDirectory = Directory(await baseOutputPath);
    if (!baseDirectory.existsSync()) {
      baseDirectory.createSync(recursive: true);
    }
    String? extension = path.extension(videoPath);
    String newVideoPath = extension.isEmpty ? videoPath : videoPath.substring(0, videoPath.length - extension.length);

    String outputPath = '${(baseDirectory.path)}/${path.basename(newVideoPath)}.${format.name}';
    String? savePath = await FFmpegExecutor.convert(videoPath, outputPath: outputPath, progressCallback: progressCallback);
    if (savePath != null) {
      ToastUtil.success("视频转换成功");
      return savePath;
    }
    return null;
  }
}
