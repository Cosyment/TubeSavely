class Constants {
  Constants._();

  // API
  static const String API_BASE_URL = 'https://api.tubesavely.cosyment.com';
  static const int API_TIMEOUT = 30000; // 30秒
  static const int API_RETRY_COUNT = 3;

  // 存储键
  static const String STORAGE_THEME_KEY = 'theme_mode';
  static const String STORAGE_LOCALE_KEY = 'locale';
  static const String STORAGE_USER_TOKEN = 'user_token';
  static const String STORAGE_USER_INFO = 'user_info';
  static const String STORAGE_DOWNLOAD_HISTORY = 'download_history';
  static const String STORAGE_DOWNLOAD_TASKS = 'download_tasks';
  static const String STORAGE_SETTINGS = 'settings';

  // 默认设置
  static const int DEFAULT_VIDEO_QUALITY = 1080; // 默认视频质量
  static const String DEFAULT_VIDEO_FORMAT = 'mp4'; // 默认视频格式
  static const String DEFAULT_DOWNLOAD_PATH = ''; // 默认下载路径，空表示使用系统默认路径
  static const bool DEFAULT_AUTO_DOWNLOAD = false; // 默认是否自动下载
  static const bool DEFAULT_WIFI_ONLY = true; // 默认是否仅在WiFi下下载
  static const bool DEFAULT_NOTIFICATION = true; // 默认是否显示通知

  // 会员等级
  static const int USER_LEVEL_FREE = 0; // 免费用户
  static const int USER_LEVEL_PREMIUM = 1; // 高级会员
  static const int USER_LEVEL_PRO = 2; // 专业会员

  // 支持的平台
  static const List<Map<String, dynamic>> SUPPORTED_PLATFORMS = [
    {'name': 'YouTube', 'icon': 'assets/images/youtube.png', 'regex': r'(youtube\.com|youtu\.be)'},
    {'name': 'Bilibili', 'icon': 'assets/images/bilibili.png', 'regex': r'bilibili\.com'},
    {'name': 'TikTok', 'icon': 'assets/images/tiktok.png', 'regex': r'(tiktok\.com|douyin\.com)'},
    {'name': 'Instagram', 'icon': 'assets/images/instagram.png', 'regex': r'instagram\.com'},
  ];
}
