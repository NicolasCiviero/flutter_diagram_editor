import 'package:shape_editor/src/abstraction_layer/policy/state_policy.dart';
import 'package:shape_editor/src/abstraction_layer/policy/base_policy_set.dart';
import 'package:shape_editor/src/canvas_context/model/component_data.dart';
import 'package:shape_editor/src/utils/painter/arrow_highlight_painter.dart';
import 'package:shape_editor/src/widget/option_icon.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:shape_editor/shape_editor.dart';
import 'package:flutter/services.dart';

/// Allows you to add any widget to a component.
mixin ComponentWidgetsPolicy on BasePolicySet implements StatePolicy {
  Color buttonBackColor = Colors.grey.withOpacity(0.7);
  Color loadingIndicatorColor = Colors.grey.withOpacity(0.7);

  /// Allows you to add any widget to a component.
  ///
  /// These widgets will be displayed under all components.
  ///
  /// You have [ComponentData] here so you can customize the widgets to individual component.
  Widget showCustomWidgetWithComponentDataUnder(
      BuildContext context, ComponentData componentData) {
    return SizedBox.shrink();
  }

  /// Allows you to add any widget to a component.
  ///
  /// These widgets will have the same z-order as this component and will be displayed over this component.
  ///
  /// You have [ComponentData] here so you can customize the widgets to individual component.
  Widget showCustomWidgetWithComponentData(
      BuildContext context, ComponentData componentData) {
    return SizedBox.shrink();
  }

  /// Allows you to add any widget to a component.
  ///
  /// These widgets will be displayed over all components.
  ///
  /// You have [ComponentData] here so you can customize the widgets to individual component.
  Widget showCustomWidgetWithComponentDataOver(
      BuildContext context, ComponentData componentData) {
    bool isJunction = componentData.type == 'junction';
    bool isPolygon = componentData.type == 'polygon';
    bool hasVertices =
        componentData.type == 'polygon' || componentData.type == 'arrow';
    bool showOptions = (!isMultipleSelectionOn) && !isJunction;
    bool isResizable = componentData.type != 'pixel_map' && !hasVertices;

    return Visibility(
      visible: componentData.isHighlightVisible,
      child: Stack(
        children: [
          if (showOptions) componentTopOptions(componentData, context),
          //if (showOptions) componentBottomOptions(componentData),
          highlight(
              componentData, isMultipleSelectionOn ? Colors.cyan : Colors.red),
          if (isPolygon) ...(this as dynamic).appendVertices(componentData),
          if (hasVertices) ...(this as dynamic).dragVertices(componentData),
          if (isResizable) resizeCorner(componentData),
          if (isJunction) junctionOptions(componentData),
        ],
      ),
    );
  }

  Widget componentTopOptions(ComponentData componentData, context) {
    Offset componentPosition =
        stateReader.toCanvasFinalCoordinates(componentData.position);
    return Positioned(
      left: componentPosition.dx,
      top: componentPosition.dy - 48,
      child: Row(
        children: [
          OptionIcon(
            color: buttonBackColor,
            iconData: Icons.delete_forever,
            tooltip: 'delete',
            size: 40,
            onPressed: () {
              modelWriter.removeComponent(componentData.id);
              selectedComponentId = null;
            },
          ),
        ],
      ),
    );
  }

  Widget componentBottomOptions(ComponentData componentData) {
    Offset componentBottomLeftCorner = stateReader.toCanvasCoordinates(
        componentData.position + componentData.size.bottomLeft(Offset.zero));
    return Positioned(
      left: componentBottomLeftCorner.dx - 16,
      top: componentBottomLeftCorner.dy + 8,
      child: Row(
        children: [
          OptionIcon(
            color: Colors.grey.withOpacity(0.7),
            iconData: Icons.arrow_upward,
            tooltip: 'bring to front',
            size: 24,
            shape: BoxShape.rectangle,
            onPressed: () =>
                modelWriter.moveComponentToTheFront(componentData.id),
          ),
          SizedBox(width: 12),
          OptionIcon(
            color: Colors.grey.withOpacity(0.7),
            iconData: Icons.arrow_downward,
            tooltip: 'move to back',
            size: 24,
            shape: BoxShape.rectangle,
            onPressed: () =>
                modelWriter.moveComponentToTheBack(componentData.id),
          ),
          SizedBox(width: 40),
        ],
      ),
    );
  }

  Widget highlight(ComponentData componentData, Color color) {
    var position =
        componentData.position * stateReader.finalScale + stateReader.position;
    if (componentData.type != "arrow") position = position - Offset(2, 2);
    final finalScale = stateReader.finalScale;
    return Positioned(
      left: position.dx,
      top: position.dy,
      child: CustomPaint(
        painter: componentData.type == "arrow"
            ? ArrowHighlightPainter(
                p1: componentData.vertices[0].position
                    .scale(finalScale, finalScale),
                p2: componentData.vertices[1].position
                    .scale(finalScale, finalScale),
                color: color,
              )
            : RectHighlightPainter(
                width: componentData.size.width * finalScale + 4,
                height: componentData.size.height * finalScale + 4,
                color: color,
              ),
      ),
    );
  }

  resizeCorner(ComponentData componentData) {
    Offset componentBottomRightCorner = stateReader.toCanvasFinalCoordinates(
        componentData.position + componentData.size.bottomRight(Offset.zero));
    return Positioned(
      left: componentBottomRightCorner.dx - 12,
      top: componentBottomRightCorner.dy - 12,
      child: GestureDetector(
        onPanUpdate: (details) {
          modelWriter.resizeComponent(
              componentData.id, details.delta / stateReader.finalScale);
        },
        onPanEnd: (details) {
          modelWriter.resizeComponentEnd(componentData.id);
        },
        child: MouseRegion(
          cursor: SystemMouseCursors.resizeDownRight,
          child: Container(
            width: 24,
            height: 24,
            color: Colors.transparent,
            child: Center(
              child: Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: Colors.grey[800]!),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget junctionOptions(ComponentData componentData) {
    Offset componentPosition =
        stateReader.toCanvasCoordinates(componentData.position);
    return Positioned(
      left: componentPosition.dx - 24,
      top: componentPosition.dy - 48,
      child: Row(
        children: [
          OptionIcon(
            color: Colors.grey.withOpacity(0.7),
            iconData: Icons.delete_forever,
            tooltip: 'delete',
            size: 32,
            onPressed: () {
              modelWriter.removeComponent(componentData.id);
              selectedComponentId = null;
            },
          ),
          SizedBox(width: 8),
        ],
      ),
    );
  }
}
