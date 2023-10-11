import 'package:downloaderx/constants/constant.dart';
import 'package:downloaderx/pages/webview.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../constants/colors.dart';

class SettingPage extends StatefulWidget {
  const SettingPage({super.key});

  @override
  State<SettingPage> createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("设置"),
      ),
      body: Container(
        child: Column(
          children: [
            Card(
              elevation: 5,
              margin: EdgeInsets.fromLTRB(30.w, 30.w, 30.w, 0),
              shadowColor: primaryColor,
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => WebViewPage(
                          title: '用户协议',
                          url: Constant.agreementUrl,
                        ),
                      ));
                },
                child: Container(
                  height: 100.w,
                  padding: EdgeInsets.fromLTRB(30.w, 0, 30.w, 0),
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: primaryColor.withAlpha(200),
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.account_box_outlined,
                        color: Colors.white,
                      ),
                      SizedBox(
                        width: 30.w,
                      ),
                      const Text(
                        "用户协议",
                        style: TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Card(
              elevation: 5,
              margin: EdgeInsets.fromLTRB(30.w, 30.w, 30.w, 0),
              shadowColor: primaryColor,
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => WebViewPage(
                          title: '隐私政策',
                          url: Constant.privacyUrl,
                        ),
                      ));
                },
                child: Container(
                  height: 100.w,
                  padding: EdgeInsets.fromLTRB(30.w, 0, 30.w, 0),
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: primaryColor.withAlpha(200),
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.privacy_tip,
                        color: Colors.white,
                      ),
                      SizedBox(
                        width: 30.w,
                      ),
                      const Text(
                        "隐私协议",
                        style: TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
