import 'dart:io';
import 'dart:typed_data';

import 'package:downloaderx/utils/exit.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'file_utils.dart';

class WatermarkPage extends StatefulWidget {
  const WatermarkPage({super.key, required this.cover});

  final File cover;

  @override
  State<StatefulWidget> createState() => WatermarkState();
}

class WatermarkState extends State<WatermarkPage> {

  late final Uint8List _imagebytes = widget.cover.readAsBytesSync();

  static List<Icon> icons = const [
    Icon(
      Icons.map,
      size: 40.0,
      color: Colors.pinkAccent,
    ),
    Icon(
      Icons.storage,
      size: 40.0,
      color: Colors.pinkAccent,
    ),
    Icon(
      Icons.format_paint,
      size: 40.0,
      color: Colors.pinkAccent,
    ),
    Icon(
      Icons.home,
      size: 40.0,
      color: Colors.pinkAccent,
    ),
    Icon(
      Icons.restore,
      size: 40.0,
      color: Colors.pinkAccent,
    ),
    Icon(
      Icons.translate,
      size: 40.0,
      color: Colors.pinkAccent,
    ),
  ];

  Icon selected = icons[0];

  final GlobalKey _repaintKey = new GlobalKey();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text('添加水印'),
        ),
        body: Column(
          children: <Widget>[
            Expanded(
              child: Center(
                child: RepaintBoundary(
                  key: _repaintKey,
                  child: Stack(
                    alignment: Alignment.bottomRight,
                    children: <Widget>[
                      Image.memory(_imagebytes),
                      selected,
                    ],
                  ),
                ),
              ),
            ),
            InkWell(
              onTap: () {
                RenderRepaintBoundary boundary = _repaintKey.currentContext!
                    .findRenderObject() as RenderRepaintBoundary;
                saveScreenShot2SDCard(boundary, success: () {
                  ToastExit.show("保存成功");
                }, fail: () {
                  ToastExit.show("保存失败");
                });
              },
              child: Container(
                padding: EdgeInsets.symmetric(
                  vertical: 20.w,
                  horizontal: 20.w,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15.r),
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFFFC6AEC),
                      Color(0xFF7776FF),
                    ],
                  ),
                ),
                child: Text(
                  '保存',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 26.sp,
                  ),
                ),
              ),
            ),
            Container(
              height: 60.0,
              child: ListView.builder(
                itemCount: icons.length,
                scrollDirection: Axis.horizontal,
                shrinkWrap: true,
                itemBuilder: (context, index) {
                  Icon icon = icons[index];
                  return Container(
                    width: 80.0,
                    height: 60.0,
//                  alignment: Alignment.center,
                    child: GestureDetector(
                        child: icon,
                        onTap: () {
                          setState(() {
                            selected = icon;
                          });
                        }),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
