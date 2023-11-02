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
                      const Color(0xFF8983F7),
                      const Color(0xFFA3DAFB),
                    ],
                  )
                : null,
            border: Border.all(color: Theme.of(context).primaryColor, width: 1.0),
            borderRadius: const BorderRadius.all(Radius.circular(4))),
        child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                widget.item['title'],
                style: TextStyle(
                    fontSize: 26.sp,
                    color: widget.isSelected ?  Colors.white :  Theme.of(context).hintColor),
              ),
            ]),
      ),
      onTap: () {
        widget.onItemClick(widget.item);
      },
    );
  }
}
