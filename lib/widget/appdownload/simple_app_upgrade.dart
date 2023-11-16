import 'package:dio/dio.dart';
import 'package:downloaderx/utils/exit.dart';
import 'package:downloaderx/utils/platform_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../plugin/upgrade_plugin.dart';
import '../../utils/pub_method.dart';
import '../theme_gradient_button.dart';
import 'app_market.dart';
import 'app_upgrade.dart';
import 'download_status.dart';
import 'liquid_progress_indicator.dart';

///
/// app升级提示控件
///
class SimpleAppUpgradeWidget extends StatefulWidget {
  const SimpleAppUpgradeWidget(
      {required this.title,
      required this.contents,
      this.okBackgroundColors,
      this.progressBar,
      this.progressBarColor,
      this.borderRadius = 10,
      this.downloadUrl,
      this.force = false,
      this.status,
      this.iosAppId,
      this.appMarketInfo,
      this.downloadProgress,
      this.downloadStatusChange});

  /// 升级标题
  final String? title;

  /// 升级提示内容
  final List<String>? contents;

  /// 下载进度条
  final Widget? progressBar;

  /// 进度条颜色
  final Color? progressBarColor;

  /// 确认控件背景颜色,2种颜色左到右线性渐变
  final List<Color>? okBackgroundColors;

  /// app安装包下载url,没有下载跳转到应用宝等渠道更新
  final String? downloadUrl;

  /// 圆角半径
  final double? borderRadius;

  /// 是否强制升级,设置true没有取消按钮
  final bool? force;

  /// ios app id,用于跳转app store
  final String? iosAppId;

  final int? status;

  /// 指定跳转的应用市场，
  /// 如果不指定将会弹出提示框，让用户选择哪一个应用市场。
  final AppMarketInfo? appMarketInfo;

  final DownloadProgressCallback? downloadProgress;
  final DownloadStatusChangeCallback? downloadStatusChange;

  @override
  State<StatefulWidget> createState() => _SimpleAppUpgradeWidget();
}

class _SimpleAppUpgradeWidget extends State<SimpleAppUpgradeWidget> {
  static const String _downloadApkName = 'drilling.apk';

  /// 下载进度
  double _downloadProgress = 0.0;

  int downloadCount = 0;

  DownloadStatus _downloadStatus = DownloadStatus.none;

  bool isShow = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Stack(
        children: <Widget>[
          _downloadProgress > 0
              ? Positioned.fill(child: _buildDownloadProgress())
              : Container(height: 10),
          _buildInfoWidget(context)
        ],
      ),
    );
  }

  Widget _buildInfoWidget(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          alignment: Alignment.center,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 30.w),
                constraints: BoxConstraints(maxWidth: 570.w),
                decoration: BoxDecoration(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(16)),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 42.w),
                    Align(
                        alignment: Alignment.topLeft,
                        child: Text(widget.title ?? '',
                            style: TextStyle(
                                fontSize: 33.sp, fontWeight: FontWeight.bold))),
                    SizedBox(height: 24.w),
                    Align(
                        alignment: Alignment.topLeft,
                        child: Container(
                            constraints: BoxConstraints(maxHeight: 230.w),
                            child: SingleChildScrollView(
                                child: Text(widget.contents![0],
                                    style: TextStyle(
                                        height: 1.5, fontSize: 26.sp))))),
                    Visibility(
                        visible: isShow,
                        child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 30.w),
                            child: Text('更新中 $downloadCount %',
                                style: TextStyle(
                                    fontSize: 24.sp,
                                    fontWeight: FontWeight.bold)))),
                    _buildAction(context),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// 构建取消或者升级按钮
  _buildAction(context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 40.w),
      child: Visibility(
        visible: !isShow,
        child: Row(
          children: [
            widget.status! == 1
                ? SizedBox(width: 20.w)
                : _buildCancelActionButton(),
            SizedBox(width: 20.w),
            _buildOkActionButton(),
          ],
        ),
      ),
    );
  }

  /// 取消按钮
  _buildCancelActionButton() {
    return Expanded(
      child: ThemeGradientButton(
        text: widget.status == 3 ? "不在提醒" : "下次再说",
        w: 200.w,
        h: 75.w,
        fontColor: Theme.of(context).hoverColor.withOpacity(0.5),
        highlighted: false,
        radius: 8,
        fillColor: Colors.transparent,
        fontsize: 28.sp,
        ontap: () {
          if (widget.status == 3) {
            PubMethodUtils.putSharedPreferences("updateAppStatus", true);
          }
          Navigator.pop(context);
        },
      ),
    );
  }

  /// 确定按钮
  _buildOkActionButton() {
    return Expanded(
      child: ThemeGradientButton(
        text: "立即升级",
        w: 200.w,
        h: 75.w,
        fontsize: 28.sp,
        radius: 20,
        fillColor: Colors.transparent,
        highlighted: false,
        fontColor: Theme.of(context).hoverColor,
        fontWeight: FontWeight.w700,
        ontap: () {
          _clickOk();
        },
      ),
    );
  }

  /// 下载进度widget
  Widget _buildDownloadProgress() {
    return widget.progressBar ??
        LiquidLinearProgressIndicator(
          value: _downloadProgress,
          direction: Axis.vertical,
          valueColor: AlwaysStoppedAnimation(widget.progressBarColor ??
              Theme.of(context).primaryColor.withOpacity(0.4)),
          borderRadius: widget.borderRadius!,
        );
  }

  ///
  /// 点击确定按钮
  ///
  _clickOk() async {
    if (PlatformUtils.isIOS) {
      ///ios 需要跳转到app store更新，原生实现
      UpgradePlugin.toAppStore(widget.downloadUrl!.isNotEmpty
          ? widget.downloadUrl!
          : widget.iosAppId!);
      return;
    }
    if (isHttpApk(widget.downloadUrl, context)) {
      String path = await UpgradePlugin.apkDownloadPath;
      _downloadApk(widget.downloadUrl, '$path/$_downloadApkName');
    } else {
      await launchUrl(Uri.parse(widget.downloadUrl!));
      // ToNativeMethodChnagel.skipBrowser(widget.downloadUrl!);
    }
  }

  ///
  /// 下载apk包
  ///
  _downloadApk(String? url, String path) async {
    if (_downloadStatus == DownloadStatus.start ||
        _downloadStatus == DownloadStatus.downloading ||
        _downloadStatus == DownloadStatus.done) {
      print('当前下载状态：$_downloadStatus,不能重复下载。');
      ToastExit.show('下载中，请勿重复操作！');
      return;
    }

    _updateDownloadStatus(DownloadStatus.start);
    try {
      var dio = Dio();
      await dio.download(url!, path, onReceiveProgress: (int count, int total) {
        if (total == -1) {
          _downloadProgress = 0.01;
        } else {
          widget.downloadProgress?.call(count, total);
          _downloadProgress = count / total.toDouble();
          downloadCount = 100 * count ~/ total;
        }
        setState(() {
          isShow = true;
        });
        if (_downloadProgress == 1) {
          //下载完成，跳转到程序安装界面
          _updateDownloadStatus(DownloadStatus.done);
          Navigator.pop(context);
          UpgradePlugin.installAppForAndroid(path);
        }
      });
    } catch (e) {
      isShow = false;
      print('$e');
      _downloadProgress = 0;
      _updateDownloadStatus(DownloadStatus.error, error: e);
    }
  }

  _updateDownloadStatus(DownloadStatus downloadStatus, {dynamic error}) {
    _downloadStatus = downloadStatus;
    widget.downloadStatusChange?.call(_downloadStatus, error: error);
  }

  isHttpApk(String? content, BuildContext context) {
    if (content!.endsWith('.apk')) {
      return true;
    } else {
      return false;
    }
  }
}
