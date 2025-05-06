import 'package:flutter/rendering.dart';

class VideoResolutionUtil {
  static String format(String dimensionsStr) {
    List<String> dimensionsParts = dimensionsStr.split('x');
    if (dimensionsParts.length != 2) {
      return '';
    }
    int width = int.parse(dimensionsParts[0]);
    int height = int.parse(dimensionsParts[1]);

    // Ensure width >= height for consistent comparison
    if (width < height) {
      int temp = width;
      width = height;
      height = temp;
    }
    debugPrint('video width:$width,height:$height');

    String? resolution = '';
    if (width == 256 || height == 256 || (width == 192 || height == 192)) {
      //256x144
      resolution = '144P';
    } else if (width == 426 || height == 426 || (width == 240 || height == 240)) {
      //426x240
      resolution = '240P';
    } else if (width == 640 || height == 640 || (width == 360 || height == 360)) {
      //640x360
      resolution = '360P';
    } else if (width == 845 || (height == 450 || height == 480)) {
      //845x450
      resolution = '480P';
    } else if ((width == 960 || height == 540) || (width == 1024 || height == 576)) {
      //960x540
      resolution = '540P';
    } else if (width == 1280 || height == 1280) {
      //1280x720
      resolution = '720P';
    } else if (width == 1920 || height == 1920 || (width == 1080 || height == 1080)) {
      //1920x1080
      resolution = '1080P';
    } else if (width == 2560 || height == 2560) {
      //2560x1440
      resolution = '2K';
    } else if (width == 3840 || height == 3840) {
      //3840x2160
      resolution = '4K';
    } else if (width == 7680 || height == 7680) {
      //7680x4320
      resolution = '8K';
    } else {
      resolution = dimensionsStr;
    }

    return resolution;
  }
}

void main() {
  debugPrint(VideoResolutionUtil.format('1920x1080')); // Should return "1080p"
  debugPrint(VideoResolutionUtil.format('2160x3840')); // Should return "4K"
  debugPrint(VideoResolutionUtil.format('360x640')); // Swapped width and height, should still return "720p"
}
