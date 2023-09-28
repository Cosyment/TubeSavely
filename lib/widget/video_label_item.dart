import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../constants/colors.dart';
import '../models/video_info.dart';

class VideoItem extends StatefulWidget {
  const VideoItem(
      {super.key,
      required this.item,
      required this.isSelected,
      required this.onItemClick});

  final VideoInfo item;
  final bool isSelected;
  final Function onItemClick;

  @override
  State<VideoItem> createState() => _VideoItemState();
}

class _VideoItemState extends State<VideoItem> {
  @override
  Widget build(BuildContext context) {
    return InkWell(
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
                widget.item.label,
                style: TextStyle(
                    fontSize: 20.sp,
                    color: widget.isSelected ? Colors.white : Colors.black),
              ),
              Text(widget.item.size,
                  style: TextStyle(
                      fontSize: 20.sp,
                      color: widget.isSelected ? Colors.white : Colors.black))
            ]),
      ),
      onTap: () {
        widget.onItemClick(widget.item);
      },
    );
  }
}
