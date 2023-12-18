import 'package:shape_editor/shape_editor.dart';
import 'package:flutter/material.dart';

class BaseComponentBody extends StatelessWidget {
  final ComponentData componentData;
  final CustomPainter componentPainter;

  const BaseComponentBody({
    Key? key,
    required this.componentData,
    required this.componentPainter,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {

    return GestureDetector(
      child: CustomPaint(
        painter: componentPainter,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 4),
          child: Align(
            alignment: componentData.textAlignment,
            child: Text(
              componentData.text,
              style: TextStyle(fontSize: componentData.textSize),
            ),
          ),
        ),
      ),
    );
  }
}
