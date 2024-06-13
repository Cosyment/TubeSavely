import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
        child: Container(
      // width: 450,
      // padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const SizedBox(width: 150, height: 100, child: Image(image: AssetImage('assets/ic_logo.png'))),
          const Text(
            'TubeSavely',
            style: TextStyle(fontSize: 20),
          ),
          FutureBuilder<PackageInfo>(
              future: PackageInfo.fromPlatform(),
              builder: (context, snapshot) {
                return Text(
                  'Version ${snapshot.data?.version}',
                  style: const TextStyle(fontSize: 12, color: Colors.black45),
                );
              }),
          const SizedBox(height: 10),
          const Text(
            '这是App介绍，很长的一段介绍这是App介绍，很长的一段介绍这是App介绍，很长的一段介绍这是App介绍，很长的一段介绍这是App介绍，很长的一段介绍这是App介绍，很长的一段介绍这是App介绍，很长的一段介绍这是App介绍，很长的一段介绍这是App介绍，很长的一段介绍这是App介绍，很长的一段介绍这是App介绍，很长的一段介绍这是App介绍，很长的一段介绍这是App介绍，很长的一段介绍这是App介绍，很长的一段介绍',
            style: TextStyle(fontSize: 12, color: Colors.black45),
          ),
          const SizedBox(height: 5),
          const Text(
            'Copyright © 2023 TubeSavely. All rights reserved.',
            style: TextStyle(fontSize: 10),
          ),
        ],
      ),
    ));
  }
}
