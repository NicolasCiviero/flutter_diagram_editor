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

