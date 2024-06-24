import 'package:shape_editor/src/abstraction_layer/policy/base/state_policy.dart';
import 'package:shape_editor/src/abstraction_layer/policy/base_policy_set.dart';
import 'package:flutter/material.dart';
import 'package:shape_editor/shape_editor.dart';

/// Allows you to add any widget to the canvas.
mixin CanvasWidgetsPolicy on BasePolicySet implements StatePolicy, CanvasControlPolicy {
  /// Allows you to add any widget to the canvas.
  ///
  /// The widgets will be displayed under all components and links.
  ///
  /// Recommendation: use Positioned as the root widget.
  List<Widget> showCustomWidgetsOnCanvasBackground(BuildContext context) {
    return [
      CustomPaint(
        size: Size.infinite,
        painter: GridPainter(
          offset: canvasReader.state.position / canvasReader.state.scale,
          scale: canvasReader.state.scale,
          lineWidth: (canvasReader.state.scale < 1.0)
              ? canvasReader.state.scale : 1.0,
          matchParentSize: false,
          lineColor: Colors.blue[900]!,
          image: canvasReader.state.canvasState.image,
          showHorizontal: isGridVisible,
          showVertical: isGridVisible,
        ),
      ),
    ];
  }

  receiveDraggedComponent( DragTargetDetails details, BuildContext context) {
    final renderBox = context.findRenderObject() as RenderBox;
    final Offset localOffset = renderBox.globalToLocal(details.offset);
    Offset componentPosition = canvasReader.state.fromCanvasFinalCoordinates(localOffset);

    ComponentData componentDataModel = details.data;
    var newComponentData = componentDataModel.clone();
    newComponentData.position = componentPosition;

    var scale = canvasReader.model.canvasState.canvasAutoScale();
    newComponentData.size = Size(newComponentData.size.width / scale, newComponentData.size.height / scale);
    for (int i = 0; i < newComponentData.vertices.length; i++) {
      newComponentData.vertices[i] = newComponentData.vertices[i].scale(1/scale, 1/scale);
    }

    String componentId = canvasWriter.model.addComponent(newComponentData);

    canvasWriter.model.moveComponentToTheFrontWithChildren(componentId);
  }

  /// Allows you to add any widget to the canvas.
  ///
  /// The widgets will be displayed over all components and links.
  ///
  /// Recommendation: use Positioned as the root widget.
  List<Widget> showCustomWidgetsOnCanvasForeground(BuildContext context) {
    return [];
  }
}
