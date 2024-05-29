import 'dart:io';

import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:tubesavely/theme/app_theme.dart';
import 'package:url_launcher/url_launcher_string.dart';

class FeedbackPage extends StatefulWidget {
  const FeedbackPage({super.key});

  @override
  State<FeedbackPage> createState() => _FeedbackPageState();
}

class _FeedbackPageState extends State<FeedbackPage> {
  TextEditingController textController = TextEditingController(text: '');

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var brightness = MediaQuery.of(context).platformBrightness;
    bool isLightMode = brightness == Brightness.light;
    return Container(
      color: isLightMode ? AppTheme.nearlyWhite : AppTheme.nearlyBlack,
      child: SafeArea(
        top: false,
        child: Scaffold(
          appBar: AppBar(
            leading: const SizedBox(width: 50),
            backgroundColor: isLightMode ? AppTheme.nearlyWhite : AppTheme.nearlyBlack,
            title: Text(
              'Feedback',
              style: TextStyle(color: isLightMode ? AppTheme.nearlyBlack : AppTheme.white),
            ),
          ),
          backgroundColor: isLightMode ? AppTheme.nearlyWhite : AppTheme.nearlyBlack,
          body: SingleChildScrollView(
            child: SizedBox(
              height: MediaQuery.of(context).size.height,
              child: Column(
                children: <Widget>[
                  Container(
                    padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top, left: 16, right: 16),
                    child: Image.asset('assets/images/ic_feedback.png'),
                  ),
                  Container(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      'Your FeedBack',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: isLightMode ? Colors.black : Colors.white),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.only(top: 16),
                    child: Text(
                      'Give your best time for this moment.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16, color: isLightMode ? Colors.black : Colors.white),
                    ),
                  ),
                  _buildComposer(),
                  Padding(
                    padding: const EdgeInsets.only(top: 16, left: 30, right: 30),
                    child: Center(
                      child: Container(
                        height: 40,
                        decoration: BoxDecoration(
                          color: AppTheme.accentColor,
                          borderRadius: const BorderRadius.all(Radius.circular(50)),
                          boxShadow: <BoxShadow>[
                            BoxShadow(color: Colors.grey.withOpacity(0.6), offset: const Offset(4, 4), blurRadius: 8.0),
                          ],
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () {
                              // FocusScope.of(context).requestFocus(FocusNode());
                              _sendMail();
                            },
                            child: const Center(
                              child: Padding(
                                padding: EdgeInsets.all(4.0),
                                child: Text(
                                  'Send',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildComposer() {
    return Padding(
      padding: const EdgeInsets.only(top: 16, left: 32, right: 32),
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: <BoxShadow>[
            BoxShadow(color: Colors.grey.withOpacity(0.8), offset: const Offset(4, 4), blurRadius: 8),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(25),
          child: Container(
            padding: const EdgeInsets.all(4.0),
            constraints: const BoxConstraints(minHeight: 80, maxHeight: 160),
            color: AppTheme.white,
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(left: 10, right: 10, top: 0, bottom: 0),
              child: TextField(
                maxLines: null,
                controller: textController,
                onChanged: (String txt) {},
                style: const TextStyle(
                  fontFamily: AppTheme.fontName,
                  fontSize: 16,
                  color: AppTheme.dark_grey,
                ),
                cursorColor: AppTheme.accentColor,
                decoration: const InputDecoration(border: InputBorder.none, hintText: 'Enter your feedback...'),
              ),
            ),
          ),
        ),
      ),
    );
  }

  _sendMail() async {
    String subject = 'TubaSavely';
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    String body = 'Platform: ${Platform.operatingSystem}%0D%0A'
            'Version: ${packageInfo.version}%0D%0A'
            'PlatformVersion: ${Platform.operatingSystemVersion}%0D%0A'
            'Language: ${Platform.localeName}%0D%0A'
            'BuildNumber: ${packageInfo.buildNumber}%0D%0A'
            'CreateTime: ${HttpDate.format(DateTime.timestamp())}%0D%0A'
        // 'Content: ${textController.text}%0D%0A'
        .replaceAll(' ', '%20');
    String url = 'mailto:waitinghc@gmail.com?body=$body&subject=$subject';
    await launchUrlString(url);
  }
}
