import 'package:shape_editor/diagram_editor.dart';
import 'package:shape_editor/src/widget/component/base_component_body.dart';
import 'package:flutter/material.dart';

class PolygonBody extends StatelessWidget {
  final ComponentData componentData;
  final double scale;

  const PolygonBody({
    Key? key,
    required this.componentData,
    required this.scale,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BaseComponentBody(
      componentData: componentData,
      componentPainter: PolygonPainter(
        scale: scale,
        color: componentData.color,
        borderColor: componentData.borderColor,
        borderWidth: componentData.borderWidth,
        vertices: componentData.vertices,
      ),
    );
  }
}

class PolygonPainter extends CustomPainter {
  final double scale;
  final Color color;
  final Color borderColor;
  final double borderWidth;
  List<Offset> vertices = [];
  Size componentSize = Size(0,0);

  PolygonPainter({
    this.scale = 1,
    this.color = Colors.grey,
    this.borderColor = Colors.black,
    this.borderWidth = 1.0,
    required this.vertices,
  });

  @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint()
      ..color = color
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
    Path path = Path();
    if (vertices == null || vertices.length == 0) return path;

    path.moveTo(vertices[0].dx * scale, vertices[0].dy * scale);
    for (var i = 1 ; i < vertices.length; i++ ) {
      path.lineTo(vertices[i].dx * scale, vertices[i].dy * scale);
    }
    path.close();
    return path;
  }
}
