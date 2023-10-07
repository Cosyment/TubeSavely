import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../constants/colors.dart';
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
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/Background.png"),
            fit: BoxFit.cover,
          ),
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: 30.w,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 80.w),
              Text(
                "Login and start transfering",
                style: TextStyle(
                  fontSize: 32.sp,
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(height: 193.w),
              Text(
                "Email",
                style: TextStyle(
                  fontSize: 28.sp,
                ),
              ),
              SizedBox(height: 8.w),
              TextField(
                decoration: InputDecoration(
                  hintText: "Enter your email",
                  hintStyle: TextStyle(
                    fontSize: 28.sp,
                    color: Color(0xFF1A1A1A).withOpacity(0.2494),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.w),
                    borderSide: BorderSide(
                      color: Color(0xFF1A1A1A).withOpacity(0.1),
                      width: 1.sp,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 24.w),
              Text(
                "Password",
                style: TextStyle(
                  fontSize: 28.sp,
                ),
              ),
              SizedBox(height: 8.w),
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
