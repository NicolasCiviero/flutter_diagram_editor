import 'package:shape_editor/shape_editor.dart';
import 'package:shape_editor/src/widget/component/base_component_body.dart';
import 'package:flutter/material.dart';

class TextThumb extends StatefulWidget {
  final ComponentData componentData;

  const TextThumb({
    Key? key,
    required this.componentData,
  }) : super(key: key);

  @override
  State<TextThumb> createState() => _TextThumbState();
}

class _TextThumbState extends State<TextThumb> {
  late ComponentData componentData;

  @override
  void initState() {
    super.initState();
    componentData = widget.componentData;
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          width: componentData.size.width,
          height: componentData.size.height,
          decoration: BoxDecoration(
            color: widget.componentData.color,
            borderRadius: BorderRadius.circular(6),
          ),
        ),
        Padding(
          padding: EdgeInsets.only(left: 8, right: 8),
          child: Center(
            child: Text(
              "text",
              style: TextStyle(
                fontSize: 14,
                color: componentData.textColor,
                fontWeight: FontWeight.normal,
              ),
            ),
          ),
        )
      ],
    );
  }
}

class TextPainter extends CustomPainter {
  final Color color;
  final Color borderColor;
  final double borderWidth;
  Size componentSize = Size(0,0);

  TextPainter({
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
