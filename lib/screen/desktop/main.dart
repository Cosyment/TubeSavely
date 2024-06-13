import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:tubesavely/screen/desktop/pages/home_page.dart';

class DesktopApp extends StatefulWidget {
  const DesktopApp({super.key});

  @override
  State<StatefulWidget> createState() => _DesktopAppState();
}

class _DesktopAppState extends State<DesktopApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      color: Colors.black,
      // builder: (BuildContext context, Widget? child) {
      //   return const HomePage();
      // },
      builder: EasyLoading.init(),
      home: const HomePage(),
    );
  }
}
