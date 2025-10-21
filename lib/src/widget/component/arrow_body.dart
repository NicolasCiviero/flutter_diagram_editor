import 'dart:math';

import 'package:shape_editor/shape_editor.dart';
import 'package:shape_editor/src/canvas_context/model/vertex.dart';
import 'package:shape_editor/src/widget/component/base_component_body.dart';
import 'package:flutter/material.dart';
import 'package:vector_math/vector_math.dart' as vector_math;

class ArrowBody extends StatelessWidget {
  final ComponentData componentData;

  const ArrowBody({
    Key? key,
    required this.componentData,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BaseComponentBody(
      componentData: componentData,
      componentPainter: ArrowPainter(
        color: componentData.color,
        borderColor: componentData.borderColor,
        borderWidth: componentData.borderWidth,
        vertices: componentData.vertices,
        componentSize: componentData.size,
      ),
    );
  }
}

class ArrowPainter extends CustomPainter {
  final Color color;
  final Color borderColor;
  final double borderWidth;
  final Size componentSize;
  List<Vertex> vertices = [];
  Size availableSize = Size(0,0);

  ArrowPainter({
    this.color = Colors.grey,
    this.borderColor = Colors.black,
    this.borderWidth = 1.0,
    required this.vertices,
    required this.componentSize,
  });

  @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.fill;
    availableSize = size;

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
  bool hitTest(Offset point) {
    Path path = Path();
    if (vertices.length < 2) return false;

    var xScale = availableSize.width / componentSize.width;
    var yScale = availableSize.height / componentSize.height;

    path.moveTo(vertices[0].position.dx * xScale, vertices[0].position.dy * yScale);
    path.lineTo(vertices[1].position.dx * xScale, vertices[1].position.dy * yScale);
    path.close();

    double minDistance = double.infinity;
    final pathMetrics = path.computeMetrics();
    for (final metric in pathMetrics) {
      final extractPath = metric.extractPath(0, metric.length);
      final pathPoints = extractPath.computeMetrics();
      for (final pathMetric in pathPoints) {
        for (double t = 0.0; t < pathMetric.length; t += 1.0) {
          final tangent = pathMetric.getTangentForOffset(t);
          if (tangent == null) continue;
          final position = tangent.position;
          final distance = vector_math.Vector2(position.dx, position.dy)
              .distanceTo(vector_math.Vector2(point.dx, point.dy));
          if (distance < minDistance) {
            minDistance = distance;
          }
        }
      }
    }
    return minDistance < 10;
  }

  Path componentPath() {
    var xScale = availableSize.width / componentSize.width;
    var yScale = availableSize.height / componentSize.height;
    var tip_size = 20 / yScale;

    Path path = Path();
    if (vertices.length < 2) return path;

    // maths
    final p1 = vertices[0];
    final p2 = vertices[1];
    var dx = p2.position.dx - p1.position.dx;
    var dy = p2.position.dy - p1.position.dy;
    var norm = sqrt(dx * dx + dy * dy);
    dx = dx / norm;
    dy = dy / norm;
    // find arrow base
    var base = Offset(p2.position.dx - dx * tip_size, p2.position.dy - dy * tip_size);
    // find arrow edges
    var ledge = Offset(base.dx - dy * tip_size * 0.3, base.dy + dx * tip_size * 0.3);
    var redge = Offset(base.dx + dy * tip_size * 0.3, base.dy - dx * tip_size * 0.3);

    // move to arrow back
    path.moveTo(p1.position.dx * xScale, p1.position.dy * yScale);
    path.lineTo(base.dx * xScale, base.dy * yScale); //base
    path.lineTo(ledge.dx * xScale, ledge.dy * yScale); //ledge
    path.lineTo(p2.position.dx * xScale, p2.position.dy * yScale); // arrow tip
    path.lineTo(redge.dx * xScale, redge.dy * yScale); //redge
    path.lineTo(base.dx * xScale, base.dy * yScale); //base
    path.close();
    return path;
  }
}
