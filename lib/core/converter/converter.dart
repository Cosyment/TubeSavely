import 'dart:io';

import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:tubesavely/core/callback/callback.dart';
import 'package:tubesavely/generated/l10n.dart';
import 'package:tubesavely/utils/toast_util.dart';

import '../../model/emuns.dart';
import '../../storage/storage.dart';
import '../ffmpeg/ffmpeg_executor.dart';

class Converter {
  static Future<String> get baseOutputPath async =>
      '${Storage().getString(StorageKeys.CACHE_DIR_KEY) ?? (await getTemporaryDirectory()).path}/Convert';

  static convertToFormat(String videoPath, VideoFormat format,
      {ProgressCallback? onProgress, SuccessCallback? onSuccess, FailureCallback? onFailure}) async {
    Directory baseDirectory = Directory(await baseOutputPath);
    if (!baseDirectory.existsSync()) {
      baseDirectory.createSync(recursive: true);
    }
    String? extension = path.extension(videoPath);
    String newVideoPath = extension.isEmpty ? videoPath : videoPath.substring(0, videoPath.length - extension.length);

    String outputPath = '${(baseDirectory.path)}/${path.basename(newVideoPath)}.${format.name.replaceAll('_', '')}';
    String? savePath =
        await FFmpegExecutor.convert(videoPath, outputPath: outputPath, onProgress: onProgress, onFailure: onFailure);
    if (savePath != null) {
      ToastUtil.success(S.current.toastConvertSuccess);
      onSuccess?.call(savePath);
      return savePath;
    }
  }
}
