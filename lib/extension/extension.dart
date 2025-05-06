extension StringExtension on String {
  bool isValidUrl() {
    Match? match = RegExp(r'http[s]?:\/\/[\w.]+[\w/]*[\w.]*\??[\w=&:\-+%]*[/]*').firstMatch(this);
    var url = match?.group(0) ?? '';
    if (!url.contains('http')) {
      return false;
    }
    return true;
  }

  String toLanguageCode() {
    if (this == '简体中文') {
      return 'zh';
    } else if (this == 'English') {
      return 'en';
    } else if (this == '日本語') {
      return 'ja';
    } else if (this == '한국어') {
      return 'ko';
    }
    return 'en';
  }

  String capitalizeWords() {
    return isNotEmpty ? this[0].toUpperCase() + substring(1) : this;
  }
}
