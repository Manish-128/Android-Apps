import 'package:flutter/material.dart';

class BackgroundPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    for (int i = 0; i < 8; i++) {
      final path = Path();
      path.moveTo(0, size.height * (i / 8));

      path.quadraticBezierTo(
        size.width * 0.3,
        size.height * (i / 8) + (i % 2 == 0 ? 60 : -60),
        size.width * 0.6,
        size.height * (i / 8),
      );

      path.quadraticBezierTo(
        size.width * 0.9,
        size.height * (i / 8) + (i % 2 == 0 ? -60 : 60),
        size.width,
        size.height * (i / 8),
      );

      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}