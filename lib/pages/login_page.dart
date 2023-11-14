import 'dart:async';

import 'package:downloaderx/network/http_api.dart';
import 'package:downloaderx/utils/exit.dart';
import 'package:downloaderx/utils/pub_method.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

import '../constants/colors.dart';
import '../constants/constant.dart';
import '../network/http_utils.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  late TextEditingController emailController;
  late TextEditingController codeController;

  var isLoading = false;

  @override
  void initState() {
    super.initState();
    emailController = TextEditingController(text: "");
    codeController = TextEditingController(text: "");
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context, designSize: const Size(750, 1378));
    return Scaffold(
      appBar: AppBar(
        title: Text("Login"),
      ),
      body: Container(
        width: double.infinity,
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: 60.w,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: 120.w),
              Text(
                "Your Email Address",
                style: TextStyle(
                  fontSize: 32.sp,
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(height: 20.w),
              Text(
                "Please confirm your email \nand enter  your code",
                style: TextStyle(fontSize: 28.sp),
              ),
              Container(
                height: 88.h,
                margin: EdgeInsets.symmetric(vertical: 40.h),
                child: TextField(
                  controller: emailController,
                  autofocus: true,
                  keyboardType: TextInputType.emailAddress,
                  inputFormatters: <TextInputFormatter>[
                    LengthLimitingTextInputFormatter(30)
                  ],
                  style: TextStyle( fontSize: 28.sp),
                  decoration: InputDecoration(
                    hintText: "Enter your email",
                    labelText: "Email",
                    hintStyle: TextStyle(
                      fontSize: 26.sp,
                      color: Colors.grey,
                    ),
                    labelStyle: TextStyle(fontSize: 26.sp, color: Colors.grey),
                    filled: true,
                    fillColor: Colors.transparent,
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(14.r)),
                      borderSide: BorderSide(
                        color: Theme.of(context).hintColor,
                        width: 3.w,
                      ),
                    ),
                    disabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(14.r)),
                      borderSide: BorderSide(
                        color: Theme.of(context).hintColor,
                        width: 3.w,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(14.r)),
                      borderSide: BorderSide(
                        color: Theme.of(context).highlightColor,
                        width: 4.w,
                      ),
                    ),
                  ),
                ),
              ),
              Stack(
                children: [
                  Container(
                    height: 88.h,
                    child: TextField(
                      controller: codeController,
                      keyboardType: TextInputType.number,
                      inputFormatters: <TextInputFormatter>[
                        LengthLimitingTextInputFormatter(16)
                      ],
                      style: TextStyle( fontSize: 28.sp),
                      decoration: InputDecoration(
                        hintText: "Enter your code",
                        labelText: "Code",
                        hintStyle: TextStyle(
                          fontSize: 26.sp,
                          color: Colors.grey,
                        ),
                        labelStyle:
                            TextStyle(fontSize: 26.sp, color: Colors.grey),
                        filled: true,
                        fillColor: Colors.transparent,
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(14.r)),
                          borderSide: BorderSide(
                            color: Theme.of(context).hintColor,
                            width: 3.w,
                          ),
                        ),
                        disabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(14.r)),
                          borderSide: BorderSide(
                            color: Theme.of(context).hintColor,
                            width: 3.w,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(14.r)),
                          borderSide: BorderSide(
                            color: Theme.of(context).highlightColor,
                            width: 4.w,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    right: 25.w,
                    top: 0,
                    bottom: 0,
                    child: Row(
                      children: [
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 15),
                          child: VerticalDivider(
                            thickness: 1,
                          ),
                        ),
                        GestureDetector(
                          onTap: () async {
                            if (codeEnable) {
                              sendMsm();
                            }
                          },
                          child: Center(
                            child: Text(
                              _buttonText,
                              style: TextStyle(
                                fontSize: 26.sp,
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ],
              ),
              // SizedBox(height: 12.w),
              // Container(
              //   alignment: Alignment.centerRight,
              //   child: Text(
              //     "Forget password?",
              //     style: TextStyle(
              //       fontSize: 24.sp,
              //       color: primaryColor,
              //     ),
              //     textAlign: TextAlign.end,
              //   ),
              // ),
              SizedBox(height: 50.h),
              Align(
                alignment: Alignment.centerRight,
                child: FloatingActionButton(
                  backgroundColor: Theme.of(context).primaryColor,
                  shape: const CircleBorder(),
                  onPressed: () {
                    login();
                  },
                  child: isLoading
                      ? LoadingAnimationWidget.hexagonDots(
                          color: Colors.white,
                          size: 40.h,
                        )
                      : Image.asset(
                          "assets/next.png",
                          fit: BoxFit.fill,
                          width: 40.w,
                          height: 40.w,
                        ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  login() async {
    setState(() {
      isLoading = true;
    });
    var map = <String, dynamic>{};
    map['email'] = emailController.text;
    map['code'] = codeController.text;
    var data = await HttpUtils.instance
        .requestNetWorkAy(Method.post, HttpApi.login, queryParameters: map);
    if (data != null) {
      var userId = data['userId'];
      Constant.userId = userId;
      PubMethodUtils.putSharedPreferences("userId", userId);
      ToastExit.show("登录成功");
      Navigator.pop(context, userId);
    } else {
      setState(() {
        isLoading = false;
      });
    }
  }

  Timer? _t;
  int seconds = 60;
  String _buttonText = "Send VerCode";
  bool codeEnable = true;

  sendMsm() async {
    reset() {
      _t!.cancel();
      codeEnable = true;
      _buttonText = "Send VerCode";
      seconds = 60;
    }

    setState(() {
      codeEnable = false;
    });
    var map = <String, dynamic>{};
    map['email'] = emailController.text;
    var data = await HttpUtils.instance.requestNetWorkAy(
        Method.post, HttpApi.sendVerCode,
        queryParameters: map);
    if (data != null) {
      _t = Timer.periodic(Duration(seconds: 1), (timer) {
        setState(() {
          if (seconds == 1) {
            reset();
          } else {
            seconds--;
            _buttonText = "Resend($seconds)";
          }
        });
      });
    } else {
      setState(() {
        codeEnable = true;
      });
    }
  }

  @override
  void dispose() {
    super.dispose();
    if (_t != null) {
      _t!.cancel();
    }
  }
}
