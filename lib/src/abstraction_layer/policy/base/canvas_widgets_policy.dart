import 'package:diagram_editor/src/abstraction_layer/policy/base/state_policy.dart';
import 'package:diagram_editor/src/abstraction_layer/policy/base_policy_set.dart';
import 'package:flutter/material.dart';
import 'package:diagram_editor/diagram_editor.dart';

/// Allows you to add any widget to the canvas.
mixin CanvasWidgetsPolicy on BasePolicySet implements StatePolicy {
  /// Allows you to add any widget to the canvas.
  ///
  /// The widgets will be displayed under all components and links.
  ///
  /// Recommendation: use Positioned as the root widget.
  List<Widget> showCustomWidgetsOnCanvasBackground(BuildContext context) {
    return [
      Visibility(
        visible: isGridVisible,
        child: CustomPaint(
          size: Size.infinite,
          painter: GridPainter(
            offset: canvasReader.state.position / canvasReader.state.scale,
            scale: canvasReader.state.scale,
            lineWidth: (canvasReader.state.scale < 1.0)
                ? canvasReader.state.scale
                : 1.0,
            matchParentSize: false,
            lineColor: Colors.blue[900]!,
          ),
        ),
      ),
      DragTarget<ComponentData>(
        builder: (_, __, ___) => SizedBox(),
        onWillAccept: (ComponentData? data) => true,
        onAcceptWithDetails: (DragTargetDetails<ComponentData> details) =>
            _onAcceptWithDetails(details, context),
      ),
    ];
  }

  _onAcceptWithDetails(
      DragTargetDetails details,
      BuildContext context,
      ) {
    final renderBox = context.findRenderObject() as RenderBox;
    final Offset localOffset = renderBox.globalToLocal(details.offset);
    Offset componentPosition = canvasReader.state.fromCanvasCoordinates(localOffset);

    ComponentData componentData = details.data;
    var componentDataCopy = componentData.clone();
    componentDataCopy.position = componentPosition;
    String componentId = canvasWriter.model.addComponent(componentDataCopy);

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
