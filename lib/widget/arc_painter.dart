import 'package:flutter/material.dart';

class ArcPainter extends CustomPainter {
  ArcPainter({
    this.startAngle = 0,
    this.sweepAngle = 0,
  });

  final double startAngle;

  final double sweepAngle;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTRB(size.width * 0.1, size.height * 0.1,
        size.width * 0.9, size.height * 0.9);

    const useCenter = false;

    final paint = Paint()
      ..shader = LinearGradient(
        colors: [
          Colors.red[600]!,
          Colors.orange[300]!,
          Colors.yellow,
          Colors.green,
        ],
        begin: Alignment.bottomLeft,
        end: Alignment.bottomRight,
      ).createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 20;

    canvas.drawArc(rect, startAngle, sweepAngle, useCenter, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}
