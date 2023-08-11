import 'package:shape_editor/src/abstraction_layer/policy/base/state_policy.dart';
import 'package:shape_editor/src/abstraction_layer/policy/base_policy_set.dart';
import 'package:shape_editor/src/canvas_context/model/connection.dart';
import 'package:shape_editor/src/utils/my_link_data.dart';
import 'package:shape_editor/src/utils/link_style.dart';
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

      if (isReadyToConnect) {
        isReadyToConnect = false;
        bool connected = connectComponents(selectedComponentId, componentId);
        if (connected) {
          print('connected');
          selectedComponentId = null;
        } else {
          print('not connected');
          selectedComponentId = componentId;
          highlightComponent(componentId);
        }
      } else {
        selectedComponentId = componentId;
        highlightComponent(componentId);
      }
    }
  }

  onComponentTapDown(String componentId, TapDownDetails details) {}

  onComponentTapUp(String componentId, TapUpDetails details) {}

  onComponentTapCancel(String componentId) {}

  Offset lastFocalPoint = Offset(0,0);
  onComponentScaleStart(componentId, details) {
    lastFocalPoint = details.localFocalPoint;

    hideLinkOption();
    if (isMultipleSelectionOn) {
      addComponentToMultipleSelection(componentId);
      highlightComponent(componentId);
    }
  }

  onComponentScaleUpdate(componentId, details) {
    Offset positionDelta = details.localFocalPoint - lastFocalPoint;
    if (isMultipleSelectionOn) {
      multipleSelected.forEach((compId) {
        var cmp = canvasReader.model.getComponent(compId);
        canvasWriter.model.moveComponent(compId, positionDelta);
        cmp.connections.forEach((connection) {
          if (connection is ConnectionOut &&
              multipleSelected.contains(connection.otherComponentId)) {
            canvasWriter.model.moveAllLinkMiddlePoints(
                connection.connectionId, positionDelta);
          }
        });
      });
    } else {
      canvasWriter.model.moveComponent(componentId, positionDelta);
    }
    lastFocalPoint = details.localFocalPoint;
  }

  onComponentScaleEnd(String componentId, ScaleEndDetails details) {}

  onComponentLongPress(String componentId) {}

  onComponentLongPressStart(
      String componentId, LongPressStartDetails details) {}

  onComponentLongPressMoveUpdate(
      String componentId, LongPressMoveUpdateDetails details) {}

  onComponentLongPressEnd(String componentId, LongPressEndDetails details) {}

  onComponentLongPressUp(String componentId) {}

  onComponentPointerSignal(String componentId, PointerSignalEvent event) {}


  bool connectComponents(String? sourceComponentId, String targetComponentId) {
    if (sourceComponentId == null) {
      return false;
    }
    if (sourceComponentId == targetComponentId) {
      return false;
    }
    if (canvasReader.model.getComponent(sourceComponentId).connections.any(
            (connection) =>
        (connection is ConnectionOut) &&
            (connection.otherComponentId == targetComponentId))) {
      return false;
    }

    canvasWriter.model.connectTwoComponents(
      sourceComponentId: sourceComponentId,
      targetComponentId: targetComponentId,
      linkStyle: LinkStyle(
        arrowType: ArrowType.pointedArrow,
        lineWidth: 1.5,
        backArrowType: ArrowType.centerCircle,
      ),
      data: MyLinkData(),
    );

    return true;
  }

}
