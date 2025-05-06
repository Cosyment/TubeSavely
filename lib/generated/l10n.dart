// GENERATED CODE - DO NOT MODIFY BY HAND
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'intl/messages_all.dart';

// **************************************************************************
// Generator: Flutter Intl IDE plugin
// Made by Localizely
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, lines_longer_than_80_chars
// ignore_for_file: join_return_with_assignment, prefer_final_in_for_each
// ignore_for_file: avoid_redundant_argument_values, avoid_escaping_inner_quotes

class S {
  S();

  static S? _current;

  static S get current {
    assert(_current != null,
        'No instance of S was loaded. Try to initialize the S delegate before accessing S.current.');
    return _current!;
  }

  static const AppLocalizationDelegate delegate = AppLocalizationDelegate();

  static Future<S> load(Locale locale) {
    final name = (locale.countryCode?.isEmpty ?? false)
        ? locale.languageCode
        : locale.toString();
    final localeName = Intl.canonicalizedLocale(name);
    return initializeMessages(localeName).then((_) {
      Intl.defaultLocale = localeName;
      final instance = S();
      S._current = instance;

      return instance;
    });
  }

  static S of(BuildContext context) {
    final instance = S.maybeOf(context);
    assert(instance != null,
        'No instance of S present in the widget tree. Did you add S.delegate in localizationsDelegates?');
    return instance!;
  }

  static S? maybeOf(BuildContext context) {
    return Localizations.of<S>(context, S);
  }

  /// `TubeSavely`
  String get appName {
    return Intl.message(
      'TubeSavely',
      name: 'appName',
      desc: '',
      args: [],
    );
  }

  /// `Download`
  String get download {
    return Intl.message(
      'Download',
      name: 'download',
      desc: '',
      args: [],
    );
  }

  /// `Convert`
  String get convert {
    return Intl.message(
      'Convert',
      name: 'convert',
      desc: '',
      args: [],
    );
  }

  /// `Paste Link`
  String get parseLink {
    return Intl.message(
      'Paste Link',
      name: 'parseLink',
      desc: '',
      args: [],
    );
  }

  /// `Download Now`
  String get downloadNow {
    return Intl.message(
      'Download Now',
      name: 'downloadNow',
      desc: '',
      args: [],
    );
  }

  /// `Please paste the video link, e.g. https://www.example.com/watch?v=dQw4w9WgXcQ`
  String get downloadTips {
    return Intl.message(
      'Please paste the video link, e.g. https://www.example.com/watch?v=dQw4w9WgXcQ',
      name: 'downloadTips',
      desc: '',
      args: [],
    );
  }

  /// `Convert to:`
  String get convertTo {
    return Intl.message(
      'Convert to:',
      name: 'convertTo',
      desc: '',
      args: [],
    );
  }

  /// `Add Video`
  String get addVideo {
    return Intl.message(
      'Add Video',
      name: 'addVideo',
      desc: '',
      args: [],
    );
  }

  /// `Pick Video`
  String get pickVideo {
    return Intl.message(
      'Pick Video',
      name: 'pickVideo',
      desc: '',
      args: [],
    );
  }

  /// `General Settings`
  String get generalSettings {
    return Intl.message(
      'General Settings',
      name: 'generalSettings',
      desc: '',
      args: [],
    );
  }

  /// `Theme`
  String get settingTheme {
    return Intl.message(
      'Theme',
      name: 'settingTheme',
      desc: '',
      args: [],
    );
  }

  /// `Dark`
  String get settingThemeDark {
    return Intl.message(
      'Dark',
      name: 'settingThemeDark',
      desc: '',
      args: [],
    );
  }

  /// `Light`
  String get settingThemeLight {
    return Intl.message(
      'Light',
      name: 'settingThemeLight',
      desc: '',
      args: [],
    );
  }

  /// `System`
  String get settingThemeSystem {
    return Intl.message(
      'System',
      name: 'settingThemeSystem',
      desc: '',
      args: [],
    );
  }

  /// `Language`
  String get settingLanguage {
    return Intl.message(
      'Language',
      name: 'settingLanguage',
      desc: '',
      args: [],
    );
  }

  /// `Video Settings`
  String get videoSettings {
    return Intl.message(
      'Video Settings',
      name: 'videoSettings',
      desc: '',
      args: [],
    );
  }

  /// `Cache Directory`
  String get settingCacheDir {
    return Intl.message(
      'Cache Directory',
      name: 'settingCacheDir',
      desc: '',
      args: [],
    );
  }

  /// `Auto Re-encode Videos`
  String get settingRecode {
    return Intl.message(
      'Auto Re-encode Videos',
      name: 'settingRecode',
      desc: '',
      args: [],
    );
  }

  /// `Download Failure Retry Count`
  String get settingRetryCount {
    return Intl.message(
      'Download Failure Retry Count',
      name: 'settingRetryCount',
      desc: '',
      args: [],
    );
  }

  /// `Default Download Quality`
  String get settingDownloadQuality {
    return Intl.message(
      'Default Download Quality',
      name: 'settingDownloadQuality',
      desc: '',
      args: [],
    );
  }

  /// `Automatically merge audio`
  String get settingMergeAudio {
    return Intl.message(
      'Automatically merge audio',
      name: 'settingMergeAudio',
      desc: '',
      args: [],
    );
  }

  /// `Default Conversion Format`
  String get settingConvertFormat {
    return Intl.message(
      'Default Conversion Format',
      name: 'settingConvertFormat',
      desc: '',
      args: [],
    );
  }

  /// `Other Settings`
  String get otherSettings {
    return Intl.message(
      'Other Settings',
      name: 'otherSettings',
      desc: '',
      args: [],
    );
  }

  /// `Visit Web Version`
  String get visitWebsite {
    return Intl.message(
      'Visit Web Version',
      name: 'visitWebsite',
      desc: '',
      args: [],
    );
  }

  /// `Privacy Policy`
  String get privacyPolicy {
    return Intl.message(
      'Privacy Policy',
      name: 'privacyPolicy',
      desc: '',
      args: [],
    );
  }

  /// `About Us`
  String get aboutUs {
    return Intl.message(
      'About Us',
      name: 'aboutUs',
      desc: '',
      args: [],
    );
  }

  /// `TubeSavely proudly supports over 1800 mainstream and niche video platforms at home and abroad, covering popular sites such as YouTube, Instagram, TikTok, Bilibili, Vimeo, and even some lesser-known professional platforms. No matter which corner of the wonderful content you prefer, TubeSavely can become your exclusive bridge, one-click download, easy collection. Using advanced multi-threaded download technology, TubeSavely greatly shortens the download time, and can quickly complete even for very large video files. Say goodbye to long waiting times and let the wonderful content be presented immediately, enjoying the immediate download and watch experience.`
  String get summary {
    return Intl.message(
      'TubeSavely proudly supports over 1800 mainstream and niche video platforms at home and abroad, covering popular sites such as YouTube, Instagram, TikTok, Bilibili, Vimeo, and even some lesser-known professional platforms. No matter which corner of the wonderful content you prefer, TubeSavely can become your exclusive bridge, one-click download, easy collection. Using advanced multi-threaded download technology, TubeSavely greatly shortens the download time, and can quickly complete even for very large video files. Say goodbye to long waiting times and let the wonderful content be presented immediately, enjoying the immediate download and watch experience.',
      name: 'summary',
      desc: '',
      args: [],
    );
  }

  /// `Copyright © 2023 TubeSavely. All rights reserved.`
  String get copyright {
    return Intl.message(
      'Copyright © 2023 TubeSavely. All rights reserved.',
      name: 'copyright',
      desc: '',
      args: [],
    );
  }

  /// `Video Quality`
  String get settingVideoQuality {
    return Intl.message(
      'Video Quality',
      name: 'settingVideoQuality',
      desc: '',
      args: [],
    );
  }

  /// `Video information parsing exception, please confirm if the link is correct`
  String get toastVideoExecuteError {
    return Intl.message(
      'Video information parsing exception, please confirm if the link is correct',
      name: 'toastVideoExecuteError',
      desc: '',
      args: [],
    );
  }

  /// `Please copy the video link first`
  String get toastLinkEmpty {
    return Intl.message(
      'Please copy the video link first',
      name: 'toastLinkEmpty',
      desc: '',
      args: [],
    );
  }

  /// `Please paste the correct link`
  String get toastLinkInvalid {
    return Intl.message(
      'Please paste the correct link',
      name: 'toastLinkInvalid',
      desc: '',
      args: [],
    );
  }

  /// `Link is already Added`
  String get toastLinkExists {
    return Intl.message(
      'Link is already Added',
      name: 'toastLinkExists',
      desc: '',
      args: [],
    );
  }

  /// `Download has started`
  String get toastDownloadStart {
    return Intl.message(
      'Download has started',
      name: 'toastDownloadStart',
      desc: '',
      args: [],
    );
  }

  /// `Downloading`
  String get toastDownloadProgress {
    return Intl.message(
      'Downloading',
      name: 'toastDownloadProgress',
      desc: '',
      args: [],
    );
  }

  /// `Download successful`
  String get toastDownloadSuccess {
    return Intl.message(
      'Download successful',
      name: 'toastDownloadSuccess',
      desc: '',
      args: [],
    );
  }

  /// `Download failed please try again later`
  String get toastDownloadFailed {
    return Intl.message(
      'Download failed please try again later',
      name: 'toastDownloadFailed',
      desc: '',
      args: [],
    );
  }

  /// `Download link invalid`
  String get toastDownloadInvalid {
    return Intl.message(
      'Download link invalid',
      name: 'toastDownloadInvalid',
      desc: '',
      args: [],
    );
  }

  /// `Recoding`
  String get toastRecodeProgress {
    return Intl.message(
      'Recoding',
      name: 'toastRecodeProgress',
      desc: '',
      args: [],
    );
  }

  /// `Merging`
  String get toastMergeProgress {
    return Intl.message(
      'Merging',
      name: 'toastMergeProgress',
      desc: '',
      args: [],
    );
  }

  /// `Convert successful`
  String get toastConvertSuccess {
    return Intl.message(
      'Convert successful',
      name: 'toastConvertSuccess',
      desc: '',
      args: [],
    );
  }

  /// `Convert failed`
  String get toastConvertFailed {
    return Intl.message(
      'Convert failed',
      name: 'toastConvertFailed',
      desc: '',
      args: [],
    );
  }

  /// `Convert started`
  String get toastConvertStart {
    return Intl.message(
      'Convert started',
      name: 'toastConvertStart',
      desc: '',
      args: [],
    );
  }

  /// `Converting`
  String get toastConvertProgress {
    return Intl.message(
      'Converting',
      name: 'toastConvertProgress',
      desc: '',
      args: [],
    );
  }

  /// `Downloading`
  String get statusDownloadProgress {
    return Intl.message(
      'Downloading',
      name: 'statusDownloadProgress',
      desc: '',
      args: [],
    );
  }

  /// `Download failed`
  String get statusDownloadFailed {
    return Intl.message(
      'Download failed',
      name: 'statusDownloadFailed',
      desc: '',
      args: [],
    );
  }

  /// `Converting`
  String get statusConvertProgress {
    return Intl.message(
      'Converting',
      name: 'statusConvertProgress',
      desc: '',
      args: [],
    );
  }

  /// `Convert failed`
  String get statusConvertFailed {
    return Intl.message(
      'Convert failed',
      name: 'statusConvertFailed',
      desc: '',
      args: [],
    );
  }

  /// `Merging`
  String get statusMergeProgress {
    return Intl.message(
      'Merging',
      name: 'statusMergeProgress',
      desc: '',
      args: [],
    );
  }

  /// `Merge failed`
  String get statusMergeFailed {
    return Intl.message(
      'Merge failed',
      name: 'statusMergeFailed',
      desc: '',
      args: [],
    );
  }

  /// `Recoding`
  String get statusRecodeProgress {
    return Intl.message(
      'Recoding',
      name: 'statusRecodeProgress',
      desc: '',
      args: [],
    );
  }

  /// `Recode failed`
  String get statusRecodeFailed {
    return Intl.message(
      'Recode failed',
      name: 'statusRecodeFailed',
      desc: '',
      args: [],
    );
  }

  /// `Completed`
  String get statusComplete {
    return Intl.message(
      'Completed',
      name: 'statusComplete',
      desc: '',
      args: [],
    );
  }

  /// `Process failed`
  String get statusFailed {
    return Intl.message(
      'Process failed',
      name: 'statusFailed',
      desc: '',
      args: [],
    );
  }
}

class AppLocalizationDelegate extends LocalizationsDelegate<S> {
  const AppLocalizationDelegate();

  List<Locale> get supportedLocales {
    return const <Locale>[
      Locale.fromSubtags(languageCode: 'en'),
      Locale.fromSubtags(languageCode: 'ja'),
      Locale.fromSubtags(languageCode: 'ko'),
      Locale.fromSubtags(languageCode: 'zh'),
    ];
  }

  @override
  bool isSupported(Locale locale) => _isSupported(locale);
  @override
  Future<S> load(Locale locale) => S.load(locale);
  @override
  bool shouldReload(AppLocalizationDelegate old) => false;

  bool _isSupported(Locale locale) {
    for (var supportedLocale in supportedLocales) {
      if (supportedLocale.languageCode == locale.languageCode) {
        return true;
      }
    }
    return false;
  }
}
