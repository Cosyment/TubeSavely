import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../constants/colors.dart';

class PlatFormItem extends StatefulWidget {
  const PlatFormItem(
      {super.key,
      required this.item,
      required this.isSelected,
      required this.onItemClick});

  final Map<String, dynamic> item;
  final bool isSelected;
  final Function onItemClick;

  @override
  State<PlatFormItem> createState() => _PlatFormItemState();
}

class _PlatFormItemState extends State<PlatFormItem> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Container(
        decoration: BoxDecoration(
            gradient: widget.isSelected
                ? const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFFFC6AEC),
                      Color(0xFF7776FF),
                    ],
                  )
                : null,
            border: Border.all(color: primaryColor, width: 1.0),
            borderRadius: const BorderRadius.all(Radius.circular(4))),
        child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Image(
                image: AssetImage("assets/images/${widget.item['icon']}"),
                width: 60.w,
                height: 60.w,
                fit: BoxFit.fill,
              ),
              SizedBox(
                width: 10.w,
              ),
              Text(
                widget.item['title'],
                style: TextStyle(
                    fontSize: 24.sp,
                    color: widget.isSelected ? Colors.white : Colors.black),
              ),
            ]),
      ),
      onTap: () {
        widget.onItemClick(widget.item);
      },
    );
  }
}
