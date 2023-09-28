import 'dart:io';

import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:path_provider/path_provider.dart';

import 'platform_utils.dart';

typedef ProgressCallback = void Function(double progress);

class DownloadUtils {
  static Future<bool> downloadVideo(
      String url, ProgressCallback? callback) async {
    try {
      final response = await HttpClient().getUrl(Uri.parse(url));
      final httpClientResponse = await response.close();

      final Directory tempDir = await getTemporaryDirectory();
      String appDocPath = tempDir.path;
      int totalBytes = httpClientResponse.contentLength;
      String contentType = httpClientResponse.headers.contentType!.mimeType;
      // int lastDotIndex = url.lastIndexOf(".");
      // String mediaType = url.substring(lastDotIndex);
      String mediaType =
          contentType.substring(contentType.lastIndexOf("/") + 1);
      var fileName = "${DateTime.now().millisecondsSinceEpoch}.$mediaType";
      print(
          'Success to load appDocPath>>>>>>>>>>>>: ${appDocPath}  contentLength=${httpClientResponse.contentLength}   contentType==${contentType}');
      File file = File('$appDocPath/$fileName');
      var fileStream = file.openWrite();
      var receivedBytes = 0;
      await for (var data in httpClientResponse) {
        fileStream.add(data);
        receivedBytes += data.length;
        String progress = (receivedBytes / totalBytes).toStringAsFixed(2);
        print(
            'Download Progress: ${(progress)}>>>>>>>>>>${receivedBytes}>>>>>${totalBytes}');
        if (callback != null) {
          callback(double.parse(progress));
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
