import 'dart:collection';
import 'dart:convert';

import 'package:shape_editor/src/canvas_context/canvas_model.dart';
import 'package:shape_editor/src/canvas_context/canvas_state.dart';
import 'package:shape_editor/src/canvas_context/model/component_data.dart';
import 'package:flutter/material.dart';

class CanvasModelReader {
  final CanvasModel canvasModel;
  final CanvasState canvasState;

  /// Allows you to read data from the model (component and vertexCluster data).
  CanvasModelReader(this.canvasModel, this.canvasState);

  /// Returns [true] if a component with provided [id] exists. Returns [false] otherwise.
  bool componentExist(String id) {
    return canvasModel.componentExists(id);
  }

  /// Returns a component with [id].
  ///
  /// If there is no component with [id] in the model, it returns null.
  ComponentData getComponent(String id) {
    assert(componentExist(id), 'model does not contain this component id: $id');
    return canvasModel.getComponent(id);
  }

  /// Returns all existing components in the model as a [HashMap].
  ///
  /// Key of the HashMap element is component's id.
  HashMap<String, ComponentData> getAllComponents() {
    return canvasModel.getAllComponents();
  }

  /// Returns [String] that contains serialized diagram in JSON format.
  ///
  /// To serialize dynamic data of components [toJson] function must be defined.
  String serializeDiagram() {
    return jsonEncode(canvasModel.getDiagram());
  }
}
