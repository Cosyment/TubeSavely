import 'package:flutter/material.dart';

const List<Color> gradientColors = [
  Color(0xFFA3FFFF),
  Color(0xFF67FEFF),
  Color(0xFF9EFFD1),
  Color(0xFFFFFA8E),
];

///主题渐变按钮
class ThemeGradientButton extends StatelessWidget {
  final String text; // 按钮文案
  final bool enable; //是否为禁用状态
  final bool highlighted; // 高亮
  final double w; // 按钮宽度
  final double h; //按钮高度
  final Function ontap; //按钮点击事件的回调
  final List<Color> colors;
  final double fontsize; //字体大小
  final Color? fontColor; //字体颜色
  final FontWeight? fontWeight;
  final double? radius;
  final Color fillColor; //填充颜色
  final double borderWidth;
  final BoxBorder? border;

  const ThemeGradientButton({
    Key? key,
    required this.text,
    this.enable = true,
    required this.w,
    required this.h,
    required this.ontap,
    this.colors = gradientColors,
    this.fontsize = 18,
    this.fontColor = Colors.white,
    this.fontWeight = FontWeight.w500,
    this.radius,
    this.highlighted = true,
    this.fillColor = const Color(0xFFE5E5E9),
    this.borderWidth = 0.0,
    this.border,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        behavior: HitTestBehavior.opaque,
        child: Container(
            width: w,
            height: h,
            decoration: BoxDecoration(
                color: enable && highlighted ? null : fillColor,
                borderRadius: BorderRadius.all(Radius.circular(radius ?? h / 2)),
                gradient: enable && highlighted
                    ? LinearGradient(begin: const Alignment(-1, 0), end: const Alignment(1.0, 0), colors: colors)
                    : null,
                border: border),
            child: Center(
                child: Text(
              text,
              style: TextStyle(fontSize: fontsize, fontWeight: fontWeight, color: fontColor),
            ))),
        onTap: () {
          if (enable) {
            ontap();
          }
        });
  }
}
