import 'package:downloaderx/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:async';
import 'package:shimmer/shimmer.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  _SplashPageState createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _translationAnimationController;
  late Animation<Offset> _offsetAnimation;
  bool isShowTitle = false;

  @override
  void initState() {
    super.initState();
    // 创建动画控制器
    _translationAnimationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 900),
    );
    _offsetAnimation = Tween<Offset>(
      begin: const Offset(0, 0),
      end: const Offset(0, -200),
    ).animate(_translationAnimationController);
    _translationAnimationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() {
          isShowTitle = true;
        });
      }
    });

    _translationAnimationController.forward();
    _mockCheckForSession().then((status) {
      Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (BuildContext context) => MainPage()));
    });
  }

  @override
  void dispose() {
    _translationAnimationController.dispose();
    super.dispose();
  }

  Future<bool> _mockCheckForSession() async {
    await Future.delayed(Duration(milliseconds: 2500), () {});
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
          AnimatedBuilder(
            animation: _translationAnimationController,
            builder: (context, child) {
              return Transform.translate(
                offset: _offsetAnimation.value,
                child: Center(
                  child: Stack(alignment: Alignment.center, children: [
                    Positioned(
                      child: isShowTitle
                          ? Shimmer.fromColors(
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
                            )
                          : Image.asset(
                              'assets/ic_transparent_logo.png',
                              width: 255,
                              height: 255,
                            ),
                    ),
                    Positioned(
                      top: 180,
                      child: Visibility(
                        visible: isShowTitle,
                        child: Shimmer.fromColors(
                          period: Duration(milliseconds: 1000),
                          baseColor: Color(0xFF8983F7),
                          highlightColor: Color(0xFFA3DAFB),
                          child: Container(
                            alignment: Alignment.center,
                            child: Text(
                              "TobeSaver",
                              style:
                                  TextStyle(fontSize: 36.0, shadows: <Shadow>[
                                Shadow(
                                    blurRadius: 18.0,
                                    color: Colors.black87,
                                    offset: Offset.fromDirection(120, 12))
                              ]),
                            ).animate().fade(),
                          ),
                        ),
                      ),
                    )
                  ]),
                ),
              );
            },
          ),
          Positioned(
            child: Text("创作高质量视频"),
            bottom: 60,
          )
        ],
      ),
    );
  }
}
