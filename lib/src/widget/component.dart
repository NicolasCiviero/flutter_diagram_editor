import 'package:shape_editor/src/abstraction_layer/policy/policy_set.dart';
import 'package:shape_editor/src/canvas_context/canvas_state.dart';
import 'package:shape_editor/src/canvas_context/model/component_data.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Component extends StatelessWidget {
  final PolicySet policy;

  /// Fundamental building unit of a diagram. Represents one component on the canvas.
  const Component({
    Key? key,
    required this.policy,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final componentData = Provider.of<ComponentData>(context);
    final canvasState = Provider.of<CanvasState>(context);
    final position = canvasState.toCanvasFinalCoordinates(componentData.position);

    return Positioned(
      left: position.dx,
      top: position.dy,
      width: canvasState.canvasFinalScale() * componentData.size.width,
      height: canvasState.canvasFinalScale() * componentData.size.height,
      child: RepaintBoundary(
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned(
              left: 0,
              top: 0,
              width: componentData.size.width * canvasState.canvasFinalScale(),
              height: componentData.size.height * canvasState.canvasFinalScale(),
              child: Listener(
                onPointerSignal: (PointerSignalEvent event) {
                  policy.onComponentPointerSignal(componentData.id, event);
                },
                child: GestureDetector(
                  //behavior: HitTestBehavior.translucent,
                  child: policy.showComponentBody(componentData) ?? Container(),
                  onTap: () => policy.onComponentTap(componentData.id),
                  onTapDown: (details) => policy.onComponentTapDown(componentData.id, details),
                  onTapUp: (details) => policy.onComponentTapUp(componentData.id, details),
                  onTapCancel: () => policy.onComponentTapCancel(componentData.id),
                  onScaleStart: (details) => policy.onComponentScaleStart(componentData.id, details),
                  onScaleUpdate: (details) => policy.onComponentScaleUpdate(componentData.id, details),
                  onScaleEnd: (details) => policy.onComponentScaleEnd(componentData.id, details),
                  onLongPress: () => policy.onComponentLongPress(componentData.id),
                  onLongPressStart: (details) => policy.onComponentLongPressStart(componentData.id, details),
                  onLongPressMoveUpdate: (details) => policy.onComponentLongPressMoveUpdate(componentData.id, details),
                  onLongPressEnd: (details) => policy.onComponentLongPressEnd(componentData.id, details),
                  onLongPressUp: () => policy.onComponentLongPressUp(componentData.id),
                ),
              ),
            ),
            policy.showCustomWidgetWithComponentData(context, componentData),
          ],
        ),
      ),
    );
  }
}
