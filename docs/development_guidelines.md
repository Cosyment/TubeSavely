# TubeSavely 项目开发规范文档

## 1. 项目概述

TubeSavely 是一个跨平台的视频下载工具，支持 iOS、Android、macOS、Windows 和 Linux 等多个平台。本项目将使用 GetX 框架进行重写，以提高代码质量和可维护性。

### 1.1 开发要求
**为确保系统架构一致性、开发流程规范化以及协作效率，制定如下开发规范条款，必须严格遵守：**

#### 1.1.1 开发顺序规范
**所有开发任务必须严格按照项目计划中指定的模块划分与实现顺序进行。禁止出现跳过开发阶段、跨模块提前开发或延后核心模块等“跳跃式开发”（Implementation Out of Sequence）行为。**

**凡未我明确批准，擅自变更开发优先级、调整功能实现顺序或执行计划外开发（Off-plan Development），均视为违反开发流程要求，将可能导致代码被回退并重新排期。**

#### 1.1.2 编码准备要求
**开始编码前，须充分了解现有代码库的结构与功能，特别是共用组件如工具类（utility classes）、数据模型（model）、状态管理（provider）等模块。**

**严禁在不了解已有实现的情况下重复创建功能相似或逻辑冗余的类、方法或组件。若发现现有功能无法满足需求，须先进行评估与沟通，再决定是否新增或重构。**

#### 1.1.3 提交前质量控制
**每项功能开发完成后，须自行完成本地编译与功能测试，确保实现逻辑完整、运行稳定、不影响现有功能，再提交代码至版本控制系统，提交前请先更新开发任务计划表状态，代码提交必须遵守代码提交规范。严禁提交未经测试的代码或存在明显缺陷的实现。**


### 1.2 开发环境

| 类别 | 版本 | 说明 |
|------|----------|------|
| Flutter SDK | 3.6.0 | 最新稳定版 |
| Dart SDK | 3.24.5 | 与 Flutter 3.6.0 对应的 Dart 版本 |


## 2. 技术栈规范

### 2.1 核心技术

| 类别 | 技术选择 | 说明 |
|------|----------|------|
| 框架 | Flutter | 跨平台开发框架 |
| 状态管理 | GetX | 轻量级且功能强大的状态管理框架 |
| 本地存储 | GetStorage | GetX 生态的键值对存储方案 |
| 数据库 | SQLite (sqflite_common_ffi) | 轻量级关系型数据库 |
| 网络请求 | GetConnect | GetX 生态的网络请求工具 |
| UI 组件 | Flutter 原生组件 + 自定义组件 | 遵循设计规范的组件库 |
| 媒体处理 | FFmpeg Kit + Media Kit | 视频处理和播放工具 |
| 下载管理 | Background Downloader | 支持后台下载的工具 |

### 2.2 依赖版本控制

```yaml
dependencies:
  flutter:
    sdk: flutter
  flutter_localizations:
    sdk: flutter

  # GetX 核心
  get: ^4.7.2  # 最新稳定版
  # get: ^5.0.0-release-candidate-9.3.2  # 预发布版本，如需尝试最新特性可使用
  get_storage: ^2.1.1

  # 网络和数据
  http: ^1.2.2
  path_provider: ^2.1.3
  sqflite_common_ffi: ^2.3.3
  dio: ^5.4.3+1

  # UI 相关
  flutter_screenutil: ^5.9.0
  shimmer: ^3.0.0
  cached_network_image: ^3.3.1
  flutter_easyloading: ^3.0.5
  flutter_animate: ^4.5.0
  lottie: ^3.1.2

  # 功能组件
  package_info_plus: ^8.0.1
  url_launcher: ^6.2.6
  permission_handler: ^11.3.1
  background_downloader: ^8.5.0
  media_kit: ^1.1.10
  media_kit_video: ^1.2.4
  media_kit_libs_video: ^1.0.4
  ffmpeg_kit_flutter_full_gpl: ^6.0.3
  file_picker: ^8.0.5
  image_gallery_saver: ^2.0.3
  open_file: ^3.3.2
  window_manager: ^0.3.9

  # 支付相关
  in_app_purchase: ^3.1.13  # iOS/macOS 内购
  flutter_stripe: ^10.1.0    # Stripe 支付

  # 国际化
  intl: ^0.19.0
  intl_utils: ^2.8.7
```

## 3. 项目结构规范

```
lib/
├── app/                      # 应用层
│   ├── bindings/             # 依赖注入绑定
│   ├── controllers/          # GetX 控制器
│   ├── data/                 # 数据层
│   │   ├── models/           # 数据模型
│   │   │   ├── download/     # 下载相关模型
│   │   │   ├── user/         # 用户相关模型
│   │   │   ├── video/        # 视频相关模型
│   │   │   └── common/       # 通用模型
│   │   ├── providers/        # 数据提供者
│   │   │   ├── api_provider.dart      # API 数据提供者
│   │   │   └── storage_provider.dart  # 本地存储提供者
│   │   └── repositories/     # 数据仓库
│   │       ├── download_repository.dart    # 下载仓库
│   │       ├── user_repository.dart        # 用户仓库
│   │       ├── video_repository.dart       # 视频仓库
│   │       ├── video_converter_repository.dart  # 视频转换仓库
│   │       └── video_player_repository.dart    # 视频播放仓库
│   ├── modules/              # 功能模块
│   │   ├── splash/           # 启动页模块
│   │   │   ├── bindings/     # 启动页绑定
│   │   │   ├── controllers/  # 启动页控制器
│   │   │   └── views/        # 启动页视图
│   │   ├── home/             # 首页模块
│   │   │   ├── bindings/     # 首页绑定
│   │   │   ├── controllers/  # 首页控制器
│   │   │   └── views/        # 首页视图
│   │   ├── main/             # 主页模块
│   │   │   ├── bindings/     # 主页绑定
│   │   │   ├── controllers/  # 主页控制器
│   │   │   └── views/        # 主页视图
│   │   ├── video/            # 视频相关模块
│   │   │   ├── detail/       # 视频详情模块
│   │   │   │   ├── bindings/
│   │   │   │   ├── controllers/
│   │   │   │   └── views/
│   │   │   ├── player/       # 视频播放模块
│   │   │   │   ├── bindings/
│   │   │   │   ├── controllers/
│   │   │   │   └── views/
│   │   │   └── convert/      # 视频转换模块
│   │   │       ├── bindings/
│   │   │       ├── controllers/
│   │   │       └── views/
│   │   ├── settings/         # 设置模块
│   │   │   ├── bindings/
│   │   │   ├── controllers/
│   │   │   └── views/
│   │   ├── history/          # 历史记录模块
│   │   │   ├── bindings/
│   │   │   ├── controllers/
│   │   │   └── views/
│   │   ├── tasks/            # 任务管理模块
│   │   │   ├── bindings/
│   │   │   ├── controllers/
│   │   │   └── views/
│   │   ├── login/            # 登录模块
│   │   │   ├── bindings/
│   │   │   ├── controllers/
│   │   │   └── views/
│   │   ├── profile/          # 个人资料模块
│   │   │   ├── bindings/
│   │   │   ├── controllers/
│   │   │   └── views/
│   │   ├── payment/          # 支付模块 (计划中)
│   │   │   ├── bindings/
│   │   │   ├── controllers/
│   │   │   └── views/
│   │   └── more/             # 更多功能模块
│   │       ├── bindings/
│   │       ├── controllers/
│   │       └── views/
│   ├── routes/               # 路由管理
│   │   ├── app_pages.dart    # 页面路由定义
│   │   └── app_routes.dart   # 路由常量
│   ├── services/             # 服务层
│   │   ├── download_service.dart     # 下载服务
│   │   ├── init_services.dart        # 服务初始化
│   │   ├── theme_service.dart        # 主题服务
│   │   ├── translation_service.dart  # 翻译服务
│   │   ├── user_service.dart         # 用户服务
│   │   ├── video_converter_service.dart  # 视频转换服务
│   │   ├── video_parser_service.dart     # 视频解析服务
│   │   └── video_player_service.dart     # 视频播放服务
│   ├── theme/                # 主题管理
│   │   ├── app_colors.dart   # 颜色定义
│   │   ├── app_text_styles.dart  # 文本样式
│   │   └── app_theme.dart    # 主题定义
│   └── utils/                # 工具类
│       ├── constants.dart     # 常量定义
│       ├── extensions/        # 扩展方法
│       ├── helpers/           # 辅助函数
│       └── widgets/           # 通用组件
├── core/                     # 核心功能
│   ├── downloader/           # 下载功能
│   │   ├── download_manager.dart  # 下载管理器
│   │   └── download_task.dart     # 下载任务
│   ├── ffmpeg/               # FFmpeg 封装
│   │   └── ffmpeg_executor.dart   # FFmpeg 执行器
│   ├── converter/            # 转换功能
│   │   └── converter.dart         # 转换器
│   └── payment/              # 支付功能 (计划中)
│       ├── apple_payment.dart     # Apple 支付
│       └── stripe_payment.dart    # Stripe 支付
├── generated/                # 自动生成的代码
│   ├── intl/                 # 国际化相关
│   │   ├── messages_all.dart
│   │   ├── messages_en.dart
│   │   ├── messages_ja.dart
│   │   ├── messages_ko.dart
│   │   └── messages_zh.dart
│   └── l10n.dart             # 国际化入口
└── main.dart             # 入口文件
```

## 4. 编码规范

### 4.1 命名规范

| 类型 | 规范 | 示例 |
|------|------|------|
| 类名 | 大驼峰命名法 | `HomeController`, `VideoModel` |
| 变量名 | 小驼峰命名法 | `videoUrl`, `isLoading` |
| 常量 | 全大写下划线分隔 | `API_BASE_URL`, `DEFAULT_TIMEOUT` |
| 私有变量 | 下划线前缀 | `_videoList`, `_isInitialized` |
| 文件名 | 小写下划线分隔 | `home_controller.dart`, `video_model.dart` |

### 4.2 代码组织

- 每个功能模块包含自己的视图、控制器和绑定
- 控制器负责状态管理和业务逻辑
- 视图只负责 UI 展示，不包含业务逻辑
- 数据模型使用不可变对象，通过工厂构造函数创建

### 4.3 注释规范

- 类和公共方法必须添加文档注释
- 复杂逻辑需要添加说明性注释
- TODO 注释必须包含具体任务描述和责任人

```dart
/// 视频下载控制器
///
/// 负责管理视频下载状态和操作
class DownloadController extends GetxController {
  // TODO(developer): 实现断点续传功能

  /// 开始下载视频
  ///
  /// [url] 视频链接
  /// [fileName] 保存的文件名
  /// 返回下载任务 ID
  Future<String> startDownload(String url, String fileName) {
    // 实现下载逻辑
  }
}
```

## 5. UI 设计规范

### 5.1 颜色规范

| 用途 | 亮色模式 | 暗色模式 |
|------|----------|----------|
| 主色调 | #8B5CF6 (紫色) | #8B5CF6 (紫色) |
| 强调色 | 渐变色 #8B5CF6 -> #EC4899 | 渐变色 #8B5CF6 -> #EC4899 |
| 背景色 | #FFFFFF | #0F172A |
| 卡片背景 | #F8FAFC | #1E293B |
| 文本主色 | #1E293B | #F8FAFC |
| 文本次色 | #64748B | #94A3B8 |
| 边框色 | #E2E8F0 | #334155 |
| 成功色 | #10B981 | #10B981 |
| 警告色 | #F59E0B | #F59E0B |
| 错误色 | #EF4444 | #EF4444 |

### 5.2 字体规范

- 主要字体：系统默认字体
- 标题大小：20-24sp
- 正文大小：14-16sp
- 说明文字：12sp
- 按钮文字：16sp

### 5.3 组件规范

- 圆角大小：8-12px
- 卡片阴影：轻微阴影增加层次感
- 按钮样式：渐变背景或纯色背景
- 输入框样式：圆角边框，聚焦时显示主色调边框
- 列表项样式：卡片式设计，悬停效果

### 5.4 响应式布局规范

- 移动端基准设计尺寸：750x1378
- 桌面端默认窗口尺寸：950x650
- 桌面端最小窗口尺寸：800x600
- 使用 `flutter_screenutil` 进行屏幕适配
- 使用 Flex 布局实现响应式设计

## 6. 功能模块规范

### 6.1 核心功能模块

#### 6.1.1 下载管理模块

- 支持多种视频平台链接解析
- 支持选择不同清晰度和格式
- 支持后台下载和断点续传
- 支持下载进度实时显示
- 支持下载完成通知

#### 6.1.2 视频处理模块

- 支持视频格式转换
- 支持视频压缩
- 支持提取音频
- 支持视频信息获取
- 支持视频预览

#### 6.1.3 支付模块

- iOS/macOS 平台使用 Apple In-App Purchase
- 其他平台使用 Stripe 支付
- 支持会员订阅和积分购买
- 支持交易记录查询
- 支持支付状态同步

### 6.2 UI 功能模块

#### 6.2.1 移动端模块

- 启动页：品牌展示和初始化
- 首页：URL 输入和快速下载
- 视频详情页：格式选择和下载控制
- 任务管理页：下载任务列表和控制
- 历史记录页：已下载视频记录
- 设置页：应用配置和个性化
- 支付页：会员订阅和积分购买
- 更多页：其他功能入口

#### 6.2.2 桌面端模块

- 主窗口：分段控制导航
- 下载页：URL 解析和下载管理
- 转换页：视频格式转换
- 设置页：应用配置
- 支付页：会员订阅和积分购买

## 7. API 接口规范

### 7.1 基础配置

- API 基础 URL：`https://api.tubesavely.cosyment.com`
- API 文档地址：`https://api.tubesavely.cosyment.com/docs`
- 请求超时时间：30 秒
- 重试次数：3 次

### 7.2 主要接口

| 接口路径 | 方法 | 功能描述 | 参数 |
|---------|------|----------|------|
| `/parse` | GET | 解析视频链接 | `url`: 视频链接 |
| `/user/login` | POST | 用户登录 | `email`, `password` |
| `/user/register` | POST | 用户注册 | `email`, `password`, `name` |
| `/payment/verify` | POST | 验证支付 | `receipt`, `platform` |
| `/payment/products` | GET | 获取商品列表 | `platform` |

### 7.3 错误处理

- 使用标准 HTTP 状态码
- 错误响应格式：`{ "code": 错误码, "message": "错误信息" }`
- 网络错误统一处理和重试机制
- 用户友好的错误提示

## 8. 支付系统规范

### 8.1 支付平台集成

#### 8.1.1 Apple In-App Purchase (iOS/macOS)

- 使用 `in_app_purchase` 插件
- 支持自动续期订阅
- 支持消耗性商品（积分包）
- 支持恢复购买
- 支持沙盒测试环境

```dart
// 示例代码
final InAppPurchase _inAppPurchase = InAppPurchase.instance;
final Stream<List<PurchaseDetails>> _purchaseUpdated = _inAppPurchase.purchaseStream;

// 初始化
void initStoreInfo() async {
  final bool available = await _inAppPurchase.isAvailable();
  if (!available) {
    // 处理商店不可用情况
    return;
  }

  // 加载商品
  final ProductDetailsResponse response = await _inAppPurchase.queryProductDetails(_productIds.toSet());
  // 处理商品信息
}

// 购买商品
void buyProduct(ProductDetails product) {
  final PurchaseParam purchaseParam = PurchaseParam(productDetails: product);
  _inAppPurchase.buyNonConsumable(purchaseParam: purchaseParam);
}
```

#### 8.1.2 Stripe 支付 (Android/Windows/Linux)

- 使用 `flutter_stripe` 插件
- 支持信用卡支付
- 支持 Google Pay/Samsung Pay
- 支持订阅和一次性支付
- 支持测试模式

```dart
// 示例代码
// 初始化 Stripe
Stripe.publishableKey = 'pk_test_your_key';

// 创建支付意图
final paymentIntentResult = await _stripeRepository.createPaymentIntent(
  amount: amount,
  currency: 'usd',
);

// 确认支付
await Stripe.instance.confirmPayment(
  paymentIntentResult['client_secret'],
  PaymentMethodParams.card(
    paymentMethodData: PaymentMethodData(
      billingDetails: billingDetails,
    ),
  ),
);
```

### 8.2 支付流程

1. 从服务器获取商品列表
2. 用户选择商品
3. 根据平台调用相应支付接口
4. 支付完成后向服务器验证支付
5. 服务器确认支付后更新用户权益
6. 客户端同步用户权益状态

### 8.3 会员体系

- 普通用户：基础功能，有下载次数限制
- 高级会员：无下载次数限制，支持高级格式
- 专业会员：所有功能无限制，优先支持

## 9. 测试规范

### 9.1 单元测试

- 控制器逻辑测试
- 服务功能测试
- 工具类方法测试
- 使用 `test` 和 `mockito` 包

### 9.2 集成测试

- 页面导航测试
- 数据流测试
- API 集成测试
- 使用 `integration_test` 包

### 9.3 UI 测试

- 组件渲染测试
- 响应式布局测试
- 主题切换测试
- 使用 `flutter_test` 包

## 10. 版本控制规范

### 10.1 Git 工作流

- 主分支：`master`（稳定版本）
- 开发分支：`develop`（开发中版本）
- 功能分支：`feature/xxx`（新功能开发）
- 修复分支：`bugfix/xxx`（bug 修复）
- 发布分支：`release/x.x.x`（版本发布准备）

### 10.2 提交规范

提交信息格式：`<type>(<scope>): <subject>`

类型（type）:
- `feat`: 新功能
- `fix`: 修复 bug
- `docs`: 文档更新
- `style`: 代码格式调整
- `refactor`: 重构
- `perf`: 性能优化
- `test`: 测试相关
- `chore`: 构建过程或辅助工具变动

示例：
- `feat(download): 添加断点续传功能`
- `fix(payment): 修复 iOS 支付验证失败问题`

### 10.3 版本号规范

版本号格式：`x.y.z`（主版本号.次版本号.修订号）

- 主版本号：不兼容的 API 修改
- 次版本号：向下兼容的功能性新增
- 修订号：向下兼容的问题修正

## 11. 发布规范

### 11.1 应用商店发布

- App Store (iOS/macOS)
- Google Play (Android)
- Microsoft Store (Windows)
- Snap Store (Linux)

### 11.2 发布前检查清单

- 所有测试通过
- 版本号和构建号更新
- 更新日志编写
- 隐私政策更新
- 应用截图更新
- 支付功能验证

## 12. 文档规范

### 12.1 代码文档

- 使用 dartdoc 格式
- 公共 API 必须有文档注释
- 复杂算法需要详细说明

### 12.2 项目文档

- README.md：项目概述和快速开始
- CONTRIBUTING.md：贡献指南
- CHANGELOG.md：版本更新日志
- API.md：API 接口文档

## 13. 性能优化规范

### 13.1 内存优化

- 避免内存泄漏
- 及时释放不需要的资源
- 使用 GetX 的懒加载机制

### 13.2 渲染优化

- 避免不必要的重建
- 使用 const 构造函数
- 合理使用 ListView.builder

### 13.3 网络优化

- 实现请求缓存
- 图片懒加载
- 减少不必要的网络请求

## 14. 安全规范

### 14.1 数据安全

- 敏感数据加密存储
- 使用 HTTPS 进行网络通信
- 支付信息不在本地存储

### 14.2 代码安全

- 避免硬编码敏感信息
- 使用环境变量存储密钥
- 混淆发布版本代码

## 15. 无障碍支持规范

- 支持屏幕阅读器
- 提供足够的对比度
- 支持键盘导航
- 提供替代文本

## 16. 国际化规范

- 支持英语、中文、日语、韩语
- 使用 Flutter 国际化机制
- 文本资源外部化
- 支持 RTL 布局

## 17. 开发流程规范

### 17.1 功能开发流程

1. 需求分析和任务拆分
2. 创建功能分支
3. 编写单元测试
4. 实现功能代码
5. 进行代码审查
6. 合并到开发分支
7. 集成测试

### 17.2 Bug 修复流程

1. 创建 Bug 修复分支
2. 编写测试用例复现问题
3. 修复 Bug
4. 验证修复效果
5. 代码审查
6. 合并到开发分支

## 18. 项目管理规范

### 18.1 任务管理

- 使用 GitHub Issues 或 Jira 进行任务管理
- 任务必须包含明确的描述、优先级和截止日期
- 使用标签分类任务类型和状态

### 18.2 代码审查

- 所有代码必须经过审查才能合并
- 审查重点：代码质量、性能、安全性、可维护性
- 使用 Pull Request 进行代码审查

## 19. 持续集成与部署

### 19.1 CI/CD 流程

- 使用 GitHub Actions 或 GitLab CI 进行自动化构建
- 每次提交自动运行测试
- 合并到主分支自动构建测试版本
- 发布分支自动构建发布版本

### 19.2 环境配置

- 开发环境：
  - Flutter SDK: 3.6.0
  - Dart SDK: 3.24.5
  - IDE: Android Studio / VS Code
  - 用于日常开发

- 测试环境：
  - 与开发环境相同
  - 用于功能测试

- 预发布环境：
  - 与生产环境相同
  - 用于发布前验证

- 生产环境：
  - Flutter SDK: 3.6.0
  - Dart SDK: 3.24.5
  - 用于最终用户使用

## 20. 平台特定配置

### 20.1 iOS/macOS 特定配置

- **Apple Pay 集成**：
  - 在 Xcode 中启用 Apple Pay 功能
  - 配置商家 ID 和支付处理证书
  - 在 Info.plist 中添加必要的配置

- **App Store 配置**：
  - 配置应用内购买项目
  - 设置订阅组和定价
  - 准备沙盒测试账号

- **权限配置**：
  - 相册访问权限
  - 文件系统访问权限
  - 网络权限

### 20.2 Android 特定配置

- **Stripe 支付集成**：
  - 在 AndroidManifest.xml 中添加必要的权限
  - 配置 Stripe 公钥
  - 设置支付回调 URL

- **Google Play 配置**：
  - 配置应用内购买项目
  - 设置订阅选项
  - 准备测试账号

- **权限配置**：
  - 存储权限
  - 网络状态权限
  - 通知权限

### 20.3 桌面平台配置

- **Windows**：
  - 配置安装程序
  - 设置文件关联
  - 配置 Stripe 支付

- **Linux**：
  - 配置 Snap 包
  - 设置文件权限
  - 配置 Stripe 支付

## 21. 错误处理与用户反馈

### 21.1 全局错误处理策略

- 使用 GetX 的全局错误处理机制
- 实现自定义错误处理中间件
- 区分网络错误、业务错误和系统错误
- 记录错误日志并上报到服务器

```dart
// 全局错误处理示例
Getx.handleError((error) {
  if (error is NetworkError) {
    Get.snackbar('网络错误', '请检查网络连接');
  } else if (error is BusinessError) {
    Get.snackbar('操作失败', error.message);
  } else {
    Get.snackbar('系统错误', '请稍后重试');
    // 上报错误
    ErrorReporter.report(error);
  }
});
```

### 21.2 用户反馈机制

- 实现应用内反馈表单
- 集成崩溃报告工具
- 提供问题截图和日志上传功能
- 设置反馈优先级和分类

## 22. 离线功能支持

### 22.1 离线数据缓存

- 缓存已下载的视频信息
- 缓存用户设置和偏好
- 使用 GetStorage 存储离线数据
- 实现定期数据同步机制

### 22.2 离线操作队列

- 记录离线状态下的用户操作
- 恢复网络连接后自动执行队列
- 处理操作冲突和失败情况
- 提供操作状态反馈

## 23. 数据同步机制

### 23.1 多设备同步

- 使用云端存储用户数据
- 实现增量同步算法
- 处理同步冲突
- 提供同步状态指示

### 23.2 同步策略

- 自动同步：应用启动、网络恢复时
- 手动同步：用户触发
- 定期同步：固定时间间隔
- 选择性同步：用户选择同步内容

## 24. GetX 最佳实践

### 24.1 状态管理

- 使用 `.obs` 创建响应式变量
- 使用 `Obx` 或 `GetX` 构建响应式 UI
- 避免在 UI 中直接修改状态
- 使用 `ever`、`once`、`debounce` 和 `interval` 监听状态变化

```dart
// 响应式状态示例
final count = 0.obs;
final user = User().obs;
final products = <Product>[].obs;

// 监听状态变化
ever(count, (_) => print('Count changed'));
debounce(searchQuery, (_) => performSearch(), time: Duration(milliseconds: 500));
```

### 24.2 依赖注入

- 使用 `Get.put()` 注入全局单例
- 使用 `Get.lazyPut()` 延迟初始化
- 使用 `Get.create()` 创建非单例实例
- 使用 `Bindings` 类组织依赖

```dart
// 依赖注入示例
class HomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<HomeController>(() => HomeController());
    Get.lazyPut<VideoRepository>(() => VideoRepository());
  }
}
```

### 24.3 路由管理

- 使用命名路由
- 使用 `GetPage` 定义路由
- 使用 `Get.toNamed()` 导航
- 使用 `Get.offNamed()` 替换页面
- 使用 `Get.offAllNamed()` 清除堆栈

```dart
// 路由示例
Get.toNamed('/video-detail', arguments: {'url': videoUrl});

// 在目标页面获取参数
final args = Get.arguments;
final url = args['url'];
```

### 24.4 服务管理

- 使用 `GetxService` 创建持久服务
- 使用 `Get.find<T>()` 查找服务
- 使用 `Get.putAsync()` 异步初始化服务

```dart
// 服务示例
class StorageService extends GetxService {
  Future<StorageService> init() async {
    // 初始化逻辑
    return this;
  }
}

// 初始化服务
Get.putAsync(() => StorageService().init());
```

## 25. 应用权限管理

### 25.1 权限请求策略

- 仅请求必要权限
- 在需要时请求权限
- 提供权限用途说明
- 处理权限拒绝情况

### 25.2 权限列表

| 平台 | 权限 | 用途 |
|------|------|------|
| 所有平台 | 网络访问 | 视频解析和下载 |
| 所有平台 | 存储访问 | 保存下载的视频 |
| iOS/Android | 通知权限 | 下载完成通知 |
| Android | 前台服务 | 后台下载 |
| macOS/Windows | 文件系统访问 | 保存下载的视频 |

### 25.3 权限请求实现

```dart
// 权限请求示例
Future<bool> requestStoragePermission() async {
  if (Platform.isAndroid) {
    final status = await Permission.storage.request();
    return status.isGranted;
  } else if (Platform.isIOS) {
    final status = await Permission.photos.request();
    return status.isGranted;
  }
  return true; // 桌面平台默认有权限
}
```

## 26. 深色模式适配

### 26.1 颜色适配

- 使用 `Get.isDarkMode` 检测当前模式
- 定义亮色/暗色主题颜色映射
- 使用 `context.theme.colorScheme` 获取当前主题颜色
- 避免硬编码颜色值

```dart
// 颜色适配示例
final backgroundColor = Get.isDarkMode ? AppTheme.darkBackground : AppTheme.lightBackground;

// 或者使用主题
final backgroundColor = Theme.of(context).colorScheme.background;
```

### 26.2 图片和图标适配

- 为深色模式提供专用图片资源
- 使用 SVG 图标并动态设置颜色
- 调整图片亮度和对比度
- 使用自适应图标

### 26.3 文本可读性

- 确保文本与背景有足够对比度
- 调整文本阴影增强可读性
- 使用适当的字体粗细
- 测试极端情况下的可读性

## 27. 总结

本规范文档为 TubeSavely 项目的重写提供了全面的指导，包括技术选型、代码规范、UI 设计、功能模块、API 接口、支付系统等方面。开发团队应严格遵循这些规范，确保项目的质量和一致性。

### 27.1 技术栈更新

本文档于 2024 年 5 月更新，采用了最新的技术栈：

- Flutter SDK: 3.6.0
- Dart SDK: 3.24.5
- GetX: 4.7.2 (最新稳定版)

随着项目的进展，本规范可能会进行更新和完善，以适应新的需求和技术变化。所有团队成员都应该定期查阅最新版本的规范文档。
