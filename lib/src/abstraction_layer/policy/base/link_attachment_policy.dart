import 'package:diagram_editor/src/abstraction_layer/policy/base_policy_set.dart';
import 'package:diagram_editor/src/canvas_context/model/component_data.dart';
import 'package:flutter/material.dart';

mixin LinkAttachmentPolicy on BasePolicySet {
  /// Calculates an alignment of link endpoint on a component from ComponentData and targetPoint (nearest link point from this component).
  ///
  /// With no implementation the link will attach to center of the component.
  Alignment getLinkEndpointAlignment(
      ComponentData componentData,
      Offset targetPoint,
      ) {
    Offset pointPosition = targetPoint -
        (componentData.position + componentData.size.center(Offset.zero));
    pointPosition = Offset(
      pointPosition.dx / componentData.size.width,
      pointPosition.dy / componentData.size.height,
    );

    switch (componentData.type) {
      case 'oval':
        Offset pointAlignment = pointPosition / pointPosition.distance;

        return Alignment(pointAlignment.dx, pointAlignment.dy);
        break;
      case 'crystal':
        Offset pointAlignment =
            pointPosition / (pointPosition.dx.abs() + pointPosition.dy.abs());

        return Alignment(pointAlignment.dx, pointAlignment.dy);
        break;

      default:
        Offset pointAlignment;
        if (pointPosition.dx.abs() >= pointPosition.dy.abs()) {
          pointAlignment = Offset(pointPosition.dx / pointPosition.dx.abs(),
              pointPosition.dy / pointPosition.dx.abs());
        } else {
          pointAlignment = Offset(pointPosition.dx / pointPosition.dy.abs(),
              pointPosition.dy / pointPosition.dy.abs());
        }
        return Alignment(pointAlignment.dx, pointAlignment.dy);
        break;
    }
  }
}
