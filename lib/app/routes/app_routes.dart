part of 'app_pages.dart';

abstract class Routes {
  Routes._();
  static const HOME = _Paths.HOME;
  static const SPLASH = _Paths.SPLASH;
  static const MAIN = _Paths.MAIN;
  static const VIDEO_DETAIL = _Paths.VIDEO_DETAIL;
  static const SETTINGS = _Paths.SETTINGS;
  static const HISTORY = _Paths.HISTORY;
  static const TASKS = _Paths.TASKS;
  static const PAYMENT = _Paths.PAYMENT;
  static const PAYMENT_RESULT = _Paths.PAYMENT_RESULT;
  static const TRANSACTION_HISTORY = _Paths.TRANSACTION_HISTORY;
  static const MORE = _Paths.MORE;
  static const VIDEO_PLAYER = _Paths.VIDEO_PLAYER;
  static const LOGIN = _Paths.LOGIN;
  static const PROFILE = _Paths.PROFILE;
  static const CONVERT = _Paths.CONVERT;
  static const DEVELOPER = _Paths.DEVELOPER;
}

abstract class _Paths {
  _Paths._();
  static const HOME = '/home';
  static const SPLASH = '/splash';
  static const MAIN = '/main';
  static const VIDEO_DETAIL = '/video-detail';
  static const SETTINGS = '/settings';
  static const HISTORY = '/history';
  static const TASKS = '/tasks';
  static const PAYMENT = '/payment';
  static const PAYMENT_RESULT = '/payment-result';
  static const TRANSACTION_HISTORY = '/transaction-history';
  static const MORE = '/more';
  static const VIDEO_PLAYER = '/video-player';
  static const LOGIN = '/login';
  static const PROFILE = '/profile';
  static const CONVERT = '/convert';
  static const DEVELOPER = '/developer';
}
