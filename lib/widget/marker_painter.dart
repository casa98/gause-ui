import 'package:flutter/material.dart';

class GaugeMarkerPainter extends CustomPainter {
  GaugeMarkerPainter(this.text, this.position, this.textStyle);

  final String text;
  final TextStyle textStyle;
  final Offset position;

  @override
  void paint(Canvas canvas, Size size) {
    final textSpan = TextSpan(
      text: text,
      style: textStyle,
    );
    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
    );
    textPainter.layout(
      minWidth: 0,
      maxWidth: size.width,
    );
    textPainter.paint(canvas, position);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}
