import 'package:get/get.dart';
import '../controllers/main_controller.dart';
import '../../home/controllers/home_controller.dart';
import '../../history/controllers/history_controller.dart';
import '../../tasks/controllers/tasks_controller.dart';
import '../../more/controllers/more_controller.dart';

class MainBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<MainController>(
      () => MainController(),
    );
    
    // 预先加载各个标签页的控制器
    Get.lazyPut<HomeController>(
      () => HomeController(),
    );
    
    Get.lazyPut<HistoryController>(
      () => HistoryController(),
    );
    
    Get.lazyPut<TasksController>(
      () => TasksController(),
    );
    
    Get.lazyPut<MoreController>(
      () => MoreController(),
    );
  }
}
