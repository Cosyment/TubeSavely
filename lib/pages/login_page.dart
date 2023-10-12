import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

import '../constants/colors.dart';
import '../widget/primary_button.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  var isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("登录"),
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
                "Please confirm your email \nand enter  your password",
                style: TextStyle(fontSize: 28.sp, color: Colors.black87),
              ),
              Container(
                height: 88.h,
                margin: EdgeInsets.symmetric(vertical: 40.h),
                child: TextField(
                  autofocus: true,
                  keyboardType: TextInputType.emailAddress,
                  inputFormatters: <TextInputFormatter>[
                    LengthLimitingTextInputFormatter(16)
                  ],
                  style: TextStyle(color: primaryColor, fontSize: 28.sp),
                  decoration: InputDecoration(
                    hintText: "Enter your email",
                    labelText: "Email",
                    hintStyle: TextStyle(
                      fontSize: 26.sp,
                      color: Colors.grey,
                    ),
                    labelStyle: TextStyle(fontSize: 26.sp, color: Colors.grey),
                    filled: true,
                    fillColor: Colors.white,
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(14.r)),
                      borderSide: BorderSide(
                        color: Colors.grey,
                        width: 1.w,
                      ),
                    ),
                    disabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(14.r)),
                      borderSide: BorderSide(
                        color: primaryColor,
                        width: 1.w,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(14.r)),
                      borderSide: BorderSide(
                        color: primaryColor,
                        width: 4.w,
                      ),
                    ),
                  ),
                ),
              ),
              Container(
                height: 88.h,
                child: TextField(
                  keyboardType: TextInputType.visiblePassword,
                  inputFormatters: <TextInputFormatter>[
                    LengthLimitingTextInputFormatter(16)
                  ],
                  style: TextStyle(color: primaryColor, fontSize: 28.sp),
                  decoration: InputDecoration(
                    hintText: "Enter your password",
                    labelText: "Password",
                    hintStyle: TextStyle(
                      fontSize: 26.sp,
                      color: Colors.grey,
                    ),
                    labelStyle: TextStyle(fontSize: 26.sp, color: Colors.grey),
                    filled: true,
                    fillColor: Colors.white,
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(14.r)),
                      borderSide: BorderSide(
                        color: Colors.grey,
                        width: 1.w,
                      ),
                    ),
                    disabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(14.r)),
                      borderSide: BorderSide(
                        color: primaryColor,
                        width: 1.w,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(14.r)),
                      borderSide: BorderSide(
                        color: primaryColor,
                        width: 4.w,
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 12.w),
              Container(
                alignment: Alignment.centerRight,
                child: Text(
                  "Forget password?",
                  style: TextStyle(
                    fontSize: 24.sp,
                    color: primaryColor,
                  ),
                  textAlign: TextAlign.end,
                ),
              ),
              SizedBox(height: 50.h),
              Align(
                alignment: Alignment.centerRight,
                child: FloatingActionButton(
                  backgroundColor: primaryColor,
                  shape: const CircleBorder(),
                  onPressed: () {
                    setState(() {
                      isLoading = true;
                    });
                  },
                  child: isLoading
                      ? LoadingAnimationWidget.hexagonDots(
                          color: Colors.white,
                          size: 40.h,
                        )
                      : Icon(
                          Icons.u_turn_right,
                          color: Colors.white,
                        ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
