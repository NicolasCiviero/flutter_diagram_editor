import 'package:shape_editor/shape_editor.dart';
import 'package:shape_editor/src/abstraction_layer/policy/state_policy.dart';
import 'package:shape_editor/src/abstraction_layer/policy/base_policy_set.dart';
import 'package:flutter/gestures.dart';

/// Allows you to define the component behaviour on any gesture registered by the [Component].
mixin ComponentPolicy on BasePolicySet implements StatePolicy  {
  onComponentTap(String componentId) {
    if (isMultipleSelectionOn) {
      if (multipleSelected.contains(componentId)) {
        removeComponentFromMultipleSelection(componentId);
        hideComponentHighlight(componentId);
      } else {
        addComponentToMultipleSelection(componentId);
        highlightComponent(componentId);
      }
    } else {
      hideAllHighlights();

      selectedComponentId = componentId;
      highlightComponent(componentId);

      final componentData = modelReader.getComponent(componentId);
      modelWriter.sendEvent(ComponentEvent(ComponentEvent.selected, componentData));
    }
  }

  onComponentTapDown(String componentId, TapDownDetails details) {
    if (isMultipleSelectionOn) {
      if (multipleSelected.contains(componentId)) {
        removeComponentFromMultipleSelection(componentId);
        hideComponentHighlight(componentId);
      } else {
        addComponentToMultipleSelection(componentId);
        highlightComponent(componentId);
      }
    } else {
      hideAllHighlights();
      selectedComponentId = componentId;
      highlightComponent(componentId);
    }
  }

  onComponentTapUp(String componentId, TapUpDetails details) {}

  onComponentTapCancel(String componentId) {}

  Offset lastFocalPoint = Offset(0,0);
  onComponentScaleStart(componentId, details) {
    if (selectedComponentId != componentId) return;
    lastFocalPoint = details.localFocalPoint;

    if (isMultipleSelectionOn) {
      addComponentToMultipleSelection(componentId);
      highlightComponent(componentId);
    }
  }

  onComponentScaleUpdate(componentId, details) {
    if (selectedComponentId != componentId) return;

    if (details.scale != 1) return;
    Offset positionDelta = details.localFocalPoint - lastFocalPoint;
    if (isMultipleSelectionOn) {
      multipleSelected.forEach((compId) {
        //var cmp = canvasReader.model.getComponent(compId);
        modelWriter.moveComponent(compId, positionDelta);
        //TODO: possible changes when vertices have clusters
      });
    } else {
      modelWriter.moveComponent(componentId, positionDelta);
    }
    lastFocalPoint = details.localFocalPoint;
  }

  onComponentScaleEnd(String componentId, ScaleEndDetails details) {
    modelWriter.moveComponentEnd(componentId);
  }

  onComponentLongPress(String componentId) {}

  onComponentLongPressStart(
      String componentId, LongPressStartDetails details) {}

  onComponentLongPressMoveUpdate(
      String componentId, LongPressMoveUpdateDetails details) {}

  onComponentLongPressEnd(String componentId, LongPressEndDetails details) {}

  onComponentLongPressUp(String componentId) {}

  onComponentPointerSignal(String componentId, PointerSignalEvent event) {}

}
