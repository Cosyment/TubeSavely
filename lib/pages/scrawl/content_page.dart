import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'file_utils.dart';
import 'scrawl_page.dart';
import 'watermark_page.dart';

class ContentPage extends StatefulWidget {
  const ContentPage({super.key, required this.cover});

  final File cover;

  @override
  State<ContentPage> createState() => _ContentPageState();
}

class _ContentPageState extends State<ContentPage> {
  final GlobalKey _repaintKey = GlobalKey();
  late final Uint8List _imagebytes = widget.cover.readAsBytesSync();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('scrawl and watermark'),
      ),
      body: RepaintBoundary(
        key: _repaintKey,
        child: Container(
          color: Colors.white,
          child: CustomScrollView(
            slivers: <Widget>[
              SliverToBoxAdapter(
                child: GestureDetector(
                  child: Padding(
                    padding: EdgeInsets.all(12.0),
                    child: Image.memory(_imagebytes),
                  ),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) {
                        return WatermarkPage(cover: widget.cover,);
                      }),
                    );
                  },
                ),
              ),
              SliverToBoxAdapter(
                child: Container(
                  alignment: Alignment.center,
                  child: Text(
                    '(Click image above to add watermark ↑↑↑)',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          _saveScreenShot(context);
        },
        icon: Icon(Icons.add),
        label: Text('去涂鸦'),
        backgroundColor:
            Color.alphaBlend(Colors.pinkAccent.withOpacity(0.8), Colors.white),
      ),
    );
  }

  void _saveScreenShot(BuildContext context) {
    var boundary =
        _repaintKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
    saveScreenShot(boundary, success: () {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (context) {
          return ScrawlPage();
        }),
      );
    }, fail: () {
      // showToast('save current screen fail!');
    });
  }
}
