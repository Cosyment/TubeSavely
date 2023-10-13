import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:fraction/fraction.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

import '../utils/exit.dart';
import 'video_result_page.dart';

Future<void> _getImageDimension(File file,
    {required Function(Size) onResult}) async {
  var decodedImage = await decodeImageFromList(file.readAsBytesSync());
  onResult(Size(decodedImage.width.toDouble(), decodedImage.height.toDouble()));
}

String _fileMBSize(File file) =>
    ' ${(file.lengthSync() / (1024 * 1024)).toStringAsFixed(1)} MB';

class CoverResultPage extends StatefulWidget {
  const CoverResultPage({super.key, required this.cover});

  final File cover;

  @override
  State<CoverResultPage> createState() => _CoverResultPageState();
}

class _CoverResultPageState extends State<CoverResultPage> {
  late final Uint8List _imagebytes = widget.cover.readAsBytesSync();
  Size? _fileDimension;
  late String _fileMbSize;

  @override
  void initState() {
    super.initState();
    _getImageDimension(
      widget.cover,
      onResult: (d) => setState(() => _fileDimension = d),
    );
    _fileMbSize = _fileMBSize(widget.cover);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("图片预览"),
      ),
      body: Padding(
        padding: EdgeInsets.all(30.w),
        child: Column(
          children: [
            Expanded(
              child: Stack(
                children: [
                  Image.memory(_imagebytes),
                  Positioned(
                    bottom: 0,
                    child: FileDescription(
                      description: {
                        'Cover path': widget.cover.path,
                        'Cover ratio': Fraction.fromDouble(
                                _fileDimension?.aspectRatio ?? 0)
                            .reduce()
                            .toString(),
                        'Cover dimension': _fileDimension.toString(),
                        'Cover size': _fileMbSize,
                      },
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20.w),
            InkWell(
              onTap: () async {
                savePhoto();
              },
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 20.w, horizontal: 40.w),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15.r),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFFFC6AEC),
                      Color(0xFF7776FF),
                    ],
                  ),
                ),
                child: Text(
                  "保存",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 30.sp,
                  ),
                ),
              ),
            ),
            SizedBox(height: 20.w),
          ],
        ),
      ),
    );
  }

  void savePhoto() async {
    bool permition = await getPormiation();
    var status = await Permission.photos.status;
    if (permition) {
      if (Platform.isIOS) {
        final result = await ImageGallerySaver.saveImage(_imagebytes);
        if (result != null) {
          ToastExit.show("保存成功");
        }
      } else {
        final result = await ImageGallerySaver.saveImage(_imagebytes);
        if (result != null) {
          ToastExit.show("保存成功");
        } else {
          ToastExit.show("保存失败");
        }
      }
    } else {
      savePhoto();
    }
  }

  //申请存本地相册权限
  Future<bool> getPormiation() async {
    if (Platform.isIOS) {
      var status = await Permission.photos.status;
      if (status.isDenied) {
        Map<Permission, PermissionStatus> statuses = await [
          Permission.photos,
        ].request();
      }
      return status.isGranted;
    } else {
      var status = await Permission.storage.status;
      if (status.isDenied) {
        Map<Permission, PermissionStatus> statuses = await [
          Permission.storage,
          Permission.photos,
        ].request();
      }
      return status.isGranted;
    }
  }
}
