import 'package:shape_editor/src/abstraction_layer/policy/base_policy_set.dart';
import 'package:flutter/material.dart';

/// Allows you to prepare canvas before anything.
mixin InitPolicy on BasePolicySet {
  /// Allows you to prepare diagram editor before anything.
  ///
  /// It's possible to change canvas state here. Or load a diagram.
  initializeDiagramEditor() {
    canvasWriter.state.setCanvasColor(Colors.white);
  }
}
