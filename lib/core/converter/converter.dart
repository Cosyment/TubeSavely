import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:tubesavely/utils/toast_util.dart';

import '../../model/emuns.dart';
import '../../storage/storage.dart';
import '../ffmpeg/ffmpeg_executor.dart';

class Converter {
  static Future<String> get _baseOutputPath async =>
      Storage().getString(StorageKeys.CACHE_DIR_KEY) ?? (await getTemporaryDirectory()).path;

  static Future<String?> convertToFormat(String videoPath, VideoFormat format) async {
    String outputPath = '${(await _baseOutputPath)}/${path.basename(videoPath)}.${format.name}';
    String? savePath = await FFmpegExecutor.convert(videoPath, outputPath: outputPath);
    if (savePath != null) {
      ToastUtil.success("视频转换成功");
      return savePath;
    }
    return null;
  }
}
