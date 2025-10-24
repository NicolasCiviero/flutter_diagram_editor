import 'package:shape_editor/shape_editor.dart';
import 'package:shape_editor/src/abstraction_layer/policy/base/state_policy.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

/// Allows you to define the canvas behaviour on any gesture registered by the [Canvas].
mixin CanvasPolicy implements StatePolicy {
  onCanvasTap() {
    multipleSelected = [];

    if (selectedComponentId != null) {
      final componentData = modelReader.getComponent(selectedComponentId!);
      modelWriter.sendEvent(ComponentEvent(ComponentEvent.deselected, componentData));
    }
    selectedComponentId = null;
    hideAllHighlights();
  }

  onCanvasTapDown(TapDownDetails details) {}

  onCanvasTapUp(TapUpDetails details) {}

  onCanvasTapCancel() {}

  onCanvasLongPress() {}

  onCanvasScaleStart(ScaleStartDetails details) {}

  onCanvasScaleUpdate(ScaleUpdateDetails details) {}

  onCanvasScaleEnd(ScaleEndDetails details) {}

  onCanvasLongPressStart(LongPressStartDetails details) {}

  onCanvasLongPressMoveUpdate(LongPressMoveUpdateDetails details) {}

  onCanvasLongPressEnd(LongPressEndDetails details) {}

  onCanvasLongPressUp() {}

  onCanvasPointerSignal(PointerSignalEvent event) {}
}
