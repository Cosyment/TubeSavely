import 'package:downloaderx/constants/colors.dart';
import 'package:downloaderx/constants/constant.dart';
import 'package:downloaderx/plugin/method_plugin.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../pages/webview.dart';

class AgreementDialog extends StatefulWidget {
  const AgreementDialog({
    Key? key,
    required this.onAgreeClick,
  }) : super(key: key);
  final Function onAgreeClick;

  @override
  AgreementDialogState createState() => AgreementDialogState();
}

class AgreementDialogState extends State<AgreementDialog> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Center(
        child: Container(
          constraints: const BoxConstraints(
            minWidth: 240,
            maxWidth: 260,
            minHeight: 260,
          ),
          decoration: BoxDecoration(
              color: Colors.white, borderRadius: BorderRadius.circular((8))),
          child: Padding(
            padding: EdgeInsets.all(15),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text("用户协议",
                    style: TextStyle(
                        color: primaryColor,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        decoration: TextDecoration.none)),
                Container(
                  margin: const EdgeInsets.only(top: 15, bottom: 15),
                  child: Wrap(
                    alignment: WrapAlignment.start,
                    children: [
                      const Text("主要用于智能AI绘画、写文章、查询问题、答题助手。在为您提供服务时，我们可能需要收集与使用您的帐户相关的信息、呼叫帐户服务、存储和读取电话状态和身份，以及一些网络信息和网络服务权限。我们承诺您的个人信息仅用于我们声明的目的。点击“同意”即表示您同意上述内容",
                          textScaleFactor: 1.1,
                          style: TextStyle(
                              color: Colors.black,
                              fontSize: 12,
                              fontWeight: FontWeight.normal,
                              decoration: TextDecoration.none)),
                      GestureDetector(
                        child: Text("《用户协议》",
                            style: const TextStyle(
                              color: primaryColor,
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              decoration: TextDecoration.underline,
                              decorationStyle: TextDecorationStyle.solid,
                              decorationColor: Colors.white30,
                              decorationThickness: 1,
                            )),
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
                      ),
                      const Text("和",
                          style: TextStyle(
                              color: primaryColor,
                              fontSize: 13,
                              fontWeight: FontWeight.normal,
                              decoration: TextDecoration.none)),
                      GestureDetector(
                        child: Text("《隐私政策》",
                            style: const TextStyle(
                              color: primaryColor,
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              decoration: TextDecoration.underline,
                              decorationStyle: TextDecorationStyle.solid,
                              decorationColor: Colors.white30,
                              decorationThickness: 1,
                            )),
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
                      )
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      Navigator.of(context, rootNavigator: true).pop();
                      widget.onAgreeClick();
                    });
                  },
                  child: Container(
                      width: 200,
                      height: 38,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular((45)),
                        color: const Color(0xff424042),
                      ),
                      child: const Text("同意",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              decoration: TextDecoration.none))),
                ),
                Container(
                    margin: const EdgeInsets.only(top: 15),
                    child: GestureDetector(
                      onTap: () {
                        SystemNavigator.pop(animated: true);
                      },
                      child: const Text("不同意",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: primaryColor,
                              fontSize: 14,
                              fontWeight: FontWeight.normal,
                              decoration: TextDecoration.none)),
                    ))
              ],
            ),
          ),
        ),
      ),
    );
  }
}
