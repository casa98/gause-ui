import 'package:flutter/material.dart';

class ArcPainter extends CustomPainter {
  ArcPainter({
    this.startAngle = 0,
    this.sweepAngle = 0,
    this.color = Colors.grey,
  });

  final double startAngle;

  final double sweepAngle;

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTRB(size.width * 0.1, size.height * 0.1,
        size.width * 0.9, size.height * 0.9);

    const useCenter = false;

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 20;

    canvas.drawArc(rect, startAngle, sweepAngle, useCenter, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}
