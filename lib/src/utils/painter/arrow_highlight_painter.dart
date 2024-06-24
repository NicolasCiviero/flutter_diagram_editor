import 'dart:math';

import 'package:flutter/material.dart';

class ArrowHighlightPainter extends CustomPainter {
  final Offset p1;
  final Offset p2;
  final Color color;
  final double strokeWidth;
  final double dashWidth;
  final double dashSpace;

  /// Rectangular dashed line painter.
  ///
  /// Useful if added as component widget to highlight it.
  ArrowHighlightPainter({
    required this.p1,
    required this.p2,
    this.color = Colors.red,
    this.strokeWidth = 2,
    this.dashWidth = 10,
    this.dashSpace = 5,
  });

  @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    Path dashedPath = Path();

    var length = sqrt(pow(p2.dx - p1.dx, 2) + pow(p2.dy - p1.dy, 2));
    var dx = (p2.dx - p1.dx) / length;
    var dy = (p2.dy - p1.dy) / length;
    var p1L = Offset(p1.dx - 10 * dy, p1.dy + 10 * dx);
    var p1R = Offset(p1.dx + 10 * dy, p1.dy - 10 * dx);
    var p2L = Offset(p2.dx - 10 * dy, p2.dy + 10 * dx);
    var p2R = Offset(p2.dx + 10 * dy, p2.dy - 10 * dx);

    drawLine(dashedPath, p1L, p2L);
    drawLine(dashedPath, p2L, p2R);
    drawLine(dashedPath, p1R, p2R);
    drawLine(dashedPath, p1L, p1R);

    canvas.drawPath(dashedPath, paint);
  }

  void drawLine(dashedPath, start, end) {
    var length = sqrt(pow(end.dx - start.dx, 2) + pow(end.dy - start.dy, 2));
    var dx = (end.dx - start.dx) / length;
    var dy = (end.dy - start.dy) / length;

    double pathLength = 0;
    dashedPath.moveTo(start.dx, start.dy);
    while (pathLength < length) {
      pathLength = min(length, pathLength + dashWidth);
      dashedPath.lineTo(start.dx + dx * pathLength, start.dy + dy * pathLength);
      pathLength = min(length, pathLength + dashSpace);
      dashedPath.moveTo(start.dx + dx * pathLength,start.dy + dy * pathLength);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
