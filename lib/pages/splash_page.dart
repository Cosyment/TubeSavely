import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shimmer/shimmer.dart';
import 'package:tubesavely/app_theme.dart';

import '../main.dart';

class SplashPage extends StatefulWidget {
  static ui.FragmentShader? shader;

  const SplashPage({super.key});

  @override
  State<StatefulWidget> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> with SingleTickerProviderStateMixin {
  @override
  void initState() {
    super.initState();
    _mockCheckForSession().then((status) {
      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (BuildContext context) => const MainPage()));
    });
  }

  Future<bool> _mockCheckForSession() async {
    await Future.delayed(const Duration(milliseconds: 2400), () {});
    return true;
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
        const SystemUiOverlayStyle(systemNavigationBarColor: Color(0XFF26242e), statusBarColor: Colors.transparent));
    return Scaffold(
      backgroundColor: const Color(0XFF26242e),
      body: Stack(
        alignment: Alignment.center,
        children: [
          Center(
            child: Stack(alignment: Alignment.center, children: [
              Positioned(
                  child: Shimmer.fromColors(
                period: const Duration(milliseconds: 1000),
                baseColor: AppTheme.accentColor,
                highlightColor: const Color(0xFFFFFFFF),
                child: Image.asset(
                  'assets/ic_logo_small.webp',
                  width: 255,
                  height: 255,
                ),
              )),
              Positioned(
                top: 180,
                child: Shimmer.fromColors(
                  period: const Duration(milliseconds: 1000),
                  baseColor: const Color(0xFFFFFFFF),
                  highlightColor: AppTheme.accentColor,
                  child: Container(
                    alignment: Alignment.center,
                    child: Text(
                      "TubeSavely",
                      style: TextStyle(fontSize: 36.0, shadows: <Shadow>[
                        Shadow(blurRadius: 18.0, color: Colors.black87, offset: Offset.fromDirection(120, 12))
                      ]),
                    ),
                  ),
                )
                    .animate()
                    .effect(delay: 750.ms, duration: 1500.ms) // this "pads out" the total duration
                    .shader(shader: SplashPage.shader),
              )
            ]),
          ).animate().slideY(duration: 800.ms, curve: Curves.easeInQuad, begin: 0, end: -0.25).fadeIn(),
          const Positioned(
            bottom: 60,
            child: Text(
              "Supports 1800+ websites",
              style: TextStyle(color: Colors.white),
            ),
          )
        ],
      ),
    );
  }
}
