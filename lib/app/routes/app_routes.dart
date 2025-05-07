part of 'app_pages.dart';

abstract class Routes {
  Routes._();
  static const HOME = _Paths.HOME;
  static const SPLASH = _Paths.SPLASH;
  static const VIDEO_DETAIL = _Paths.VIDEO_DETAIL;
  static const SETTINGS = _Paths.SETTINGS;
  static const HISTORY = _Paths.HISTORY;
  static const TASKS = _Paths.TASKS;
  static const PAYMENT = _Paths.PAYMENT;
  static const MORE = _Paths.MORE;
  static const VIDEO_PLAYER = _Paths.VIDEO_PLAYER;
  static const LOGIN = _Paths.LOGIN;
  static const PROFILE = _Paths.PROFILE;
}

abstract class _Paths {
  _Paths._();
  static const HOME = '/home';
  static const SPLASH = '/splash';
  static const VIDEO_DETAIL = '/video-detail';
  static const SETTINGS = '/settings';
  static const HISTORY = '/history';
  static const TASKS = '/tasks';
  static const PAYMENT = '/payment';
  static const MORE = '/more';
  static const VIDEO_PLAYER = '/video-player';
  static const LOGIN = '/login';
  static const PROFILE = '/profile';
}
