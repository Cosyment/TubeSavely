import 'package:get/get.dart';
import '../models/user_model.dart';
import '../providers/api_provider.dart';
import '../providers/storage_provider.dart';

class UserRepository {
  final ApiProvider _apiProvider = Get.find<ApiProvider>();
  final StorageProvider _storageProvider = Get.find<StorageProvider>();

  // 获取用户信息
  Future<UserModel?> getUserInfo() async {
    // 先尝试从本地获取
    UserModel? user = _storageProvider.getUserInfo();
    if (user != null) return user;

    // 如果本地没有，则从API获取
    try {
      final response = await _apiProvider.getUserInfo();
      if (response.status.isOk) {
        user = UserModel.fromJson(response.body);
        // 保存到本地
        await _storageProvider.saveUserInfo(user);
        return user;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // 保存用户令牌
  Future<void> saveUserToken(String token) async {
    await _storageProvider.saveUserToken(token);
  }

  // 获取用户令牌
  String? getUserToken() {
    return _storageProvider.getUserToken();
  }

  // 清除用户数据
  Future<void> clearUserData() async {
    await _storageProvider.clearUserData();
  }

  // 检查用户是否已登录
  bool isLoggedIn() {
    final token = getUserToken();
    return token != null && token.isNotEmpty;
  }

  // 检查用户是否是会员
  bool isPremiumUser() {
    final user = _storageProvider.getUserInfo();
    return user != null && user.isPremium && user.isMembershipActive;
  }

  // 获取会员套餐
  Future<List<Map<String, dynamic>>> getMembershipPlans() async {
    try {
      final response = await _apiProvider.getMembershipPlans();
      if (response.status.isOk) {
        return List<Map<String, dynamic>>.from(response.body);
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  // 验证支付
  Future<bool> verifyPayment(Map<String, dynamic> data) async {
    try {
      final response = await _apiProvider.verifyPayment(data);
      return response.status.isOk;
    } catch (e) {
      return false;
    }
  }
}
