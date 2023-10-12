import 'package:flutter/material.dart';
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
  var isLoading=false;
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
                height: 100.h,
                margin: EdgeInsets.symmetric(vertical: 40.h),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: "Enter your email",
                    labelText: "Email",
                    hintStyle: TextStyle(
                      fontSize: 26.sp,
                      color: const Color(0xFF1A1A1A).withOpacity(0.2494),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    enabledBorder: const OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                      borderSide: BorderSide(
                        color: primaryColor,
                        width: 2.0,
                      ),
                    ),
                    disabledBorder: const OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                      borderSide: BorderSide(
                        color: primaryColor,
                        width: 2.0,
                      ),
                    ),
                    focusedBorder: const OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                      borderSide: BorderSide(
                        color: primaryColor,
                        width: 2.0,
                      ),
                    ),
                  ),
                ),
              ),
              Container(
                height: 100.h,
                child: TextField(
                  decoration: InputDecoration(
                    hintText: "Enter your password",
                    labelText: "Password",
                    hintStyle: TextStyle(
                      fontSize: 26.sp,
                      color: const Color(0xFF1A1A1A).withOpacity(0.2494),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    enabledBorder: const OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                      borderSide: BorderSide(
                        color: primaryColor,
                        width: 2.0,
                      ),
                    ),
                    disabledBorder: const OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                      borderSide: BorderSide(
                        color: primaryColor,
                        width: 2.0,
                      ),
                    ),
                    focusedBorder: const OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                      borderSide: BorderSide(
                        color: primaryColor,
                        width: 2.0,
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 8.w),
              Container(
                alignment: Alignment.centerRight,
                child: Text(
                  "Forget password?",
                  style: TextStyle(
                    fontSize: 24.sp,
                    color: Theme.of(context).colorScheme.primary,
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
                     isLoading=true;
                   });
                  },
                  child: isLoading? LoadingAnimationWidget.hexagonDots(
                    color: Colors.white,
                    size: 40.h,
                  ):Icon(
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
