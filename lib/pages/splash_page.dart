import 'package:downloaderx/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:async';
import 'package:shimmer/shimmer.dart';
import 'package:flutter_animate/src/effects/shader_effect.dart';
import 'dart:ui' as ui;

class SplashPage extends StatefulWidget {
  static ui.FragmentShader? shader;

  const SplashPage({super.key});

  @override
  _SplashPageState createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage>
    with SingleTickerProviderStateMixin {
  @override
  void initState() {
    super.initState();
    _mockCheckForSession().then((status) {
      Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (BuildContext context) => MainPage()));
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<bool> _mockCheckForSession() async {
    await Future.delayed(Duration(milliseconds: 2400), () {});
    return true;
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
        const SystemUiOverlayStyle(statusBarColor: Colors.transparent));
    return Scaffold(
      backgroundColor: Color(0XFF26242e),
      body: Stack(
        alignment: Alignment.center,
        children: [
          Center(
            child: Stack(alignment: Alignment.center, children: [
              Positioned(
                  child: Shimmer.fromColors(
                period: Duration(milliseconds: 1000),
                baseColor: Color(0xFF8983F7),
                highlightColor: Color(0xFFA3DAFB),
                child: Container(
                  child: Image.asset(
                    'assets/ic_transparent_logo.png',
                    width: 255,
                    height: 255,
                  ),
                ),
              )),
              Positioned(
                top: 180,
                child: Shimmer.fromColors(
                  period: Duration(milliseconds: 1000),
                  baseColor: Color(0xFF8983F7),
                  highlightColor: Color(0xFFA3DAFB),
                  child: Container(
                    alignment: Alignment.center,
                    child: Text(
                      "TobeSaver",
                      style: TextStyle(fontSize: 36.0, shadows: <Shadow>[
                        Shadow(
                            blurRadius: 18.0,
                            color: Colors.black87,
                            offset: Offset.fromDirection(120, 12))
                      ]),
                    ),
                  ),
                )
                    .animate()
                    .effect(delay: 750.ms, duration: 1500.ms)// this "pads out" the total duration
                    .shader(shader: SplashPage.shader),
              )
            ]),
          )
              .animate()
              .slideY(
                  duration: 800.ms,
                  curve: Curves.easeInQuad,
                  begin: 0,
                  end: -0.25)
              .fadeIn(),
          const Positioned(
            bottom: 60,
            child: Text("创作高质量视频",style: TextStyle(color: Colors.white),),
          )
        ],
      ),
    );
  }
}
