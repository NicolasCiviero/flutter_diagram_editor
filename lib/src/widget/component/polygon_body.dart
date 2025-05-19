import 'package:shape_editor/shape_editor.dart';
import 'package:shape_editor/src/widget/component/base_component_body.dart';
import 'package:flutter/material.dart';

class PolygonBody extends StatelessWidget {
  final ComponentData componentData;

  const PolygonBody({
    Key? key,
    required this.componentData,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BaseComponentBody(
      componentData: componentData,
      componentPainter: PolygonPainter(
        color: componentData.color,
        borderColor: componentData.borderColor,
        borderWidth: componentData.borderWidth,
        vertices: componentData.vertices,
        componentSize: componentData.size,
      ),
    );
  }
}

class PolygonPainter extends CustomPainter {
  final Color color;
  final Color borderColor;
  final double borderWidth;
  final Size componentSize;
  List<Offset> vertices = [];
  Size availableSize = Size(0,0);

  PolygonPainter({
    this.color = Colors.grey,
    this.borderColor = Colors.black,
    this.borderWidth = 1.0,
    required this.vertices,
    required this.componentSize,
  });

  @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint()
      ..color = color
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
  bool hitTest(Offset position) {
    Path path = componentPath();
    return path.contains(position);
  }

  Path componentPath() {
    Path path = Path();
    if (vertices == null || vertices.length == 0) return path;

    var xScale = availableSize.width / componentSize.width;
    var yScale = availableSize.height / componentSize.height;

    path.moveTo(vertices[0].dx * xScale, vertices[0].dy * yScale);
    for (var i = 1 ; i < vertices.length; i++ ) {
      path.lineTo(vertices[i].dx * xScale, vertices[i].dy * yScale);
    }
    path.close();
    return path;
  }
}
