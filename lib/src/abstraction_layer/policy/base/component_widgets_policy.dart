import 'package:shape_editor/src/abstraction_layer/policy/base/state_policy.dart';
import 'package:shape_editor/src/abstraction_layer/policy/base_policy_set.dart';
import 'package:shape_editor/src/canvas_context/model/component_data.dart';
import 'package:shape_editor/src/widget/dialog/edit_component_dialog.dart';
import 'package:shape_editor/src/widget/option_icon.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:shape_editor/diagram_editor.dart';

/// Allows you to add any widget to a component.
mixin ComponentWidgetsPolicy on BasePolicySet implements StatePolicy {
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
  Widget showCustomWidgetWithComponentDataOver(BuildContext context, ComponentData componentData) {
    bool isJunction = componentData.type == 'junction';
    bool isPolygon = componentData.type == 'polygon';
    bool showOptions =
        (!isMultipleSelectionOn) && (!isReadyToConnect) && !isJunction;

    return Visibility(
      visible: componentData.isHighlightVisible,
      child: Stack(
        children: [
          //if (showOptions) componentTopOptions(componentData, context),
          //if (showOptions) componentBottomOptions(componentData),
          highlight( componentData, isMultipleSelectionOn ? Colors.cyan : Colors.red),
          if (isPolygon) ...appendVertices(componentData),
          if (isPolygon) ...dragVertices(componentData),
          if (!isPolygon) resizeCorner(componentData),
          if (isJunction && !isReadyToConnect) junctionOptions(componentData),
        ],
      ),
    );
  }

  Widget componentTopOptions(ComponentData componentData, context) {
    Offset componentPosition =
    canvasReader.state.toCanvasCoordinates(componentData.position);
    return Positioned(
      left: componentPosition.dx - 24,
      top: componentPosition.dy - 48,
      child: Row(
        children: [
          OptionIcon(
            color: Colors.grey.withOpacity(0.7),
            iconData: Icons.delete_forever,
            tooltip: 'delete',
            size: 40,
            onPressed: () {
              canvasWriter.model.removeComponent(componentData.id);
              selectedComponentId = null;
            },
          ),
          SizedBox(width: 12),
          OptionIcon(
            color: Colors.grey.withOpacity(0.7),
            iconData: Icons.copy,
            tooltip: 'duplicate',
            size: 40,
            onPressed: () {
              String newId = componentData.clone().id;
              canvasWriter.model.moveComponentToTheFront(newId);
              selectedComponentId = newId;
              hideComponentHighlight(componentData.id);
              highlightComponent(newId);
            },
          ),
          SizedBox(width: 12),
          OptionIcon(
            color: Colors.grey.withOpacity(0.7),
            iconData: Icons.edit,
            tooltip: 'edit',
            size: 40,
            onPressed: () => showEditComponentDialog(context, componentData),
          ),
          SizedBox(width: 12),
          OptionIcon(
            color: Colors.grey.withOpacity(0.7),
            iconData: Icons.link_off,
            tooltip: 'remove links',
            size: 40,
            onPressed: () =>
                canvasWriter.model.removeComponentConnections(componentData.id),
          ),
        ],
      ),
    );
  }

  Widget componentBottomOptions(ComponentData componentData) {
    Offset componentBottomLeftCorner = canvasReader.state.toCanvasCoordinates(
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
                canvasWriter.model.moveComponentToTheFront(componentData.id),
          ),
          SizedBox(width: 12),
          OptionIcon(
            color: Colors.grey.withOpacity(0.7),
            iconData: Icons.arrow_downward,
            tooltip: 'move to back',
            size: 24,
            shape: BoxShape.rectangle,
            onPressed: () =>
                canvasWriter.model.moveComponentToTheBack(componentData.id),
          ),
          SizedBox(width: 40),
          OptionIcon(
            color: Colors.grey.withOpacity(0.7),
            iconData: Icons.arrow_right_alt,
            tooltip: 'connect',
            size: 40,
            onPressed: () {
              isReadyToConnect = true;
              componentData.updateComponent();
            },
          ),
        ],
      ),
    );
  }

  Widget highlight(ComponentData componentData, Color color) {
    final position = componentData.position * canvasReader.state.finalScale - Offset(2, 2) + canvasReader.state.position;
    return Positioned(
      left: position.dx,
      top: position.dy,
      child: CustomPaint(
        painter: ComponentHighlightPainter(
          width: componentData.size.width * canvasReader.state.finalScale + 4,
          height: componentData.size.height * canvasReader.state.finalScale + 4,
          color: color,
        ),
      ),
    );
  }

  resizeCorner(ComponentData componentData) {
    Offset componentBottomRightCorner = canvasReader.state.toCanvasFinalCoordinates(
        componentData.position + componentData.size.bottomRight(Offset.zero));
    return Positioned(
      left: componentBottomRightCorner.dx - 12,
      top: componentBottomRightCorner.dy - 12,
      child: GestureDetector(
        onPanUpdate: (details) {
          canvasWriter.model.resizeComponent(
              componentData.id, details.delta / canvasReader.state.finalScale);
          canvasWriter.model.updateComponentLinks(componentData.id);
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

  dragVertices(ComponentData componentData) {
    return componentData.vertices.map<Widget>(
            (vertex) => dragVertex(componentData, vertex) ).toList();
  }
  dragVertex(ComponentData componentData, Offset vertex) {
    Offset vertexPosition = canvasReader.state.toCanvasFinalCoordinates(
        componentData.position + Offset(vertex.dx, vertex.dy));
    return Positioned(
      left: vertexPosition.dx - 12,
      top: vertexPosition.dy - 12,
      child: GestureDetector(
        onPanUpdate: (details) {
          final RenderBox renderBox = canvasReader.state.canvasState
              .canvasGlobalKey.currentContext?.findRenderObject() as RenderBox;
          var position = canvasReader.state.fromCanvasFinalCoordinates(renderBox.globalToLocal(details.globalPosition));
          canvasWriter.model.moveVertex(componentData.id, vertex, position);
          canvasWriter.model.updateComponentLinks(componentData.id);
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

  appendVertices(ComponentData componentData) {
    List<Offset> offsets = [];
    for (int i = 0; i < componentData.vertices.length; i++) {
      var a = componentData.vertices[i];
      var b = componentData.vertices[(i+1)%componentData.vertices.length];
      offsets.add(Offset((a.dx + b.dx) / 2, (a.dy + b.dy) / 2));
    }
    List<Widget> widgets = [];
    for (int i = 0; i < offsets.length; i++) {
      widgets.add(appendVertex(componentData, offsets[i], i+1));
    }
    return widgets;
  }

  appendVertex(ComponentData componentData, Offset vertex, int index) {
    Offset vertexPosition = canvasReader.state.toCanvasFinalCoordinates(
        componentData.position + Offset(vertex.dx, vertex.dy));
    return Positioned(
      left: vertexPosition.dx - 12,
      top: vertexPosition.dy - 12,
      child: GestureDetector(
        onTap: () {
          canvasWriter.model.addVertex(
              componentData.id, vertex, index);
          canvasWriter.model.updateComponentLinks(componentData.id);
          canvasWriter.model.updateComponent(componentData.id);
        },
        child: MouseRegion(
          cursor: SystemMouseCursors.click,
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
                  shape: BoxShape.circle,
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
    canvasReader.state.toCanvasCoordinates(componentData.position);
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
              canvasWriter.model.removeComponent(componentData.id);
              selectedComponentId = null;
            },
          ),
          SizedBox(width: 8),
          OptionIcon(
            color: Colors.grey.withOpacity(0.7),
            iconData: Icons.arrow_right_alt,
            tooltip: 'connect',
            size: 32,
            onPressed: () {
              isReadyToConnect = true;
              componentData.updateComponent();
            },
          ),
        ],
      ),
    );
  }

}
