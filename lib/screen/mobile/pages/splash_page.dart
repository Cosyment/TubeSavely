import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shimmer/shimmer.dart';
import 'package:tubesavely/main.dart';
import 'package:tubesavely/screen/mobile/pages/home_page.dart';
import 'package:tubesavely/theme/app_theme.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<StatefulWidget> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> with SingleTickerProviderStateMixin {
  @override
  void initState() {
    super.initState();
    _mockCheckForSession().then((status) {
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          transitionDuration: const Duration(milliseconds: 300),
          pageBuilder: (BuildContext context, _, __) => const MainPage(),
          transitionsBuilder:
              (BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation, Widget child) {
            return FadeTransition(
              opacity: Tween<double>(
                begin: 0,
                end: 1, // 结束位置在屏幕原点
              ).animate(animation),
              child: child,
            );
          },
        ),
      );
    });
  }

  Future<bool> _mockCheckForSession() async {
    await Future.delayed(const Duration(milliseconds: 3400), () {});
    return true;
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
        const SystemUiOverlayStyle(systemNavigationBarColor: Color(0XFF26242e), statusBarColor: Colors.transparent));

    var brightness = MediaQuery.of(context).platformBrightness;
    bool isLightMode = brightness == Brightness.light;
    return Scaffold(
      backgroundColor: isLightMode ? AppTheme.nearlyWhite : AppTheme.nearlyBlack,
      body: Stack(
        alignment: Alignment.center,
        children: [
          Center(
            child: Stack(alignment: Alignment.center, children: [
              Positioned(
                  child: Shimmer.fromColors(
                period: const Duration(milliseconds: 1000),
                baseColor: AppTheme.accentColor,
                highlightColor: Colors.white,
                child: Image.asset(
                  'assets/ic_logo_small.webp',
                  width: 255,
                  height: 255,
                ),
              )),
              Positioned(
                top: 180,
                child: FutureBuilder<FragmentShader>(
                  builder: (context, snapshot) {
                    return Shimmer.fromColors(
                      period: const Duration(milliseconds: 1000),
                      baseColor: Colors.white,
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
                        .shader(shader: snapshot.data);
                  },
                  future: FragmentProgram.fromAsset('assets/shaders/shader.frag').then((FragmentProgram prgm) {
                    return prgm.fragmentShader();
                  }),
                ),
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
