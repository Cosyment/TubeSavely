import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

import '../constants/colors.dart';

class FeedBackPage extends StatefulWidget {
  const FeedBackPage({super.key});

  @override
  State<FeedBackPage> createState() => _FeedBackPageState();
}

class _FeedBackPageState extends State<FeedBackPage> {
  var isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("意见反馈"),
      ),
      body: Container(
        width: double.infinity,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 30.w, vertical: 60.w),
          child: Column(
            children: [
              Container(
                child: TextField(
                  maxLines: 8,
                  minLines: 5,
                  autofocus: true,
                  keyboardType: TextInputType.text,
                  inputFormatters: <TextInputFormatter>[
                    LengthLimitingTextInputFormatter(200)
                  ],
                  style: TextStyle(color: Colors.black, fontSize: 30.sp),
                  decoration: InputDecoration(
                    hintText: "请输入您的意见,我们期待您的反馈~",
                    hintStyle: TextStyle(
                      fontSize: 30.sp,
                      color: Colors.grey,
                    ),
                    contentPadding:
                        EdgeInsets.symmetric(vertical: 25.w, horizontal: 25.w),
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
                margin: EdgeInsets.symmetric(vertical: 30.h),
                child: TextField(
                  keyboardType: TextInputType.visiblePassword,
                  inputFormatters: <TextInputFormatter>[
                    LengthLimitingTextInputFormatter(16)
                  ],
                  style: TextStyle(color: primaryColor, fontSize: 28.sp),
                  decoration: InputDecoration(
                    hintText: "请输入您的联系方式",
                    labelText: "联系方式",
                    hintStyle: TextStyle(
                      fontSize: 28.sp,
                      color: Colors.grey,
                    ),
                    labelStyle: TextStyle(fontSize: 28.sp, color: Colors.grey),
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
              SizedBox(
                height: 120.h,
              ),
              FloatingActionButton(
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
                        Icons.navigate_next,
                        color: Colors.white,
                      ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
