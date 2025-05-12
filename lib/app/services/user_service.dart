import 'package:get/get.dart';
import '../data/models/user_model.dart';
import '../data/providers/api_provider.dart';
import '../data/providers/storage_provider.dart';
import '../utils/logger.dart';

/// 用户服务
///
/// 负责管理用户登录、注册、信息获取等功能
class UserService extends GetxService {
  final ApiProvider _apiProvider = Get.find<ApiProvider>();
  final StorageProvider _storageProvider = Get.find<StorageProvider>();

  // 当前用户
  final Rx<UserModel?> currentUser = Rx<UserModel?>(null);

  // 登录状态
  final RxBool isLoggedIn = false.obs;

  /// 初始化服务
  Future<UserService> init() async {
    Logger.d('UserService initialized');

    // 检查是否已登录
    final token = _storageProvider.getUserToken();
    isLoggedIn.value = token != null && token.isNotEmpty;

    // 如果已登录，获取用户信息
    if (isLoggedIn.value) {
      await getUserInfo();
    }

    return this;
  }

  /// 用户登录
  ///
  /// [email] 邮箱
  /// [password] 密码
  /// 返回登录结果，成功返回true，失败返回false
  Future<bool> login(String email, String password) async {
    try {
      Logger.d('User login: $email');

      final response = await _apiProvider.login(email, password);

      if (response.status.isOk && response.body != null) {
        // 保存令牌
        final token = response.body['token'];
        if (token != null) {
          await _storageProvider.saveUserToken(token);
          isLoggedIn.value = true;

          // 获取用户信息
          await getUserInfo();

          return true;
        }
      }

      return false;
    } catch (e) {
      Logger.e('Login error: $e');
      return false;
    }
  }

  /// 用户注册
  ///
  /// [email] 邮箱
  /// [password] 密码
  /// [name] 用户名
  /// 返回注册结果，成功返回true，失败返回false
  Future<bool> register(String email, String password, String name) async {
    try {
      Logger.d('User register: $email');

      final response = await _apiProvider.register(email, password, name);

      if (response.status.isOk && response.body != null) {
        // 保存令牌
        final token = response.body['token'];
        if (token != null) {
          await _storageProvider.saveUserToken(token);
          isLoggedIn.value = true;

          // 获取用户信息
          await getUserInfo();

          return true;
        }
      }

      return false;
    } catch (e) {
      Logger.e('Register error: $e');
      return false;
    }
  }

  /// 获取用户信息
  ///
  /// 返回用户信息，获取失败返回null
  Future<UserModel?> getUserInfo() async {
    try {
      Logger.d('Getting user info');

      // 先尝试从本地获取
      UserModel? user = _storageProvider.getUserInfo();
      if (user != null) {
        currentUser.value = user;
        return user;
      }

      // 如果本地没有，则从API获取
      final response = await _apiProvider.getUserInfo();

      if (response.status.isOk && response.body != null) {
        user = UserModel.fromJson(response.body);

        // 保存到本地
        await _storageProvider.saveUserInfo(user);

        // 更新当前用户
        currentUser.value = user;

        return user;
      }

      return null;
    } catch (e) {
      Logger.e('Get user info error: $e');
      return null;
    }
  }

  /// 退出登录
  Future<void> logout() async {
    try {
      Logger.d('User logout');

      // 清除本地存储的用户数据
      await _storageProvider.clearUserData();

      // 更新状态
      isLoggedIn.value = false;
      currentUser.value = null;
    } catch (e) {
      Logger.e('Logout error: $e');
    }
  }

  /// 更新用户信息
  ///
  /// [user] 用户信息
  Future<bool> updateUserInfo(UserModel user) async {
    try {
      Logger.d('Updating user info');

      // 构建请求数据
      final data = user.toJson();

      // 调用 API
      final response = await _apiProvider.updateUserInfo(data);

      if (response.status.isOk) {
        // 更新本地存储
        await _storageProvider.saveUserInfo(user);

        // 更新当前用户
        currentUser.value = user;

        return true;
      }

      return false;
    } catch (e) {
      Logger.e('Update user info error: $e');
      return false;
    }
  }

  /// 检查用户是否是会员
  bool isPremiumUser() {
    return currentUser.value != null &&
        currentUser.value!.isPremium &&
        currentUser.value!.isMembershipActive;
  }

  /// 检查用户是否是专业会员
  bool isProUser() {
    return currentUser.value != null &&
        currentUser.value!.isPro &&
        currentUser.value!.isMembershipActive;
  }

  /// 获取会员套餐
  Future<List<Map<String, dynamic>>> getMembershipPlans() async {
    try {
      Logger.d('Getting membership plans');

      final response = await _apiProvider.getMembershipPlans();

      if (response.status.isOk && response.body != null) {
        return List<Map<String, dynamic>>.from(response.body);
      }

      return [];
    } catch (e) {
      Logger.e('Get membership plans error: $e');
      return [];
    }
  }

  /// 获取积分套餐
  Future<List<Map<String, dynamic>>> getPointsPackages() async {
    try {
      Logger.d('Getting points packages');

      final response = await _apiProvider.getPointsPackages();

      if (response.status.isOk && response.body != null) {
        return List<Map<String, dynamic>>.from(response.body);
      }

      return [];
    } catch (e) {
      Logger.e('Get points packages error: $e');
      return [];
    }
  }

  /// 验证支付
  ///
  /// [data] 支付数据
  Future<bool> verifyPayment(Map<String, dynamic> data) async {
    try {
      Logger.d('Verifying payment');

      final response = await _apiProvider.verifyPayment(data);

      return response.status.isOk;
    } catch (e) {
      Logger.e('Verify payment error: $e');
      return false;
    }
  }

  /// 发送重置密码邮件
  ///
  /// [email] 邮箱
  Future<bool> sendResetPasswordEmail(String email) async {
    try {
      Logger.d('Sending reset password email: $email');

      final response = await _apiProvider.sendResetPasswordEmail(email);

      return response.status.isOk;
    } catch (e) {
      Logger.e('Send reset password email error: $e');
      return false;
    }
  }

  /// 使用 Apple 登录
  ///
  /// [identityToken] Apple 身份令牌
  /// [email] 邮箱
  /// [name] 用户名
  Future<bool> loginWithApple({
    required String identityToken,
    String? email,
    String? name,
  }) async {
    try {
      Logger.d('User login with Apple');

      // 构建请求数据
      final data = {
        'identity_token': identityToken,
        if (email != null) 'email': email,
        if (name != null) 'name': name,
      };

      // 调用 API
      final response = await _apiProvider.loginWithApple(data);

      if (response.status.isOk && response.body != null) {
        // 保存令牌
        final token = response.body['token'];
        if (token != null) {
          await _storageProvider.saveUserToken(token);
          isLoggedIn.value = true;

          // 获取用户信息
          await getUserInfo();

          return true;
        }
      }

      return false;
    } catch (e) {
      Logger.e('Login with Apple error: $e');
      return false;
    }
  }

  /// 使用 Google 登录
  ///
  /// [idToken] Google ID 令牌
  /// [email] 邮箱
  /// [name] 用户名
  Future<bool> loginWithGoogle({
    required String idToken,
    required String email,
    String? name,
  }) async {
    try {
      Logger.d('User login with Google');

      // 构建请求数据
      final data = {
        'id_token': idToken,
        'email': email,
        if (name != null) 'name': name,
      };

      // 调用 API
      final response = await _apiProvider.loginWithGoogle(data);

      if (response.status.isOk && response.body != null) {
        // 保存令牌
        final token = response.body['token'];
        if (token != null) {
          await _storageProvider.saveUserToken(token);
          isLoggedIn.value = true;

          // 获取用户信息
          await getUserInfo();

          return true;
        }
      }

      return false;
    } catch (e) {
      Logger.e('Login with Google error: $e');
      return false;
    }
  }

  /// 模拟登录（仅用于开发测试）
  ///
  /// [user] 用户信息
  void mockLogin(UserModel user) {
    try {
      Logger.d('Mock login: ${user.email}');

      // 保存用户信息到本地
      _storageProvider.saveUserInfo(user);

      // 保存一个假的令牌
      _storageProvider
          .saveUserToken('mock_token_${DateTime.now().millisecondsSinceEpoch}');

      // 更新状态
      isLoggedIn.value = true;
      currentUser.value = user;
    } catch (e) {
      Logger.e('Mock login error: $e');
    }
  }

  /// 模拟更新用户信息（仅用于开发测试）
  ///
  /// [user] 用户信息
  Future<void> mockUpdateUser(UserModel user) async {
    try {
      Logger.d('Mock update user: ${user.email}');

      // 保存用户信息到本地
      await _storageProvider.saveUserInfo(user);

      // 更新当前用户
      currentUser.value = user;
    } catch (e) {
      Logger.e('Mock update user error: $e');
    }
  }
}
