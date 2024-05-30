import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:tubesavely/pages/webview.dart';

import '../theme/app_theme.dart';
import '../utils/constants.dart';

class MorePage extends StatefulWidget {
  const MorePage({super.key});

  @override
  State<MorePage> createState() => _MorePageState();
}

class _MorePageState extends State<MorePage> {
  var versionName = "";

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
    var brightness = MediaQuery.of(context).platformBrightness;
    bool isLightMode = brightness == Brightness.light;
    return Container(
        color: isLightMode ? AppTheme.nearlyWhite : AppTheme.nearlyBlack,
        child: SafeArea(
            top: false,
            bottom: false,
            child: Scaffold(
              appBar: AppBar(
                leading: const SizedBox(width: 50),
                backgroundColor: isLightMode ? AppTheme.nearlyWhite : AppTheme.nearlyBlack,
                title: Text(
                  'More',
                  style: TextStyle(color: isLightMode ? AppTheme.nearlyBlack : AppTheme.white),
                ),
              ),
              backgroundColor: isLightMode ? AppTheme.white : AppTheme.nearlyBlack,
              body: Container(
                margin: const EdgeInsets.fromLTRB(0, 40, 0, 0),
                child: Column(
                  children: [
                    InkWell(
                      child: _buildItem(Icons.privacy_tip, "Privacy Policy", 2),
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const WebViewPage(
                                title: 'Privacy Policy',
                                url: Constants.privacyUrl,
                              ),
                            ));
                      },
                    ),
                    const Divider(),
                    InkWell(
                      child: _buildItem(Icons.verified, "Version", 0),
                      onTap: () {},
                    )
                  ],
                ),
              ),
            )));
  }

  Widget _buildItem(IconData icon, String title, int type) {
    return Container(
      height: 50,
      padding: EdgeInsets.fromLTRB(30.w, 0, 30.w, 0),
      width: double.infinity,
      color: Colors.transparent,
      child: Row(
        children: [
          // Image(image: image),
          Icon(
            icon,
            color: Colors.grey,
          ),
          SizedBox(
            width: 30.w,
          ),
          Text(
            title,
            style: const TextStyle(color: Colors.grey, fontSize: 18),
          ),
          Flexible(
            flex: 1,
            child: Container(),
          ),
          type == 0
              ? Text(
                  versionName,
                  style: const TextStyle(color: Colors.grey),
                )
              : const Icon(
                  Icons.arrow_forward,
                  color: Colors.grey,
                ),
        ],
      ),
    );
  }
}
