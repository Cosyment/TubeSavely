import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../constants/colors.dart';

class LiveTypeItem extends StatefulWidget {
  const LiveTypeItem(
      {super.key,
      required this.item,
      required this.isSelected,
      required this.onItemClick});

  final Map<String, dynamic> item;
  final bool isSelected;
  final Function onItemClick;

  @override
  State<LiveTypeItem> createState() => _LiveTypeItemState();
}

class _LiveTypeItemState extends State<LiveTypeItem> {
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
        child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                widget.item['title'],
                style: TextStyle(
                    fontSize: 26.sp,
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
