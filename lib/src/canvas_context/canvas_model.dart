import 'dart:collection';

import 'package:shape_editor/src/abstraction_layer/policy/base/policy_set.dart';
import 'package:shape_editor/src/canvas_context/model/component_data.dart';
import 'package:shape_editor/src/canvas_context/model/diagram_data.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import 'model/vertex.dart';
import 'model/vertex_cluster.dart';

class CanvasModel with ChangeNotifier {
  HashMap<String, ComponentData> components = HashMap();
  List<VertexCluster> clusters = [];
  PolicySet policySet;

  CanvasModel(this.policySet);

  DiagramData getDiagram() {
    return DiagramData(
      components: components.values.toList(),
    );
  }

  updateCanvas() {
    notifyListeners();
  }

  bool componentExists(String? id) {
    if (id == null) return false;
    return components.containsKey(id);
  }

  ComponentData getComponent(String id) {
    return components[id]!;
  }

  HashMap<String, ComponentData> getAllComponents() {
    return components;
  }

  /// Returns componentData id. useful when the id is set automatically.
  String addComponent(ComponentData componentData) {
    components[componentData.id] = componentData;
    notifyListeners();
    return componentData.id;
  }

  removeComponent(String id) {
    removeComponentFromClusters(id);
    components.remove(id);
    notifyListeners();
  }

  removeComponentFromClusters(String id) {
    assert(
        componentExists(id), 'model does not contain this component id: $id');
    final component = getComponent(id);
    for (final vertex in component.vertices) {
      component.vertexClusters[vertex.id]?.removeVertex(vertex);
    }
  }

  removeAllComponents() {
    components.clear();
    notifyListeners();
  }

  setComponentZOrder(String componentId, int zOrder) {
    getComponent(componentId).zOrder = zOrder;
    notifyListeners();
  }

  /// You cannot use is during any movement, because the order will change so the moving item will change.
  /// Returns new zOrder
  int moveComponentToTheFront(String componentId) {
    int zOrderMax = getComponent(componentId).zOrder;
    components.values.forEach((component) {
      if (component.zOrder > zOrderMax) {
        zOrderMax = component.zOrder;
      }
    });
    getComponent(componentId).zOrder = zOrderMax + 1;
    notifyListeners();
    return zOrderMax + 1;
  }

  /// You cannot use is during any movement, because the order will change so the moving item will change.
  /// /// Returns new zOrder
  int moveComponentToTheBack(String componentId) {
    int zOrderMin = getComponent(componentId).zOrder;
    components.values.forEach((component) {
      if (component.zOrder < zOrderMin) {
        zOrderMin = component.zOrder;
      }
    });
    getComponent(componentId).zOrder = zOrderMin - 1;
    notifyListeners();
    return zOrderMin - 1;
  }

  void updateComponentClusters(String componentId) {
    assert(componentExists(componentId),
        'model does not contain this component id: $componentId');
    final component = getComponent(componentId);
    for (final vertex in component.vertices) {
      updateVertexCluster(componentId, vertex);
    }
  }

  void updateVertexCluster(String componentId, Vertex vertex) {
    assert(componentExists(componentId),
        'model does not contain this component id: $componentId');
    final component = getComponent(componentId);
    final absolutePosition = component.position + vertex.position;
    final cluster = component.vertexClusters[vertex.id];
    if (cluster == null) return;

    for (final v in cluster.vertices) {
      if (v.id == vertex.id) continue;
      v.componentData.moveVertex(v, absolutePosition);
    }
    ;
  }
}
