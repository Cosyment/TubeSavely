import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../controllers/developer_controller.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_text_styles.dart';

/// 开发者测试页面
class DeveloperView extends GetView<DeveloperController> {
  const DeveloperView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '开发者测试',
          style: AppTextStyles.titleLarge,
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildUserInfoSection(),
            SizedBox(height: 16.h),
            _buildApiTestSection(),
            SizedBox(height: 16.h),
            _buildLoginTestSection(),
            SizedBox(height: 16.h),
            _buildMockLoginSection(),
            SizedBox(height: 16.h),
            _buildPremiumTestSection(),
          ],
        ),
      ),
    );
  }

  /// 构建用户信息区域
  Widget _buildUserInfoSection() {
    return Obx(() {
      final isLoggedIn = controller.isLoggedIn.value;
      final user = controller.currentUser.value;

      return Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '当前用户信息',
                style: AppTextStyles.titleMedium.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8.h),
              if (isLoggedIn && user != null) ...[
                _buildInfoRow('ID', user.id ?? ''),
                _buildInfoRow('名称', user.name ?? ''),
                _buildInfoRow('邮箱', user.email ?? ''),
                _buildInfoRow('等级', '${user.level}'),
                _buildInfoRow('积分', '${user.points}'),
                _buildInfoRow('会员到期', user.membershipExpiry != null
                    ? '${user.membershipExpiry!.year}-${user.membershipExpiry!.month.toString().padLeft(2, '0')}-${user.membershipExpiry!.day.toString().padLeft(2, '0')}'
                    : '无'),
                _buildInfoRow('会员状态', user.isMembershipActive ? '有效' : '无效'),
                _buildInfoRow('高级用户', user.isPremium ? '是' : '否'),
                _buildInfoRow('专业用户', user.isPro ? '是' : '否'),
              ] else
                Text(
                  '未登录',
                  style: AppTextStyles.bodyMedium,
                ),
              SizedBox(height: 8.h),
              if (isLoggedIn)
                ElevatedButton(
                  onPressed: controller.logout,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red.shade100,
                    foregroundColor: Colors.red,
                  ),
                  child: Text('退出登录'),
                ),
            ],
          ),
        ),
      );
    });
  }

  /// 构建API测试区域
  Widget _buildApiTestSection() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'API测试',
              style: AppTextStyles.titleMedium.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8.h),
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: TextField(
                    controller: controller.apiUrlController,
                    decoration: InputDecoration(
                      labelText: 'API路径',
                      hintText: '/parse',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                SizedBox(width: 8.w),
                Expanded(
                  flex: 1,
                  child: Obx(() => DropdownButtonFormField<String>(
                        value: controller.selectedMethod.value,
                        decoration: InputDecoration(
                          labelText: '方法',
                          border: OutlineInputBorder(),
                        ),
                        items: controller.httpMethods
                            .map((method) => DropdownMenuItem(
                                  value: method,
                                  child: Text(method),
                                ))
                            .toList(),
                        onChanged: (value) {
                          if (value != null) {
                            controller.selectedMethod.value = value;
                          }
                        },
                      )),
                ),
              ],
            ),
            SizedBox(height: 8.h),
            TextField(
              controller: controller.apiParamsController,
              decoration: InputDecoration(
                labelText: '参数 (JSON)',
                hintText: '{"url": "https://example.com/video"}',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            SizedBox(height: 8.h),
            SizedBox(
              width: double.infinity,
              child: Obx(() => ElevatedButton(
                    onPressed: controller.isApiLoading.value
                        ? null
                        : controller.sendApiRequest,
                    child: controller.isApiLoading.value
                        ? SizedBox(
                            width: 20.w,
                            height: 20.w,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.w,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white),
                            ),
                          )
                        : Text('发送请求'),
                  )),
            ),
            SizedBox(height: 8.h),
            Text(
              '响应结果:',
              style: AppTextStyles.bodyMedium.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 4.h),
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(8.w),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8.r),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Obx(() => Text(
                    controller.apiResponse.value.isEmpty
                        ? '请发送请求...'
                        : controller.apiResponse.value,
                    style: AppTextStyles.bodySmall.copyWith(
                      fontFamily: 'monospace',
                    ),
                  )),
              constraints: BoxConstraints(
                minHeight: 100.h,
                maxHeight: 200.h,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 构建登录测试区域
  Widget _buildLoginTestSection() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'API登录测试',
              style: AppTextStyles.titleMedium.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8.h),
            TextField(
              controller: controller.emailController,
              decoration: InputDecoration(
                labelText: '邮箱',
                hintText: 'user@example.com',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            SizedBox(height: 8.h),
            TextField(
              controller: controller.passwordController,
              decoration: InputDecoration(
                labelText: '密码',
                border: OutlineInputBorder(),
              ),
              obscureText: true,
            ),
            SizedBox(height: 8.h),
            SizedBox(
              width: double.infinity,
              child: Obx(() => ElevatedButton(
                    onPressed: controller.isLoginLoading.value
                        ? null
                        : controller.apiLogin,
                    child: controller.isLoginLoading.value
                        ? SizedBox(
                            width: 20.w,
                            height: 20.w,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.w,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white),
                            ),
                          )
                        : Text('API登录'),
                  )),
            ),
          ],
        ),
      ),
    );
  }

  /// 构建模拟登录区域
  Widget _buildMockLoginSection() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '模拟登录',
              style: AppTextStyles.titleMedium.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8.h),
            TextField(
              controller: controller.mockNameController,
              decoration: InputDecoration(
                labelText: '用户名',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 8.h),
            TextField(
              controller: controller.mockEmailController,
              decoration: InputDecoration(
                labelText: '邮箱',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            SizedBox(height: 8.h),
            TextField(
              controller: controller.mockIdController,
              decoration: InputDecoration(
                labelText: '用户ID',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 8.h),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      labelText: '用户等级',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      if (value.isNotEmpty) {
                        controller.mockUserLevel.value = int.tryParse(value) ?? 0;
                      }
                    },
                    controller: TextEditingController(
                        text: controller.mockUserLevel.value.toString()),
                  ),
                ),
                SizedBox(width: 8.w),
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      labelText: '积分',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      if (value.isNotEmpty) {
                        controller.mockUserPoints.value = int.tryParse(value) ?? 0;
                      }
                    },
                    controller: TextEditingController(
                        text: controller.mockUserPoints.value.toString()),
                  ),
                ),
              ],
            ),
            SizedBox(height: 8.h),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: controller.mockLogin,
                child: Text('模拟登录'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 构建高级用户测试区域
  Widget _buildPremiumTestSection() {
    return Obx(() {
      final isLoggedIn = controller.isLoggedIn.value;
      final isPremium = controller.isPremiumUser.value;
      final isPro = controller.isProUser.value;

      return Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '高级用户测试',
                style: AppTextStyles.titleMedium.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8.h),
              if (!isLoggedIn)
                Text(
                  '请先登录',
                  style: AppTextStyles.bodyMedium,
                )
              else ...[
                SwitchListTile(
                  title: Text('高级用户'),
                  value: isPremium,
                  onChanged: (_) => controller.togglePremiumUser(),
                  activeColor: AppColors.primary,
                ),
                SwitchListTile(
                  title: Text('专业用户'),
                  value: isPro,
                  onChanged: (_) => controller.toggleProUser(),
                  activeColor: AppColors.primary,
                ),
              ],
            ],
          ),
        ),
      );
    });
  }

  /// 构建信息行
  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 2.h),
      child: Row(
        children: [
          Text(
            '$label: ',
            style: AppTextStyles.bodyMedium.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: AppTextStyles.bodyMedium,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
