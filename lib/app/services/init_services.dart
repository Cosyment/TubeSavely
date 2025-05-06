import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:media_kit/media_kit.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../data/providers/api_provider.dart';
import '../data/providers/storage_provider.dart';
import '../data/repositories/download_repository.dart';
import '../data/repositories/user_repository.dart';
import '../data/repositories/video_repository.dart';
import 'theme_service.dart';
import 'translation_service.dart';

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
  
  // 注册仓库
  Get.put(UserRepository(), permanent: true);
  Get.put(VideoRepository(), permanent: true);
  Get.put(DownloadRepository(), permanent: true);
  
  print('所有服务初始化完成');
}
