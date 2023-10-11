import 'package:flutter/material.dart';

class ImageViewerPage extends StatelessWidget {
  final String imagePath;
  ImageViewerPage({required this.imagePath});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "图片预览",
        ),
      ),
      body: Center(
        child: GestureDetector(
          onTap: () {
            Navigator.pop(context);
          },
          child: Hero(
            tag: imagePath,
            child: Image.asset(imagePath),
          ),
        ),
      ),
    );
  }
}
