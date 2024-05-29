import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../theme/app_theme.dart';

class WebViewPage extends StatefulWidget {
  const WebViewPage({super.key, required this.title, required this.url});

  final String title;
  final String url;

  @override
  State<WebViewPage> createState() => _WebViewState();
}

double linearProgress = 0.0;

class _WebViewState extends State<WebViewPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var brightness = MediaQuery.of(context).platformBrightness;
    bool isLightMode = brightness == Brightness.light;
    late final PlatformWebViewControllerCreationParams params;
    final WebViewController controller =
        WebViewController.fromPlatformCreationParams(const PlatformWebViewControllerCreationParams());
    controller
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(isLightMode ? AppTheme.nearlyWhite : AppTheme.nearlyBlack)
      ..setNavigationDelegate(NavigationDelegate(onProgress: (int progress) {
        linearProgress = progress / 100.0;
      }))
      ..loadRequest(Uri.parse(widget.url));
    return Container(
        color: isLightMode ? AppTheme.nearlyWhite : AppTheme.nearlyBlack,
        child: SafeArea(
            top: false,
            child: Scaffold(
              appBar: AppBar(
                leading: BackButton(
                  color: isLightMode ? Colors.black : Colors.white,
                  onPressed: () {
                    // 执行返回操作
                    Navigator.of(context).pop();
                  },
                ),
                backgroundColor: isLightMode ? AppTheme.nearlyWhite : AppTheme.nearlyBlack,
                title: Text(
                  widget.title,
                  style: TextStyle(color: isLightMode ? AppTheme.nearlyBlack : AppTheme.white),
                ),
              ),
              backgroundColor: isLightMode ? AppTheme.nearlyWhite : AppTheme.nearlyBlack,
              body: Stack(children: [
                LinearProgressIndicator(
                  backgroundColor: AppTheme.grey,
                  color: AppTheme.accentColor,
                  minHeight: 1,
                  valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.accentColor),
                  value: linearProgress,
                ),
                WebViewWidget(controller: controller)
              ]),
            )));
  }
}
