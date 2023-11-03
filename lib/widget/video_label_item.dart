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
                      const Color(0xFF8983F7),
                      const Color(0xFFA3DAFB),
                    ],
                  )
                : null,
            border:
                Border.all(color: Theme.of(context).primaryColor, width: 1.0),
            borderRadius: const BorderRadius.all(Radius.circular(4))),
        child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                widget.item.label,
                style: TextStyle(
                    fontSize: 20.sp,
                    color: widget.isSelected
                        ? Colors.white
                        : Theme.of(context).hintColor),
              ),
              Text(widget.item.size,
                  style: TextStyle(
                      fontSize: 20.sp,
                      color: widget.isSelected
                          ? Colors.white
                          : Theme.of(context).hintColor))
            ]),
      ),
      onTap: () {
        widget.onItemClick(widget.item);
      },
    );
  }
}
