import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shimmer/shimmer.dart';

class ShimmerImageWidget extends StatefulWidget {
  ShimmerImageWidget({super.key, required this.url});

  final String url;

  @override
  State<ShimmerImageWidget> createState() => _ShimmerImageWidgetState();
}

class _ShimmerImageWidgetState extends State<ShimmerImageWidget> {
  bool _isImageLoaded = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Image.network(
          widget.url,
          loadingBuilder: (context, child, loadingProgress) {
            print(loadingProgress.toString());
            if ((loadingProgress!.cumulativeBytesLoaded /
                    loadingProgress.expectedTotalBytes!.toInt()) !=
                1) {
              return Shimmer.fromColors(
                baseColor: Colors.grey.shade300,
                highlightColor: Colors.grey.shade100,
                child: Container(
                  width: 240.w,
                  height: 320.w,
                ),
              );
            }
            return Container();
          },
          fit: BoxFit.cover,
          width: 240.w,
          height: 320.w,
        ),
      ],
    );
  }
}
