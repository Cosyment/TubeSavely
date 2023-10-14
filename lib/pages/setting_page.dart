import 'package:downloaderx/constants/constant.dart';
import 'package:downloaderx/pages/home_page.dart';
import 'package:downloaderx/pages/login_page.dart';
import 'package:downloaderx/pages/webview.dart';
import 'package:downloaderx/utils/exit.dart';
import 'package:downloaderx/widget/confirm_dialog.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../constants/colors.dart';

class SettingPage extends StatefulWidget {
  const SettingPage({super.key});

  @override
  State<SettingPage> createState() => _SettingPageState();
}

List<dynamic> itemList = [
  {
    "icon": Icons.verified,
    "title": "版本信息",
    "type": 0,
  },
  {
    "icon": Icons.account_box,
    "title": "用户协议",
    "type": 1,
  },
  {
    "icon": Icons.privacy_tip,
    "title": "隐私政策",
    "type": 2,
  },
  {
    "icon": Icons.logout,
    "title": "退出登录",
    "type": 3,
  },
];
var versionName = "";

class _SettingPageState extends State<SettingPage> {
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("设置"),
      ),
      body: Container(
        margin: EdgeInsets.fromLTRB(0, 40.w, 0, 0),
        child: Column(
          children: List.generate(itemList.length, (index) {
            var item = itemList[index];
            return Card(
              elevation: 5,
              margin: EdgeInsets.fromLTRB(40.w, 30.w, 40.w, 0),
              shadowColor: primaryColor,
              child: InkWell(
                onTap: () {
                  onItemClick(item['type']);
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
                      // Image(image: image),
                      Icon(
                        item['icon'],
                        color: Colors.white,
                      ),
                      SizedBox(
                        width: 30.w,
                      ),
                      Text(
                        item['title'],
                        style: TextStyle(color: Colors.white),
                      ),
                      Flexible(
                        flex: 1,
                        child: Container(),
                      ),
                      Visibility(
                        visible: item['type'] == 0,
                        child: Text(
                          versionName,
                          style: TextStyle(color: Colors.white),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }

  void onItemClick(int type) async {
    if (type == 0) {
      ToastExit.show("已是最新版本!");
    } else if (type == 1) {
      Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => WebViewPage(
              title: '用户协议',
              url: Constant.agreementUrl,
            ),
          ));
    } else if (type == 2) {
      Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => WebViewPage(
              title: '隐私政策',
              url: Constant.privacyUrl,
            ),
          ));
    } else if (type == 3) {
      showCupertinoDialog(
        barrierDismissible: true,
        context: context,
        builder: (context) {
          return CupertinoAlertDialog(
            title: Text("提示"),
            content: Text("确认退出吗？"),
            actions: [
              CupertinoDialogAction(
                child: const Text("取消"),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              CupertinoDialogAction(
                child: const Text("确定"),
                onPressed: () {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => HomePage()),
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
