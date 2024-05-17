import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../theme/colors.dart';

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
    late final PlatformWebViewControllerCreationParams params;
    final WebViewController controller =
        WebViewController.fromPlatformCreationParams(const PlatformWebViewControllerCreationParams());
    controller
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.white)
      ..setNavigationDelegate(NavigationDelegate(onProgress: (int progress) {
        linearProgress = progress / 100.0;
      }))
      ..loadRequest(Uri.parse(widget.url));
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: Text(widget.title),
      ),
      body: Stack(children: [
        LinearProgressIndicator(
          backgroundColor: primaryColor,
          color: primaryColor,
          minHeight: 1,
          valueColor: const AlwaysStoppedAnimation<Color>(progressColor),
          value: linearProgress,
        ),
        WebViewWidget(controller: controller)
      ]),
    );
  }
}
