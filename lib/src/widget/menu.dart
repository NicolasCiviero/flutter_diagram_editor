import 'package:shape_editor/shape_editor.dart';
import 'package:flutter/material.dart';
import 'package:shape_editor/src/canvas_context/model/vertex.dart';

class DraggableMenu extends StatelessWidget {
  final PolicySet myPolicySet;
  final Color color;
  final Color borderColor;
  final Color textColor;
  final Color textBackgroundColor;
  final double borderWidth;
  final double scale;
  final double textSize;

  const DraggableMenu({
        Key? key,
        required this.myPolicySet,
        this.color = Colors.black12,
        this.borderColor = Colors.black,
        this.textColor = Colors.black,
        this.textBackgroundColor = Colors.white54,
        this.borderWidth = 2.0,
        this.scale = 1.0,
        this.textSize = 16.0,
      }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: <Widget>[
        ...myPolicySet.bodies.map(
              (componentType) {
            var componentData = getComponentData(componentType);
            return Padding(
              padding: EdgeInsets.fromLTRB(8, 8, 8, 16),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return SizedBox(
                    width: constraints.maxWidth < componentData.size.width
                        ? componentData.size.width *
                        (constraints.maxWidth / componentData.size.width)
                        : componentData.size.width,
                    height: constraints.maxWidth < componentData.size.width
                        ? componentData.size.height *
                        (constraints.maxWidth / componentData.size.width)
                        : componentData.size.height,
                    child: Align(
                      alignment: Alignment.center,
                      child: AspectRatio(
                        aspectRatio: componentData.size.aspectRatio,
                        child: Tooltip(
                          message: componentData.type,
                          child: DraggableComponent(
                            policySet: myPolicySet,
                            componentData: componentData,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            );
          },
        ).toList(),
      ],
    );
  }

  ComponentData getComponentData(String componentType) {
    switch (componentType) {
      case 'arrow':
        final c = ComponentData(
          size: Size(150 * scale, 100 * scale),
          minSize: Size(80 * scale, 64 * scale),
          color: color,
          borderColor: borderColor,
          borderWidth: borderWidth,
          type: componentType,
          vertices: [],
        );
        c.addVertex(Offset(0, 100 * scale), null);
        c.addVertex(Offset(150 * scale, 0), null);
        return c;
      case 'text':
        return ComponentData(
          size: Size(350 * scale, 180 * scale),
          minSize: Size(60 * scale, 30 * scale),
          color: textBackgroundColor,
          borderColor: Colors.transparent,
          borderWidth: borderWidth,
          type: componentType,
          textColor: textColor,
          textSize: textSize
        );
      case 'polygon':
        final c = ComponentData(
          size: Size(150 * scale, 110 * scale),
          minSize: Size(80 * scale, 64 * scale),
          color: color,
          borderColor: borderColor,
          borderWidth: borderWidth,
          type: componentType,
          vertices: [],
        );
        c.addVertex(Offset(75 * scale,0), null);
        c.addVertex(Offset(150 * scale,110 * scale), null);
        c.addVertex(Offset(0 * scale, 110 * scale), null);
        return c;
      default:
        return ComponentData(
          size: Size(160 * scale, 100 * scale),
          minSize: Size(32 * scale, 24 * scale),
          color: color,
          borderColor: borderColor,
          borderWidth: borderWidth,
          type: componentType,
        );
    }
  }
}

class DraggableComponent extends StatelessWidget {
  final PolicySet policySet;
  final ComponentData componentData;

  DraggableComponent({Key? key, required this.policySet, required this.componentData}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Draggable<ComponentData>(
      affinity: Axis.horizontal,
      ignoringFeedbackSemantics: true,
      data: componentData,
      childWhenDragging: policySet.showComponentBody(componentData),
      feedback: Material(
        color: Colors.transparent,
        child: Container(
          width: componentData.size.width,
          height: componentData.size.height,
          child: policySet.showComponentBody(componentData),
        ),
      ),
      child: policySet.showComponentThumb(componentData) ?? Container(),//TODO replace Container
    );
  }
}
