import 'dart:convert';

import 'package:shape_editor/src/canvas_context/canvas_model.dart';
import 'package:shape_editor/src/canvas_context/canvas_state.dart';
import 'package:shape_editor/src/canvas_context/model/component_data.dart';
import 'package:shape_editor/src/canvas_context/model/diagram_data.dart';
import 'package:shape_editor/src/utils/link_style.dart';
import 'package:flutter/material.dart';

class ModelWriter {
  final CanvasModel _canvasModel;
  final CanvasState _canvasState;

  ModelWriter(this._canvasModel, this._canvasState);
}

class CanvasModelWriter extends ModelWriter
    with ComponentWriter, LinkWriter, ConnectionWriter {
  /// Allows you to change the model.
  CanvasModelWriter(CanvasModel canvasModel, CanvasState canvasState)
      : super(canvasModel, canvasState);

  /// Adds [componentData] to the canvas model.
  ///
  /// Returns component's id (if [componentData] doesn't contain id, new id if generated).
  /// Canvas is updated and this new components is shown on it.
  String addComponent(ComponentData componentData) {
    _canvasState.componentUpdateEvent.broadcast(ComponentEvent(ComponentEvent.created, componentData));
    return _canvasModel.addComponent(componentData);
  }

  /// Removes a component with [componentId] and all its links.
  removeComponent(String componentId) {
    _checkComponentId(componentId);
    final component = _canvasModel.getComponent(componentId);
    removeComponentParent(componentId);
    _removeParentFromChildren(componentId);
    _canvasModel.removeComponent(componentId);
    _canvasState.componentUpdateEvent.broadcast(ComponentEvent(ComponentEvent.removed, component));
  }

  /// Removes a component with [componentId] and also removes all its children components.
  removeComponentWithChildren(String componentId) {
    _checkComponentId(componentId);
    List<String> componentsToRemove = [];
    _removeComponentWithChildren(componentId, componentsToRemove);
    componentsToRemove.reversed.forEach(removeComponent);
  }

  _removeComponentWithChildren(String componentId, List<String> toRemove) {
    toRemove.add(componentId);
    _canvasModel.getComponent(componentId).childrenIds.forEach((childId) {
      _removeComponentWithChildren(childId, toRemove);
    });
  }

  /// Removes all components in the model. All links are also removed with the components.
  removeAllComponents() {
    _canvasModel.removeAllComponents();
  }

  /// Removes link with [linkId] from the model.
  ///
  /// Also deletes the connection information from both components which were connected with this link.
  removeLink(String linkId) {
    assert(_canvasModel.linkExists(linkId),
        'model does not contain this link id: $linkId');
    _canvasModel.removeLink(linkId);
  }

  /// Removes all links from the model.
  removeAllLinks() {
    _canvasModel.removeAllLinks();
  }

  /// Loads a diagram from json string.
  ///
  /// !!! Beware of passing correct json string.
  /// The diagram may become unstable if any data are manipulated.
  /// Deleting existing diagram is recommended.
  deserializeDiagram(
    String json, {
    Function(Map<String, dynamic> json)? decodeCustomComponentData,
    Function(Map<String, dynamic> json)? decodeCustomLinkData,
  }) {
    final diagram = DiagramData.fromJson(
      jsonDecode(json),
      decodeCustomComponentData: decodeCustomComponentData,
      decodeCustomLinkData: decodeCustomLinkData,
    );
    for (final componentData in diagram.components) {
      _canvasModel.components[componentData.id] = componentData;
    }
    for (final linkData in diagram.links) {
      _canvasModel.links[linkData.id] = linkData;
      linkData.updateLink();
    }
    _canvasModel.updateCanvas();
  }
}

mixin ComponentWriter on ModelWriter {
  /// Update a component with [componentId].
  ///
  /// It calls [notifyListeners] function of [ChangeNotifier] on [ComponentData].
  updateComponent(String? componentId) {
    _checkComponentId(componentId);
    if (componentId == null) return;
    final component = _canvasModel.getComponent(componentId);
    component.updateComponent();
    _canvasState.componentUpdateEvent.broadcast(ComponentEvent(ComponentEvent.update, component));
  }

  /// Sets the position of the component to [position] value.
  setComponentPosition(String componentId, Offset position) {
    _checkComponentId(componentId);
    final component = _canvasModel.getComponent(componentId);
    component.setPosition(position);
    _canvasModel.updateLinks(componentId);
    _canvasState.componentUpdateEvent.broadcast(ComponentEvent(ComponentEvent.setPosition, component));
  }

  /// Translates the component by [offset] value.
  moveComponent(String componentId, Offset offset) {
    _checkComponentId(componentId);
    final component = _canvasModel.getComponent(componentId);
    if (component.locked) return;
    component.move(offset / _canvasState.canvasFinalScale());
    _canvasModel.updateLinks(componentId);
    _canvasState.componentUpdateEvent.broadcast(ComponentEvent(ComponentEvent.move, component));
  }

  moveComponentEnd(String componentId){
    final component = _canvasModel.getComponent(componentId);
    _canvasState.componentUpdateEvent.broadcast(ComponentEvent(ComponentEvent.moveEnded, component));
  }

  /// Moves the component's vertex to [vertexLocation] value.
  moveVertex(String componentId, Offset vertex, Offset vertexLocation) {
    _checkComponentId(componentId);
    final component = _canvasModel.getComponent(componentId);
    component.moveVertex(vertex, vertexLocation);
    _canvasModel.updateLinks(componentId);
    _canvasState.componentUpdateEvent.broadcast(ComponentEvent(ComponentEvent.moveVertex, component));
  }

  moveVertexEnd(String componentId) {
    final component = _canvasModel.getComponent(componentId);
    _canvasState.componentUpdateEvent.broadcast(ComponentEvent(ComponentEvent.moveVertexEnded, component));
  }

  /// Translates the component's vertex by [offset] value.
  addVertex(String componentId, Offset vertex, int index) {
    _checkComponentId(componentId);
    final component = _canvasModel.getComponent(componentId);
    component.addVertex(vertex, index);
    _canvasModel.updateLinks(componentId);
    _canvasState.componentUpdateEvent.broadcast(ComponentEvent(ComponentEvent.addVertex, component));
  }

  /// Translates the component by [offset] value and all its children as well.
  moveComponentWithChildren(String componentId, Offset offset) {
    _checkComponentId(componentId);
    moveComponent(componentId, offset);
    _canvasModel.getComponent(componentId).childrenIds.forEach((childId) {
      moveComponentWithChildren(childId, offset);
    });
  }

  /// Removes all connections that the component with [componentId] has.
  removeComponentConnections(String componentId) {
    _checkComponentId(componentId);
    _canvasModel.removeComponentConnections(componentId);
  }

  /// Updates all links (their position) connected to the component with [componentId].
  ///
  /// Use it when the component is somehow changed (its size or position) and the links are not updated to their proper positions.
  updateComponentLinks(String componentId) {
    _checkComponentId(componentId);
    _canvasModel.updateLinks(componentId);
  }

  /// Sets the component's z-order to [zOrder].
  ///
  /// Higher z-order means that the component will be shown on top of another component with lower z-order.
  setComponentZOrder(String componentId, int zOrder) {
    _checkComponentId(componentId);
    _canvasModel.setComponentZOrder(componentId, zOrder);
  }

  /// Sets the components's z-order to the highest z-order value of all components +1.
  int moveComponentToTheFront(String componentId) {
    _checkComponentId(componentId);
    return _canvasModel.moveComponentToTheFront(componentId);
  }

  /// Sets the components's z-order to the highest z-order value of all components +1 and sets z-order of its children to +2...
  int moveComponentToTheFrontWithChildren(String componentId) {
    _checkComponentId(componentId);
    int zOrder = moveComponentToTheFront(componentId);
    _setZOrderToChildren(componentId, zOrder);
    return zOrder;
  }

  _setZOrderToChildren(String componentId, int zOrder) {
    _checkComponentId(componentId);
    setComponentZOrder(componentId, zOrder);
    _canvasModel.getComponent(componentId).childrenIds.forEach((childId) {
      _setZOrderToChildren(childId, zOrder + 1);
    });
  }

  /// Sets the components's z-order to the lowest z-order value of all components -1.
  int moveComponentToTheBack(String componentId) {
    _checkComponentId(componentId);
    return _canvasModel.moveComponentToTheBack(componentId);
  }

  /// Sets the components's z-order to the lowest z-order value of all components -1 and sets z-order of its children to one more than the component and their children to one more..
  int moveComponentToTheBackWithChildren(String componentId) {
    _checkComponentId(componentId);
    int zOrder = moveComponentToTheBack(componentId);
    _setZOrderToChildren(componentId, zOrder);
    return zOrder;
  }

  /// Changes the component's size by [deltaSize].
  ///
  /// You cannot change its size to smaller than [minSize] defined on the component.
  resizeComponent(String componentId, Offset deltaSize) {
    _checkComponentId(componentId);
    final component = _canvasModel.getComponent(componentId);
    component.resizeDelta(deltaSize);
    _canvasState.componentUpdateEvent.broadcast(ComponentEvent(ComponentEvent.resize, component));
  }

  resizeComponentEnd(String componentId){
    final component = _canvasModel.getComponent(componentId);
    _canvasState.componentUpdateEvent.broadcast(ComponentEvent(ComponentEvent.resizeEnded, component));
  }

  /// Sets the component's to [size].
  setComponentSize(String componentId, Size size) {
    _checkComponentId(componentId);
    _canvasModel.getComponent(componentId).setSize(size);
  }

  /// Sets the component's parent.
  ///
  /// It's not possible to make a parent-child loop. (its ancestor cannot be its child)
  setComponentParent(String componentId, String parentId) {
    _checkComponentId(componentId);
    removeComponentParent(componentId);
    if (_checkParentChildLoop(componentId, parentId)) {
      _canvasModel.getComponent(componentId).setParent(parentId);
      _canvasModel.getComponent(parentId).addChild(componentId);
    }
  }

  bool _checkParentChildLoop(String componentId, String parentId) {
    if (componentId == parentId) return false;
    final _parentIdOfParent = _canvasModel.getComponent(parentId).parentId;
    if (_parentIdOfParent != null) {
      return _checkParentChildLoop(componentId, _parentIdOfParent);
    }

    return true;
  }

  /// Removes the component's parent from a component.
  ///
  /// It also removes child from former parent.
  removeComponentParent(String componentId) {
    _checkComponentId(componentId);
    final _parentId = _canvasModel.getComponent(componentId).parentId;
    if (_parentId != null) {
      _canvasModel.getComponent(componentId).removeParent();
      _canvasModel.getComponent(_parentId).removeChild(componentId);
    }
  }

  _removeParentFromChildren(componentId) {
    _checkComponentId(componentId);
    final _component = _canvasModel.getComponent(componentId);
    final _childrenToRemove = List.from(_component.childrenIds);
    _childrenToRemove.forEach((childId) {
      removeComponentParent(childId);
    });
  }

  _checkComponentId(String? id){
    assert(_canvasModel.componentExists(id),
      'model does not contain this component id: $id');
  }
}

mixin LinkWriter on ModelWriter {
  /// Makes all link's joints visible.
  showLinkJoints(String linkId) {
    assert(_canvasModel.linkExists(linkId),
        'model does not contain this link id: $linkId');
    _canvasModel.getLink(linkId).showJoints();
  }

  /// Makes all link's joints invisible.
  hideLinkJoints(String linkId) {
    assert(_canvasModel.linkExists(linkId),
        'model does not contain this link id: $linkId');
    _canvasModel.getLink(linkId).hideJoints();
  }

  /// Makes invisible all link joints on the canvas.
  hideAllLinkJoints() {
    _canvasModel.links.values.forEach((link) {
      link.hideJoints();
    });
  }

  /// Updates the link.
  ///
  /// Use it when something is changed and the link is not updated to its proper positions.
  updateLink(String linkId) {
    assert(_canvasModel.linkExists(linkId),
        'model does not contain this link id: $linkId');
    _canvasModel.updateLinks(_canvasModel.getLink(linkId).sourceComponentId);
    _canvasModel.updateLinks(_canvasModel.getLink(linkId).targetComponentId);
  }

  /// Creates a new link's joint on [point] location.
  ///
  /// [index] is an index of link's segment where you want to insert the point.
  /// Indexed from 1.
  /// When the link is a straight line you want to add a point to index 1.
  insertLinkMiddlePoint(String linkId, Offset point, int index) {
    assert(_canvasModel.linkExists(linkId),
        'model does not contain this link id: $linkId');
    _canvasModel
        .getLink(linkId)
        .insertMiddlePoint(_canvasState.fromCanvasCoordinates(point), index);
  }

  /// Sets the new position ([point]) to the existing link's joint point.
  ///
  /// Joints are indexed from 1.
  setLinkMiddlePointPosition(String linkId, Offset point, int index) {
    assert(_canvasModel.linkExists(linkId),
        'model does not contain this link id: $linkId');
    _canvasModel.getLink(linkId).setMiddlePointPosition(
        _canvasState.fromCanvasCoordinates(point), index);
  }

  /// Updates link's joint position by [offset].
  ///
  /// Joints are indexed from 1.
  moveLinkMiddlePoint(String linkId, Offset offset, int index) {
    assert(_canvasModel.linkExists(linkId),
        'model does not contain this link id: $linkId');
    _canvasModel
        .getLink(linkId)
        .moveMiddlePoint(offset / _canvasState.scale, index);
  }

  /// Removes the joint on [index]th place from the link.
  ///
  /// Joints are indexed from 1.
  removeLinkMiddlePoint(String linkId, int index) {
    assert(_canvasModel.linkExists(linkId),
        'model does not contain this link id: $linkId');
    _canvasModel.getLink(linkId).removeMiddlePoint(index);
  }

  /// Updates all link's joints position by [offset].
  moveAllLinkMiddlePoints(String linkId, Offset position) {
    assert(_canvasModel.linkExists(linkId),
        'model does not contain this link id: $linkId');
    _canvasModel
        .getLink(linkId)
        .moveAllMiddlePoints(position / _canvasState.scale);
  }

  sendEvent(ComponentEvent event) {
    _canvasState.componentUpdateEvent.broadcast(event);
  }
}

mixin ConnectionWriter on ModelWriter {
  /// Connects two components with a new link. The link is added to the model.
  ///
  /// The link points from [sourceComponentId] to [targetComponentId].
  /// Connection information is added to both components.
  ///
  /// Returns id of the created link.
  ///
  /// You can define the design of the link with [LinkStyle].
  /// You can add your own dynamic [data] to the link.
  String connectTwoComponents({
    required String sourceComponentId,
    required String targetComponentId,
    LinkStyle? linkStyle,
    dynamic data,
  }) {
    assert(_canvasModel.componentExists(sourceComponentId));
    assert(_canvasModel.componentExists(targetComponentId));
    return _canvasModel.connectTwoComponents(
      sourceComponentId,
      targetComponentId,
      linkStyle,
      data,
    );
  }
}
