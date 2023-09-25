import 'dart:io';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:path_provider/path_provider.dart';

import 'PlatformUtils.dart';

typedef ProgressCallback = void Function(double progress);

class DownloadUtils {
  static Future<bool> downloadVideo(String url, String mediaType,
      int totalBytes, ProgressCallback? callback) async {
    var fileName = "${DateTime.now().millisecondsSinceEpoch}.$mediaType";
    try {
      final response = await HttpClient().getUrl(Uri.parse(url));
      final httpClientResponse = await response.close();

      final Directory tempDir = await getTemporaryDirectory();
      String appDocPath = tempDir.path;
      print('Success to load appDocPath>>>>>>>>>>>>: ${appDocPath}');
      File file = File('$appDocPath/$fileName');
      var fileStream = file.openWrite();
      var receivedBytes = 0;
      await for (var data in httpClientResponse) {
        fileStream.add(data);
        receivedBytes += data.length;
        var lengthSync = file.lengthSync();
        double progress = receivedBytes / totalBytes;
        print(
            'Download Progress: ${(progress * 100).toStringAsFixed(2)}%>>>>>>>>>>${receivedBytes}>>>>>${totalBytes}');
        if (callback != null) {
          callback(progress);
        }
      }
      await fileStream.flush();
      await fileStream.close();
      print('File downloaded successfully');
      if (PlatformUtils.isAndroidOrIOS) {
        final result = await ImageGallerySaver.saveFile(file.path);
        print('Success to ImageGallerySaver>>>>>>>>>>>>: ${result}');
      }
      return true;
    } catch (e) {
      return false;
    }
  }
}
