import 'package:shape_editor/shape_editor.dart';
import 'package:shape_editor/src/widget/component/base_component_body.dart';
import 'package:flutter/material.dart';

class TextBody extends StatefulWidget {
  final ComponentData componentData;
  final PolicySet policy;

  const TextBody({
    Key? key,
    required this.componentData,
    required this.policy,
  }) : super(key: key);

  @override
  State<TextBody> createState() => _TextBodyState();
}

class _TextBodyState extends State<TextBody> {
  FocusNode _focusNode = FocusNode();
  TextEditingController _controller = TextEditingController(text: null);

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      if (_focusNode.hasFocus) {
        widget.policy.onComponentTap(widget.componentData.id);
      }
    });
    _controller.text = widget.componentData.text;
  }

  @override
  Widget build(BuildContext context) {
    _controller.text = widget.componentData.text;
    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            color: widget.componentData.color,
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        Padding(
          padding: EdgeInsets.only(left: 8, right: 8),
          child: Center(
            child: TextField(
              focusNode: _focusNode,
              controller: _controller,
              textAlign: TextAlign.center,
              maxLines: null,
              style: TextStyle(
                fontSize: widget.componentData.textSize * widget.policy.stateReader.scale,
                color: widget.componentData.textColor,
                fontWeight: FontWeight.normal,
              ),
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: 'text',
              ),
              onChanged: (text) {
                setState(() {
                  widget.componentData.text = text;
                });
              },
            ),
          ),
        )
      ],
    );
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
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
