import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tubesavely/pages/webview.dart';
import 'package:tubesavely/utils/constants.dart';

import '../app_theme.dart';
import '../main.dart';

class MorePage extends StatefulWidget {
  const MorePage({super.key});

  @override
  State<MorePage> createState() => _MorePageState();
}

class _MorePageState extends State<MorePage> {
  List itemList = [
    {
      "icon": Icons.verified,
      "title": "Version",
      "type": 0,
    },
    {
      "icon": Icons.account_box,
      "title": "User Agreement",
      "type": 1,
    },
    {
      "icon": Icons.privacy_tip,
      "title": "Privacy Policy",
      "type": 2,
    },
    {
      "icon": Icons.info,
      "title": "About",
      "type": 2,
    },
  ];

  var versionName = "";
  var userId = "";

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      PackageInfo.fromPlatform().then((value) {
        setState(() {
          versionName = value.version;
        });
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var brightness = MediaQuery.of(context).platformBrightness;
    bool isLightMode = brightness == Brightness.light;
    return Container(
        color: isLightMode ? AppTheme.nearlyWhite : AppTheme.nearlyBlack,
        child: SafeArea(
            top: false,
            bottom: false,
            child: Scaffold(
              appBar: AppBar(
                leading: const Spacer(),
                backgroundColor: isLightMode ? AppTheme.nearlyWhite : AppTheme.nearlyBlack,
                title: Text(
                  'More',
                  style: TextStyle(color: isLightMode ? AppTheme.nearlyBlack : AppTheme.white),
                ),
              ),
              backgroundColor: isLightMode ? AppTheme.white : AppTheme.nearlyBlack,
              body: Container(
                margin: EdgeInsets.fromLTRB(0, 40.w, 0, 0),
                child: Column(
                  children: List.generate(itemList.length, (index) {
                    var item = itemList[index];
                    return GestureDetector(
                      onTap: () {
                        onItemClick(item['type']);
                      },
                      child: Container(
                        height: 100.w,
                        padding: EdgeInsets.fromLTRB(30.w, 0, 30.w, 0),
                        width: double.infinity,
                        color: Colors.transparent,
                        child: Row(
                          children: [
                            // Image(image: image),
                            Icon(
                              item['icon'],
                              color: Colors.grey,
                            ),
                            SizedBox(
                              width: 30.w,
                            ),
                            Text(
                              item['title'],
                              style: TextStyle(color: isLightMode ? AppTheme.nearlyBlack : AppTheme.nearlyWhite, fontSize: 18),
                            ),
                            Flexible(
                              flex: 1,
                              child: Container(),
                            ),
                            item['type'] == 0
                                ? Text(
                                    versionName,
                                    style: TextStyle(color: isLightMode ? AppTheme.nearlyBlack : AppTheme.nearlyWhite),
                                  )
                                : Icon(
                                    Icons.arrow_forward,
                                    color: isLightMode ? AppTheme.nearlyBlack : AppTheme.nearlyWhite,
                                  ),
                          ],
                        ),
                      ),
                    );
                  }),
                ),
              ),
            )));
  }

  void onItemClick(int type) async {
    if (type == 0) {
    } else if (type == 1) {
      Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const WebViewPage(
              title: 'User Agreement',
              url: Constants.agreementUrl,
            ),
          ));
    } else if (type == 2) {
      Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const WebViewPage(
              title: 'Privacy Policy',
              url: Constants.privacyUrl,
            ),
          ));
    } else if (type == 3 || type == 4) {
      showCupertinoDialog(
        barrierDismissible: true,
        context: context,
        builder: (context) {
          return CupertinoAlertDialog(
            title: const Text("提示"),
            content: Text("确认${type == 3 ? '注销' : '退出'}吗？"),
            actions: [
              CupertinoDialogAction(
                child: const Text("取消"),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              CupertinoDialogAction(
                child: const Text("确定"),
                onPressed: () async {
                  var sharedPreferences = await SharedPreferences.getInstance();
                  sharedPreferences.remove("userId");
                  // Navigator.popUntil(context, ModalRoute.withName('/'));
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => const MainPage()),
                    (Route<dynamic> route) => false,
                  );
                },
              ),
            ],
          );
        },
      );
    }
  }

  void onRightClick() {}
}
