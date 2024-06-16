import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    var brightness = MediaQuery.of(context).platformBrightness;
    bool isLightMode = brightness == Brightness.light;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(
            width: 100,
            height: 100,
            child: Image(
              image: AssetImage('assets/ic_logo.png'),
              fit: BoxFit.cover,
            )),
        Text(
          'TubeSavely',
          style: TextStyle(fontSize: 20, color: isLightMode ? Colors.black87 : Colors.white),
        ),
        FutureBuilder<PackageInfo>(
            future: PackageInfo.fromPlatform(),
            builder: (context, snapshot) {
              return Text(
                'Version ${snapshot.data?.version}',
                style: TextStyle(fontSize: 12, color: isLightMode ? Colors.black54 : Colors.grey),
              );
            }),
        const SizedBox(height: 10),
        Text(
          '这是App介绍，很长的一段介绍这是App介绍，很长的一段介绍这是App介绍，很长的一段介绍这是App介绍，很长的一段介绍这是App介绍，很长的一段介绍这是App介绍，很长的一段介绍这是App介绍，很长的一段介绍这是App介绍，很长的一段介绍这是App介绍，很长的一段介绍这是App介绍，很长的一段介绍这是App介绍，很长的一段介绍这是App介绍，很长的一段介绍这是App介绍，很长的一段介绍这是App介绍，很长的一段介绍',
          style: TextStyle(fontSize: 12, color: isLightMode ? Colors.black45 : Colors.grey.shade600),
        ),
        const SizedBox(height: 5),
        Text(
          'Copyright © 2023 TubeSavely. All rights reserved.',
          style: TextStyle(fontSize: 10, color: isLightMode ? Colors.black54 : Colors.grey),
        ),
      ],
    );
  }
}
