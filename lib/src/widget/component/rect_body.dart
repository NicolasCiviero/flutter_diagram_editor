import 'package:shape_editor/diagram_editor.dart';
import 'package:shape_editor/src/widget/component/base_component_body.dart';
import 'package:flutter/material.dart';

class RectBody extends StatelessWidget {
  final ComponentData componentData;

  const RectBody({
    Key? key,
    required this.componentData,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BaseComponentBody(
      componentData: componentData,
      componentPainter: RectPainter(
        color: componentData.color,
        borderColor: componentData.borderColor,
        borderWidth: componentData.borderWidth,
      ),
    );
  }
}

class RectPainter extends CustomPainter {
  final Color color;
  final Color borderColor;
  final double borderWidth;
  Size componentSize = Size(0,0);

  RectPainter({
    this.color = Colors.grey,
    this.borderColor = Colors.black,
    this.borderWidth = 1.0,
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
      if (borderWidth > 0) {
        paint
          ..style = PaintingStyle.stroke
          ..color = borderColor
          ..strokeWidth = borderWidth;

        canvas.drawPath(path, paint);
      }
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
    path.moveTo(0, 0);
    path.lineTo(componentSize.width, 0);
    path.lineTo(componentSize.width, componentSize.height);
    path.lineTo(0, componentSize.height);
    path.close();
    return path;
  }
}
