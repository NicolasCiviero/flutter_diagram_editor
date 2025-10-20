import 'dart:collection';

import 'package:shape_editor/src/abstraction_layer/policy/base/policy_set.dart';
import 'package:shape_editor/src/canvas_context/model/component_data.dart';
import 'package:shape_editor/src/canvas_context/model/connection.dart';
import 'package:shape_editor/src/canvas_context/model/diagram_data.dart';
import 'package:shape_editor/src/canvas_context/model/link_data.dart';
import 'package:shape_editor/src/utils/link_style.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

class CanvasModel with ChangeNotifier {
  Uuid _uuid = Uuid();
  HashMap<String, ComponentData> components = HashMap();
  HashMap<String, LinkData> links = HashMap();
  PolicySet policySet;

  CanvasModel(this.policySet);

  DiagramData getDiagram() {
    return DiagramData(
      components: components.values.toList(),
      links: links.values.toList(),
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

  bool linkExists(String id) {
    return links.containsKey(id);
  }

  LinkData getLink(String id) {
    return links[id]!;
  }

  HashMap<String, LinkData> getAllLinks() {
    return links;
  }

  /// Returns componentData id. useful when the id is set automatically.
  String addComponent(ComponentData componentData) {
    components[componentData.id] = componentData;
    notifyListeners();
    return componentData.id;
  }

  removeComponent(String id) {
    removeComponentConnections(id);
    components.remove(id);
    notifyListeners();
  }

  removeComponentConnections(String id) {
    assert(components.keys.contains(id));

    List<String> _linksToRemove = [];

    getComponent(id).connections.forEach((connection) {
      _linksToRemove.add(connection.connectionId);
    });

    _linksToRemove.forEach(removeLink);
    notifyListeners();
  }

  removeAllComponents() {
    links.clear();
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

  addLink(LinkData linkData) {
    links[linkData.id] = linkData;
    notifyListeners();
  }

  removeLink(String linkId) {
    getComponent(getLink(linkId).sourceComponentId).removeConnection(linkId);
    getComponent(getLink(linkId).targetComponentId).removeConnection(linkId);
    links.remove(linkId);
    notifyListeners();
  }

  removeAllLinks() {
    components.values.forEach((component) {
      removeComponentConnections(component.id);
    });
  }

}
