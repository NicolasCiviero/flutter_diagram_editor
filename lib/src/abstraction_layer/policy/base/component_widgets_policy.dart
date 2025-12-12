import 'package:shape_editor/src/abstraction_layer/policy/base/clustering_policy.dart';
import 'package:shape_editor/src/abstraction_layer/policy/base/state_policy.dart';
import 'package:shape_editor/src/abstraction_layer/policy/base_policy_set.dart';
import 'package:shape_editor/src/canvas_context/model/component_data.dart';
import 'package:shape_editor/src/utils/painter/arrow_highlight_painter.dart';
import 'package:shape_editor/src/widget/option_icon.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:shape_editor/shape_editor.dart';
import 'package:flutter/services.dart'; // For HardwareKeyboard

import '../../../canvas_context/model/vertex.dart';

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
          if (isPolygon) ...appendVertices(componentData),
          if (hasVertices) ...dragVertices(componentData),
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
          // SizedBox(width: 12),
          // OptionIcon(
          //   color: Colors.grey.withOpacity(0.7),
          //   iconData: Icons.copy,
          //   tooltip: 'duplicate',
          //   size: 40,
          //   onPressed: () {
          //     String newId = componentData.clone().id;
          //     modelWriter.moveComponentToTheFront(newId);
          //     selectedComponentId = newId;
          //     hideComponentHighlight(componentData.id);
          //     highlightComponent(newId);
          //   },
          // ),
          // SizedBox(width: 12),
          // OptionIcon(
          //   color: Colors.grey.withOpacity(0.7),
          //   iconData: Icons.edit,
          //   tooltip: 'edit',
          //   size: 40,
          //   onPressed: () => showEditComponentDialog(context, componentData),
          // ),
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

  //Helper to check shift status
  bool _isShiftPressed() {
    return HardwareKeyboard.instance.logicalKeysPressed
            .contains(LogicalKeyboardKey.shiftLeft) ||
        HardwareKeyboard.instance.logicalKeysPressed
            .contains(LogicalKeyboardKey.shiftRight);
  }

  dragVertices(ComponentData componentData) {
    return componentData.vertices
        .map<Widget>((vertex) => dragVertex(componentData, vertex))
        .toList();
  }

  dragVertex(ComponentData componentData, Vertex vertex) {
    Offset vertexPosition = stateReader.toCanvasFinalCoordinates(
        componentData.position + Offset(vertex.position.dx, vertex.position.dy));

    bool showClusterArea = _isShiftPressed() && selectedVertex == vertex;
    double radius = ClusteringPolicy.userClusteringDistance;

    return Positioned(
      left: vertexPosition.dx - (showClusterArea ? radius : 12),
      top: vertexPosition.dy - (showClusterArea ? radius : 12),
      child: GestureDetector(
        onTap: () {},
        onPanStart: (details) {
          selectedVertex = vertex;
        },
        onPanUpdate: (details) {
          final RenderBox renderBox = stateReader
              .canvasState.canvasGlobalKey.currentContext
              ?.findRenderObject() as RenderBox;
          var position = stateReader.fromCanvasFinalCoordinates(
              renderBox.globalToLocal(details.globalPosition));

          if (!_isShiftPressed()) {
            modelReader.canvasModel.policySet.detachVertexFromCluster(vertex);
          }

          modelWriter.moveVertex(componentData.id, vertex, position);

          if (_isShiftPressed()) {
            modelReader.canvasModel.policySet.findClusterableVertices(
                vertex, radius / stateReader.finalScale);
          }
        },
        onPanEnd: (details) {
          modelWriter.moveVertexEnd(componentData.id);
          selectedVertex = null;
        },
        onDoubleTap: () {
          modelWriter.removeVertex(componentData.id, vertex);
          modelWriter.updateComponent(componentData.id);
        },
        child: MouseRegion(
          cursor: SystemMouseCursors.resizeDownRight,
          child: Container(
            width: showClusterArea ? radius * 2 : 24,
            height: showClusterArea ? radius * 2 : 24,
            color: Colors.transparent,
            child: Center(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  if (showClusterArea)
                    Container(
                      width: radius * 2,
                      height: radius * 2,
                      decoration: BoxDecoration(
                        color: ClusteringPolicy.clusterIndicatorColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      //color: componentData.vertexClusters[vertex.id] == null ? Colors.white : Colors.lime,
                      color: Colors.white,
                      border: Border.all(color: Colors.grey[800]!),
                    ),
                  ),
                ],
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
      var b = componentData.vertices[(i + 1) % componentData.vertices.length];
      offsets.add(Offset((a.position.dx + b.position.dx) / 2,
          (a.position.dy + b.position.dy) / 2));
    }
    List<Widget> widgets = [];
    for (int i = 0; i < offsets.length; i++) {
      widgets.add(appendVertex(componentData, offsets[i], i + 1));
    }
    return widgets;
  }

  appendVertex(ComponentData componentData, Offset vertex, int index) {
    Offset vertexPosition = stateReader.toCanvasFinalCoordinates(
        componentData.position + Offset(vertex.dx, vertex.dy));
    return Positioned(
      left: vertexPosition.dx - 12,
      top: vertexPosition.dy - 12,
      child: GestureDetector(
        onTap: () {
          modelWriter.addVertex(componentData.id, vertex, index);
          modelWriter.updateComponent(componentData.id);
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
