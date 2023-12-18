import 'package:shape_editor/src/abstraction_layer/policy/base_policy_set.dart';
import 'package:shape_editor/src/canvas_context/model/component_data.dart';
import 'package:shape_editor/src/widget/component/oval_body.dart';
import 'package:shape_editor/src/widget/component/polygon_body.dart';
import 'package:shape_editor/src/widget/component/rect_body.dart';
import 'package:flutter/material.dart';

/// Allows you to specify a design of the components.
mixin ComponentDesignPolicy on BasePolicySet {
  /// Returns a widget that specifies a design of this component.
  ///
  /// Recommendation: type can by used to determine what widget should be returned.
  Widget? showComponentBody(ComponentData componentData, double scale) {
    switch (componentData.type) {
      case 'polygon':
        return PolygonBody(componentData: componentData, scale: scale);
      case 'rect':
        return RectBody(componentData: componentData);
      case 'rectangle':
        return RectBody(componentData: componentData);
      case 'ellipse':
        return OvalBody(componentData: componentData);
      case 'body':
        return RectBody(componentData: componentData);
      case 'junction':
        return OvalBody(componentData: componentData);
      default:
        return null;
    }
  }
}
