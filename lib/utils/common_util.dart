import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:url_launcher/url_launcher_string.dart';

class CommonUtil {
  static String formatSize(num bytes, {int fractionDigits = 2}) {
    if (bytes <= 0.0) return '';
    String suffix;
    num result = bytes;
    if (bytes < 1024) {
      suffix = 'B';
    } else if (bytes < 1048576) {
      suffix = 'KB';
      result /= 1024;
    } else if (bytes < 1073741824) {
      suffix = 'MB';
      result /= 1048576;
    } else if (bytes < 1099511627776) {
      suffix = 'GB';
      result /= 1073741824;
    } else {
      suffix = 'TB';
      result /= 1099511627776;
    }
    return '${result.toStringAsFixed(fractionDigits)} $suffix';
  }

  static void openDesktopDirectory(String path) async {
    if (Platform.isMacOS) {
      _open('open', ['-R', path.padRight(path.length + 1, '/')]);
    } else if (Platform.isWindows) {
      _open('explorer', [path]);
    } else if (Platform.isLinux) {
      _open('xdg-open', [path]);
    } else {
      print('Platform not supported');
      launchUrlString(Uri.file((path), windows: Platform.isWindows).toString());
    }
  }

  static void _open(String cmd, List<String> args) {
    Process.run(cmd, args).then((ProcessResult result) {
      if (result.exitCode == 0) {
        debugPrint('Directory opened successfully');
      } else {
        debugPrint(result.stderr);
        launchUrlString(Uri.file((args.last), windows: Platform.isWindows).toString());
      }
    });
  }
}
