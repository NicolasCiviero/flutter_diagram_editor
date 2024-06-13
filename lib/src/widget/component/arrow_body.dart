import 'dart:math';

import 'package:shape_editor/shape_editor.dart';
import 'package:shape_editor/src/widget/component/base_component_body.dart';
import 'package:flutter/material.dart';

class ArrowBody extends StatelessWidget {
  final ComponentData componentData;
  final double scale;

  const ArrowBody({
    Key? key,
    required this.componentData,
    required this.scale,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BaseComponentBody(
      componentData: componentData,
      componentPainter: ArrowPainter(
        scale: scale,
        color: componentData.color,
        borderColor: componentData.borderColor,
        borderWidth: componentData.borderWidth,
        vertices: componentData.vertices,
      ),
    );
  }
}

class ArrowPainter extends CustomPainter {
  final double scale;
  final Color color;
  final Color borderColor;
  final double borderWidth;
  List<Offset> vertices = [];
  Size componentSize = Size(0,0);

  ArrowPainter({
    this.scale = 1,
    this.color = Colors.grey,
    this.borderColor = Colors.black,
    this.borderWidth = 1.0,
    required this.vertices,
  });

  @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.fill;
    componentSize = size;

    Path path = componentPath();

    canvas.drawPath(path, paint);

    if (borderWidth > 0) {
      paint
        ..style = PaintingStyle.stroke
        ..color = borderColor
        ..strokeWidth = borderWidth;

      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;

  @override
  bool hitTest(Offset position) {
    Path path = componentPath();
    return path.contains(position);
  }

  Path componentPath() {
    var tip_size = 20 /scale;

    Path path = Path();
    if (vertices == null || vertices.length < 2) return path;

    // maths
    final p1 = vertices[0];
    final p2 = vertices[1];
    var dx = p2.dx - p1.dx;
    var dy = p2.dy - p1.dy;
    var norm = sqrt(dx * dx + dy * dy);
    dx = dx / norm;
    dy = dy / norm;
    // find arrow base
    var base = Offset(p2.dx - dx * tip_size, p2.dy - dy * tip_size);
    // find arrow edges
    var ledge = Offset(base.dx - dy * tip_size * 0.3, base.dy + dx * tip_size * 0.3);
    var redge = Offset(base.dx + dy * tip_size * 0.3, base.dy - dx * tip_size * 0.3);

    // move to arrow back
    path.moveTo(p1.dx * scale, p1.dy * scale);
    path.lineTo(base.dx * scale, base.dy * scale); //base
    path.lineTo(ledge.dx * scale, ledge.dy * scale); //ledge
    path.lineTo(p2.dx * scale, p2.dy * scale); // arrow tip
    path.lineTo(redge.dx * scale, redge.dy * scale); //redge
    path.lineTo(base.dx * scale, base.dy * scale); //base
    path.close();
    return path;
  }
}
