import 'package:downloaderx/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'package:shimmer/shimmer.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  _SplashPageState createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage>   with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _jumpAnimation;
  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 1000),
    );
    _jumpAnimation = Tween<double>(begin: 0, end: 30).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOut,
      ),
    );
    _animationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _animationController.reverse();
      } else if (status == AnimationStatus.dismissed) {
        _animationController.forward();
      }
    });
    _animationController.forward();
    _mockCheckForSession().then((status) {
      Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (BuildContext context) => MainPage()));
    });
  }
  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
  Future<bool> _mockCheckForSession() async {
    await Future.delayed(Duration(milliseconds: 6000), () {});
    return true;
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
        const SystemUiOverlayStyle(statusBarColor: Colors.transparent));
    return Scaffold(
      backgroundColor: Color(0XFF26242e),
      body: Stack(children: [
        Positioned(
            child: Center(
          child: Shimmer.fromColors(
      period: Duration(milliseconds: 1500),
      baseColor: Color(0xFF8983F7),
      highlightColor: Color(0xFFA3DAFB),
      child: Container(
        alignment: Alignment.center,
        child:AnimatedBuilder(
          animation: _jumpAnimation,
          builder: (context, child) {
            return Container(
              margin: EdgeInsets.only(bottom: _jumpAnimation.value),
              child: Image.asset(
                'assets/ic_transparent_logo.png',
                width: 255,
                height: 255,
              ),
            );
          },
        ),
      ),
    )
        )),
        Positioned(
          top: 280,
            left: 0,
            right: 0,
            child: Shimmer.fromColors(
          period: Duration(milliseconds: 1500),
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
        ))
      ]),
    );
  }
}
