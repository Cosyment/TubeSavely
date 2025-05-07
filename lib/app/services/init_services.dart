import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:media_kit/media_kit.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ffmpeg_kit_flutter_full_gpl/ffmpeg_kit.dart';
import '../data/providers/api_provider.dart';
import '../data/providers/storage_provider.dart';
import '../data/repositories/download_repository.dart';
import '../data/repositories/user_repository.dart';
import '../data/repositories/video_repository.dart';
import '../data/repositories/video_converter_repository.dart';
import '../data/repositories/video_player_repository.dart';
import 'theme_service.dart';
import 'translation_service.dart';
import 'video_parser_service.dart';
import 'download_service.dart';
import 'video_converter_service.dart';
import 'video_player_service.dart';

/// 初始化所有服务
Future<void> initServices() async {
  print('正在初始化服务...');

  // 初始化GetStorage
  await GetStorage.init();

  // 初始化MediaKit
  MediaKit.ensureInitialized();

  // 确保ScreenUtil已初始化
  await ScreenUtil.ensureInitialized();

  // 注册服务
  Get.put(ThemeService(), permanent: true);
  Get.put(TranslationService(), permanent: true);
  Get.put(StorageProvider(), permanent: true);
  Get.put(ApiProvider(), permanent: true);

  // 初始化并注册视频解析服务
  final videoParserService = await VideoParserService().init();
  Get.put(videoParserService, permanent: true);

  // 初始化并注册下载服务
  final downloadService = await DownloadService().init();
  Get.put(downloadService, permanent: true);

  // 初始化并注册视频转换服务
  final videoConverterService = await VideoConverterService().init();
  Get.put(videoConverterService, permanent: true);

  // 初始化并注册视频播放服务
  final videoPlayerService = await VideoPlayerService().init();
  Get.put(videoPlayerService, permanent: true);

  // 注册仓库
  Get.put(UserRepository(), permanent: true);
  Get.put(VideoRepository(), permanent: true);
  Get.put(DownloadRepository(), permanent: true);
  Get.put(VideoConverterRepository(), permanent: true);
  Get.put(VideoPlayerRepository(), permanent: true);

  print('所有服务初始化完成');
}
