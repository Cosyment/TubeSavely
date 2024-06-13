import 'package:flutter/material.dart';

class SettingPage extends StatefulWidget {
  const SettingPage({super.key});

  @override
  State<StatefulWidget> createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  @override
  Widget build(BuildContext context) {
    return Center(
        child: const Column(
      children: [
        Row(
          children: [Text('Theme')],
        ),
        Row(
          children: [Text('Download Path')],
        ),
        Row(
          children: [Text('language')],
        ),
        Row(
          children: [Text('retry count')],
        ),
        Row(
          children: [Text('youtube merge audio')],
        ),
        Row(
          children: [Text('Privacy Policy')],
        ),
        Row(
          children: [Text('About')],
        ),
      ],
    ));
  }
}
