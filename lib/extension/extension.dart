extension StringExtension on String {
  bool isValidUrl() {
    Match? match = RegExp(r'http[s]?:\/\/[\w.]+[\w/]*[\w.]*\??[\w=&:\-+%]*[/]*').firstMatch(this);
    var url = match?.group(0) ?? '';
    if (!url.contains('http')) {
      return false;
    }
    return true;
  }
}
