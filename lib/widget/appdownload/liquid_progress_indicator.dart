import 'package:flutter/material.dart';

import 'wave.dart';

class LiquidLinearProgressIndicator extends ProgressIndicator {
  final double borderWidth;

  final Color borderColor;

  final double borderRadius;

  final Widget? center;

  final Axis direction;

  LiquidLinearProgressIndicator({
    Key? key,
    double value = 0.5,
    Color? backgroundColor,
    Animation<Color>? valueColor,
    this.borderWidth = 0,
    this.borderColor = Colors.black,
    this.borderRadius = 5,
    this.center,
    this.direction = Axis.horizontal,
  }) : super(
          key: key,
          value: value,
          backgroundColor: backgroundColor,
          valueColor: valueColor,
        ) {
    if (borderWidth != null && borderColor == null ||
        borderColor != null && borderWidth == null) {
      throw ArgumentError("borderWidth and borderColor should both be set.");
    }
  }

  Color _getBackgroundColor(BuildContext context) =>
      backgroundColor ?? Color(0x0000BFFF); //Theme.of(context).backgroundColor;

  Color _getValueColor(BuildContext context) =>
      valueColor?.value ?? Color(0x6600BFFF); //Theme.of(context).accentColor;

  @override
  State<StatefulWidget> createState() => _LiquidLinearProgressIndicatorState();
}

class _LiquidLinearProgressIndicatorState
    extends State<LiquidLinearProgressIndicator> {
  @override
  Widget build(BuildContext context) {
    return ClipPath(
      clipper: _LinearClipper(
        radius: widget.borderRadius,
      ),
      child: CustomPaint(
        painter: _LinearPainter(
          color: widget._getBackgroundColor(context),
          radius: widget.borderRadius,
        ),
        foregroundPainter: _LinearBorderPainter(
          color: widget.borderColor,
          width: widget.borderWidth,
          radius: widget.borderRadius,
        ),
        child: Stack(
          children: <Widget>[
            Wave(
              value: widget.value!,
              color: widget._getValueColor(context),
              direction: widget.direction,
            ),
            widget.center != null ? Center(child: widget.center) : Container(),
          ],
        ),
      ),
    );
  }
}

class _LinearPainter extends CustomPainter {
  final Color color;
  final double radius;

  _LinearPainter({required this.color, required this.radius});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(0, 0, size.width, size.height),
          Radius.circular(radius),
        ),
        paint);
  }

  @override
  bool shouldRepaint(_LinearPainter oldDelegate) => color != oldDelegate.color;
}

class _LinearBorderPainter extends CustomPainter {
  final Color color;
  final double width;
  final double radius;

  _LinearBorderPainter({
    required this.color,
    required this.width,
    required this.radius,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (color == null || width == null) {
      return;
    }

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = width;
    final alteredRadius = radius;
    canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(
              width / 2, width / 2, size.width - width, size.height - width),
          Radius.circular(alteredRadius - width),
        ),
        paint);
  }

  @override
  bool shouldRepaint(_LinearBorderPainter oldDelegate) =>
      color != oldDelegate.color ||
      width != oldDelegate.width ||
      radius != oldDelegate.radius;
}

class _LinearClipper extends CustomClipper<Path> {
  final double radius;

  _LinearClipper({required this.radius});

  @override
  Path getClip(Size size) {
    final path = Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(0, 0, size.width, size.height),
          Radius.circular(radius),
        ),
      );
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
