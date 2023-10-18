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

  /// `Lubian video download`
  String get appName {
    return Intl.message(
      'Lubian video download',
      name: 'appName',
      desc: '',
      args: [],
    );
  }

  /// `FAQ`
  String get askQuestions {
    return Intl.message(
      'FAQ',
      name: 'askQuestions',
      desc: '',
      args: [],
    );
  }

  /// `Home`
  String get home {
    return Intl.message(
      'Home',
      name: 'home',
      desc: '',
      args: [],
    );
  }

  /// `my`
  String get me {
    return Intl.message(
      'my',
      name: 'me',
      desc: '',
      args: [],
    );
  }

  /// `Login`
  String get loginTxt {
    return Intl.message(
      'Login',
      name: 'loginTxt',
      desc: '',
      args: [],
    );
  }

  /// `setting`
  String get setting {
    return Intl.message(
      'setting',
      name: 'setting',
      desc: '',
      args: [],
    );
  }

  /// `Feedback`
  String get feedbackTxt {
    return Intl.message(
      'Feedback',
      name: 'feedbackTxt',
      desc: '',
      args: [],
    );
  }

  /// `Parse Records`
  String get parseRecordsTxt {
    return Intl.message(
      'Parse Records',
      name: 'parseRecordsTxt',
      desc: '',
      args: [],
    );
  }

  /// `Get verification code`
  String get getCodeTxt {
    return Intl.message(
      'Get verification code',
      name: 'getCodeTxt',
      desc: '',
      args: [],
    );
  }

  /// `Remove video watermark`
  String get videoLinkWatermarkTxt {
    return Intl.message(
      'Remove video watermark',
      name: 'videoLinkWatermarkTxt',
      desc: '',
      args: [],
    );
  }

  /// `Remove watermark from video link`
  String get videoLinkWatermarkRemovalTxt {
    return Intl.message(
      'Remove watermark from video link',
      name: 'videoLinkWatermarkRemovalTxt',
      desc: '',
      args: [],
    );
  }

  /// `Remove watermark from picture`
  String get pictureWatermarkingTxt {
    return Intl.message(
      'Remove watermark from picture',
      name: 'pictureWatermarkingTxt',
      desc: '',
      args: [],
    );
  }

  /// `View Picture`
  String get lookPhotoTxt {
    return Intl.message(
      'View Picture',
      name: 'lookPhotoTxt',
      desc: '',
      args: [],
    );
  }

  /// `doodle`
  String get doodleTxt {
    return Intl.message(
      'doodle',
      name: 'doodleTxt',
      desc: '',
      args: [],
    );
  }

  /// `Douyin, Kuaishou, Bili, Weibo, Zhihu, YouTube`
  String get platformListTxt {
    return Intl.message(
      'Douyin, Kuaishou, Bili, Weibo, Zhihu, YouTube',
      name: 'platformListTxt',
      desc: '',
      args: [],
    );
  }

  /// `Hypnosis live broadcast, Music live broadcast, Movie live broadcast`
  String get liveListTxt {
    return Intl.message(
      'Hypnosis live broadcast, Music live broadcast, Movie live broadcast',
      name: 'liveListTxt',
      desc: '',
      args: [],
    );
  }

  /// `Video crop, Video clip, Video reverse, Video rotation, Video speed, Video compression, Video screenshot, Video to GIF, Video mirroring, Video to remove sound`
  String get tvListTxt {
    return Intl.message(
      'Video crop, Video clip, Video reverse, Video rotation, Video speed, Video compression, Video screenshot, Video to GIF, Video mirroring, Video to remove sound',
      name: 'tvListTxt',
      desc: '',
      args: [],
    );
  }

  /// `Video clipping tool`
  String get tvClipTxt {
    return Intl.message(
      'Video clipping tool',
      name: 'tvClipTxt',
      desc: '',
      args: [],
    );
  }

  /// `play`
  String get playTxt {
    return Intl.message(
      'play',
      name: 'playTxt',
      desc: '',
      args: [],
    );
  }

  /// `Next step`
  String get nextTxt {
    return Intl.message(
      'Next step',
      name: 'nextTxt',
      desc: '',
      args: [],
    );
  }

  /// `Save`
  String get saveTxt {
    return Intl.message(
      'Save',
      name: 'saveTxt',
      desc: '',
      args: [],
    );
  }

  /// `Save successfully`
  String get saveSuccessfullyTxt {
    return Intl.message(
      'Save successfully',
      name: 'saveSuccessfullyTxt',
      desc: '',
      args: [],
    );
  }

  /// `Save failed`
  String get saveFailedyTxt {
    return Intl.message(
      'Save failed',
      name: 'saveFailedyTxt',
      desc: '',
      args: [],
    );
  }

  /// `clear`
  String get clearTxt {
    return Intl.message(
      'clear',
      name: 'clearTxt',
      desc: '',
      args: [],
    );
  }

  /// `Video playback`
  String get tvPlayTxt {
    return Intl.message(
      'Video playback',
      name: 'tvPlayTxt',
      desc: '',
      args: [],
    );
  }

  /// `Start push streaming`
  String get startPushTxt {
    return Intl.message(
      'Start push streaming',
      name: 'startPushTxt',
      desc: '',
      args: [],
    );
  }

  /// `Select the push platform`
  String get selectPushTxt {
    return Intl.message(
      'Select the push platform',
      name: 'selectPushTxt',
      desc: '',
      args: [],
    );
  }

  /// `Server address`
  String get serverAddressTxt {
    return Intl.message(
      'Server address',
      name: 'serverAddressTxt',
      desc: '',
      args: [],
    );
  }

  /// `Streaming Key`
  String get streamingKeyTxt {
    return Intl.message(
      'Streaming Key',
      name: 'streamingKeyTxt',
      desc: '',
      args: [],
    );
  }

  /// `Live Room Address`
  String get liveRoomAddressTxt {
    return Intl.message(
      'Live Room Address',
      name: 'liveRoomAddressTxt',
      desc: '',
      args: [],
    );
  }

  /// `Live broadcast type`
  String get liveTypeTxt {
    return Intl.message(
      'Live broadcast type',
      name: 'liveTypeTxt',
      desc: '',
      args: [],
    );
  }

  /// `Live push streaming`
  String get livePushTxt {
    return Intl.message(
      'Live push streaming',
      name: 'livePushTxt',
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

  /// `UserAgreement`
  String get userAgreement {
    return Intl.message(
      'UserAgreement',
      name: 'userAgreement',
      desc: '',
      args: [],
    );
  }

  /// `Terms of use`
  String get termsUse {
    return Intl.message(
      'Terms of use',
      name: 'termsUse',
      desc: '',
      args: [],
    );
  }

  /// `about us`
  String get aboutUs {
    return Intl.message(
      'about us',
      name: 'aboutUs',
      desc: '',
      args: [],
    );
  }

  /// `You must pass every exam`
  String get everyPass {
    return Intl.message(
      'You must pass every exam',
      name: 'everyPass',
      desc: '',
      args: [],
    );
  }

  /// `agree`
  String get agree {
    return Intl.message(
      'agree',
      name: 'agree',
      desc: '',
      args: [],
    );
  }

  /// `cancel`
  String get cancel {
    return Intl.message(
      'cancel',
      name: 'cancel',
      desc: '',
      args: [],
    );
  }

  /// `version`
  String get version {
    return Intl.message(
      'version',
      name: 'version',
      desc: '',
      args: [],
    );
  }

  /// `Give praise`
  String get givePraise {
    return Intl.message(
      'Give praise',
      name: 'givePraise',
      desc: '',
      args: [],
    );
  }

  /// `Ready to start the purchase process`
  String get startShop {
    return Intl.message(
      'Ready to start the purchase process',
      name: 'startShop',
      desc: '',
      args: [],
    );
  }

  /// `Purchase failed`
  String get startShopFail {
    return Intl.message(
      'Purchase failed',
      name: 'startShopFail',
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
