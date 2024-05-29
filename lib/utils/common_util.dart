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
}
