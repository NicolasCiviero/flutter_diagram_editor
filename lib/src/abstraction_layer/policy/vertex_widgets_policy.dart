import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shape_editor/src/abstraction_layer/policy/clustering_policy.dart';
import 'package:shape_editor/src/abstraction_layer/policy/state_policy.dart';
import 'package:shape_editor/src/abstraction_layer/policy/base_policy_set.dart';
import 'package:shape_editor/src/canvas_context/model/component_data.dart';
import 'package:shape_editor/src/canvas_context/model/vertex.dart';

mixin VertexWidgetsPolicy on BasePolicySet implements StatePolicy {
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
        componentData.position +
            Offset(vertex.position.dx, vertex.position.dy));

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
            (modelReader.canvasModel.policySet as dynamic)
                .detachVertexFromCluster(vertex);
          }

          modelWriter.moveVertex(componentData.id, vertex, position);

          if (_isShiftPressed()) {
            (modelReader.canvasModel.policySet as dynamic)
                .findClusterableVertices(
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
}
