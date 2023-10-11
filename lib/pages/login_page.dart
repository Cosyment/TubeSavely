import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../widget/primary_button.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
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
            horizontal: 30.w,
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
              SizedBox(height: 40.w),
              TextField(
                decoration: InputDecoration(
                  hintText: "Enter your email",
                  labelText: "Email",
                  hintStyle: TextStyle(
                    fontSize: 28.sp,
                    color: Color(0xFF1A1A1A).withOpacity(0.2494),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                    borderSide: BorderSide(
                      color: Colors.blue,
                      width: 2.0,
                    ),
                  ),
                  disabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                    borderSide: BorderSide(
                      color: Colors.red,
                      width: 2.0,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(20)),
                    borderSide: BorderSide(
                      color: Colors.green,
                      width: 2.0,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 24.w),
              TextField(
                decoration: InputDecoration(
                  hintText: "Enter your password",
                  hintStyle: TextStyle(
                    fontSize: 28.sp,
                    color: Color(0xFF1A1A1A).withOpacity(0.2494),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  suffixIcon: Icon(
                    Icons.remove_red_eye_outlined,
                    size: 24.sp,
                    color: Colors.black.withOpacity(0.1953),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.w),
                    borderSide: BorderSide(
                      color: Color(0xFF1A1A1A).withOpacity(0.1),
                      width: 1.sp,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 8.w),
              SizedBox(
                width: 375.w,
                child: Text(
                  "Forget password?",
                  style: TextStyle(
                    fontSize: 28.sp,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  textAlign: TextAlign.end,
                ),
              ),
              SizedBox(height: 92.w),
              PrimaryButton(text: "Login"),
              SizedBox(height: 24.w),
              SizedBox(
                width: 375.w,
                child: Text(
                  "Create new account",
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontSize: 28.sp,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
