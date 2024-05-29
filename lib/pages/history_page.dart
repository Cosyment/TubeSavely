import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<StatefulWidget> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  @override
  void initState() {
    super.initState();
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
                  'History',
                  style: TextStyle(color: isLightMode ? AppTheme.nearlyBlack : AppTheme.white),
                ),
              ),
              backgroundColor: isLightMode ? AppTheme.white : AppTheme.nearlyBlack,
              body: Center(
                child: Image.asset('assets/images/ic_empty.png'),
              ),
            )));
  }
}
