import 'package:downloaderx/utils/exit.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

import '../constants/colors.dart';
import '../network/http_api.dart';
import '../network/http_utils.dart';

class FeedBackPage extends StatefulWidget {
  const FeedBackPage({super.key});

  @override
  State<FeedBackPage> createState() => _FeedBackPageState();
}

class _FeedBackPageState extends State<FeedBackPage> {
  late TextEditingController contentController =
      TextEditingController(text: "");
  late TextEditingController mobileController = TextEditingController(text: "");
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
                  controller: contentController,
                  keyboardType: TextInputType.text,
                  inputFormatters: <TextInputFormatter>[
                    LengthLimitingTextInputFormatter(200)
                  ],
                  style: TextStyle(color: Colors.grey, fontSize: 30.sp),
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
                    fillColor: Colors.transparent,
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
                        color: Theme.of(context).primaryColor,
                        width: 1.w,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(14.r)),
                      borderSide: BorderSide(
                        color: Theme.of(context).primaryColor,
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
                  controller: mobileController,
                  keyboardType: TextInputType.visiblePassword,
                  inputFormatters: <TextInputFormatter>[
                    LengthLimitingTextInputFormatter(16)
                  ],
                  style: TextStyle(color: Colors.grey, fontSize: 28.sp),
                  decoration: InputDecoration(
                    hintText: "请输入您的联系方式",
                    labelText: "联系方式",
                    hintStyle: TextStyle(
                      fontSize: 28.sp,
                      color: Colors.grey,
                    ),
                    labelStyle: TextStyle(fontSize: 28.sp, color: Colors.grey),
                    filled: true,
                    fillColor: Colors.transparent,
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
                        color: Colors.grey,
                        width: 1.w,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(14.r)),
                      borderSide: BorderSide(
                        color: Theme.of(context).primaryColor,
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
                backgroundColor: Theme.of(context).primaryColor,
                shape: const CircleBorder(),
                onPressed: () {
                  submit();
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
              )
            ],
          ),
        ),
      ),
    );
  }

  submit() async {
    String content = contentController.text;
    if (content.isEmpty) {
      ToastExit.show('请输入内容');
      return;
    }
    setState(() {
      isLoading = true;
    });
    var map = <String, dynamic>{};
    map['content'] = content;
    map['mobile'] = mobileController.text;
    var respond = await HttpUtils.instance.requestNetWorkAy(
        Method.post, HttpApi.submitFeedback,
        queryParameters: map);
    if (respond) {
      await Future.delayed(Duration(milliseconds: 400));
      ToastExit.show('感谢您的反馈~');
      setState(() {
        isLoading = false;
      });
    } else {}
    Navigator.pop(context);
  }
}
