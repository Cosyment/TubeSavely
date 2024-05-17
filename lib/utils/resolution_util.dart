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

    String? resolution = '';
    if (width == 256 || height == 256) {
      //256x144
      resolution = '144P';
    } else if (width == 426 || height == 426) {
      //426x240
      return '240P';
    } else if (width == 640 || height == 640) {
      //640x360
      resolution = '360P';
    } else if (width == 845 || (height == 450 || height == 480)) {
      //845x450
      resolution = '480P';
    } else if (width == 960 || height == 540) {
      //960x540
      resolution = '540P';
    } else if (width == 1280 || height == 1280) {
      //1280x720
      resolution = '720P';
    } else if (width == 1920 || height == 1920) {
      //1920x1080
      resolution = '1080P';
    } else if (width == 2560 || height == 2560) {
      //2560x1440
      return '2K';
    } else if (width == 3840 || height == 3840) {
      //3840x2160
      resolution = '4K';
    } else if (width == 7680 || height == 7680) {
      //7680x4320
      resolution = '8K';
    }

    return resolution;
  }
}

void main() {
  print(VideoResolutionUtil.format('1920x1080')); // Should return "1080p"
  print(VideoResolutionUtil.format('2160x3840')); // Should return "4K"
  print(VideoResolutionUtil.format('360x640')); // Swapped width and height, should still return "720p"
}
