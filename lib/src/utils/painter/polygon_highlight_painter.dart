import 'package:flutter/material.dart';

class PolygonHighlightPainter extends CustomPainter {
  final double width;
  final double height;
  final List<Offset> vertices;
  final Color color;
  final double strokeWidth;
  final double dashWidth;
  final double dashSpace;

  /// Rectangular dashed line painter.
  ///
  /// Useful if added as component widget to highlight it.
  PolygonHighlightPainter({
    required this.width,
    required this.height,
    required this.vertices,
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

    Path path = Path();

    path.moveTo(vertices[0].dx + 2, vertices[0].dy + 2);
    for (var i = 1 ; i < vertices.length; i++ ) {
      path.lineTo(vertices[i].dx + 2, vertices[i].dy + 2);
    }
    path.lineTo(vertices[0].dx.toDouble() + 2, vertices[0].dy.toDouble() + 2);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
