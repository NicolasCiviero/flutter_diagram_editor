import 'package:shape_editor/shape_editor.dart';
import 'package:shape_editor/src/abstraction_layer/policy/base_policy_set.dart';
import 'package:shape_editor/src/canvas_context/model/component_data.dart';
import 'package:shape_editor/src/widget/component/arrow_body.dart';
import 'package:shape_editor/src/widget/component/oval_body.dart';
import 'package:shape_editor/src/widget/component/polygon_body.dart';
import 'package:shape_editor/src/widget/component/rect_body.dart';
import 'package:flutter/material.dart';
import 'package:shape_editor/src/widget/component/text_body.dart';
import 'package:shape_editor/src/widget/component/text_thumb.dart';

/// Allows you to specify a design of the components.
mixin ComponentDesignPolicy on BasePolicySet {
  /// Returns a widget that specifies a design of this component.
  ///
  /// Recommendation: type can by used to determine what widget should be returned.
  Widget? showComponentBody(ComponentData componentData) {
    switch (componentData.type) {
      case 'arrow':
        return ArrowBody(componentData: componentData);
      case 'polygon':
        return PolygonBody(componentData: componentData);
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
      case 'text':
        return TextBody(componentData: componentData, policy: this as PolicySet,);
      default:
        return null;
    }
  }

  Widget? showComponentThumb(ComponentData componentData) {
    switch (componentData.type) {
      case 'arrow':
        return ArrowBody(componentData: componentData);
      case 'polygon':
        return PolygonBody(componentData: componentData);
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
      case 'text':
        return TextThumb(componentData: componentData);
      default:
        return null;
    }
  }
}
