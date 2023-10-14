import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../constants/colors.dart';

class ConfirmDialog extends StatefulWidget {
  const ConfirmDialog(
      {Key? key,
      required this.title,
      required this.leftText,
      required this.rightText,
      required this.onRightClick})
      : super(key: key);
  final String title;
  final String leftText;
  final String rightText;
  final Function onRightClick;

  @override
  ConfirmDialogState createState() => ConfirmDialogState();
}

class ConfirmDialogState extends State<ConfirmDialog> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
        backgroundColor: Colors.white,
        title: Text(
          widget.title,
          style: const TextStyle(
              color: primaryColor, fontSize: 18, fontWeight: FontWeight.bold),
        ),
        content: Container(
            margin: EdgeInsets.symmetric(vertical: 20.w),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.of(context).pop(true);
                  },
                  child: Container(
                    height: 40.h,
                    width: 100.w,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: grayColor,
                      borderRadius: BorderRadius.circular(30.r),
                    ),
                    child: Text(
                      widget.leftText,
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
                SizedBox(
                  width: 30.w,
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.of(context).pop(true);
                    widget.onRightClick();
                  },
                  child: Container(
                    height: 40.h,
                    width: 100.w,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(30.r),
                        color: primaryColor),
                    child: Text(
                      widget.rightText,
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                )
              ],
            )));
  }
}
