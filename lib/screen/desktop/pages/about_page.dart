import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:tubesavely/generated/l10n.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
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
          S.current.appName,
          style: TextStyle(fontSize: 20, color: Theme.of(context).colorScheme.onSurface),
        ),
        FutureBuilder<PackageInfo>(
            future: PackageInfo.fromPlatform(),
            builder: (context, snapshot) {
              return Text(
                'Version ${snapshot.data?.version}',
                style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6)),
              );
            }),
        const SizedBox(height: 10),
        Text(
          S.current.summary,
          style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.4)),
        ),
        const SizedBox(height: 5),
        Text(
          S.current.copyright,
          style: TextStyle(fontSize: 10, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6)),
        ),
      ],
    );
  }
}
