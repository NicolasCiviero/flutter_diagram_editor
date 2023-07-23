import 'package:diagram_editor/src/abstraction_layer/policy/base/state_policy.dart';
import 'package:diagram_editor/src/abstraction_layer/policy/base_policy_set.dart';
import 'package:flutter/gestures.dart';

/// Allows you to define the link behaviour on any gesture registered by the [Link].
mixin LinkPolicy on BasePolicySet implements StatePolicy {
  onLinkTap(String linkId) {}

  onLinkTapDown(String linkId, TapDownDetails details) {}

  onLinkTapUp(String linkId, TapUpDetails details) {
    hideLinkOption();
    canvasWriter.model.hideAllLinkJoints();
    canvasWriter.model.showLinkJoints(linkId);

    showLinkOption(linkId,
        canvasReader.state.fromCanvasCoordinates(details.localPosition));
  }

  onLinkTapCancel(String linkId) {}

  var segmentIndex;
  onLinkScaleStart(String linkId, ScaleStartDetails details) {
    hideLinkOption();
    canvasWriter.model.hideAllLinkJoints();
    canvasWriter.model.showLinkJoints(linkId);
    segmentIndex = canvasReader.model
        .determineLinkSegmentIndex(linkId, details.localFocalPoint);
    if (segmentIndex != null) {
      canvasWriter.model
          .insertLinkMiddlePoint(linkId, details.localFocalPoint, segmentIndex);
      canvasWriter.model.updateLink(linkId);
    }
  }

  onLinkScaleUpdate(String linkId, ScaleUpdateDetails details) {
    if (segmentIndex != null) {
      canvasWriter.model.setLinkMiddlePointPosition(
          linkId, details.localFocalPoint, segmentIndex);
      canvasWriter.model.updateLink(linkId);
    }
  }

  onLinkScaleEnd(String linkId, ScaleEndDetails details) {}

  onLinkLongPress(String linkId) {}

  onLinkLongPressStart(String linkId, LongPressStartDetails details) {
    hideLinkOption();
    canvasWriter.model.hideAllLinkJoints();
    canvasWriter.model.showLinkJoints(linkId);
    segmentIndex = canvasReader.model
        .determineLinkSegmentIndex(linkId, details.localPosition);
    if (segmentIndex != null) {
      canvasWriter.model
          .insertLinkMiddlePoint(linkId, details.localPosition, segmentIndex);
      canvasWriter.model.updateLink(linkId);
    }
  }

  onLinkLongPressMoveUpdate(String linkId, LongPressMoveUpdateDetails details) {
    if (segmentIndex != null) {
      canvasWriter.model.setLinkMiddlePointPosition(
          linkId, details.localPosition, segmentIndex);
      canvasWriter.model.updateLink(linkId);
    }
  }

  onLinkLongPressEnd(String linkId, LongPressEndDetails details) {}

  onLinkLongPressUp(String linkId) {}

  onLinkPointerSignal(String linkId, PointerSignalEvent event) {}
}
