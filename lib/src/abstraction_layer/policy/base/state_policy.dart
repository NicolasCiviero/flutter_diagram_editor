import 'package:flutter/services.dart';
import 'package:shape_editor/src/abstraction_layer/policy/base_policy_set.dart';
import 'package:shape_editor/shape_editor.dart';
import 'package:flutter/material.dart';

mixin StatePolicy on BasePolicySet {
  bool isGridVisible = true;

  List<String> bodies = [
    //'junction',
    'rect',
    'polygon',
    'ellipse',
  ];

  String? selectedComponentId;

  bool isMultipleSelectionOn = false;
  List<String> multipleSelected = [];

  Offset deleteLinkPos = Offset.zero;

  bool isReadyToConnect = false;

  String? selectedLinkId;
  Offset tapLinkPosition = Offset.zero;

  hideAllHighlights() {
    canvasWriter.model.hideAllLinkJoints();
    hideLinkOption();
    canvasReader.model.getAllComponents().values.forEach((component) {
      if (component.isHighlightVisible) {
        component.isHighlightVisible = false;
        canvasWriter.model.updateComponent(component.id);
      }
    });
  }

  highlightComponent(String componentId) {
    final component = canvasReader.model.getComponent(componentId);
    component.isHighlightVisible = true;
    component.updateComponent();
  }

  hideComponentHighlight(String componentId) {
    final component = canvasReader.model.getComponent(componentId);
    component.isHighlightVisible = false;
    component.updateComponent();
  }

  turnOnMultipleSelection() {
    isMultipleSelectionOn = true;
    isReadyToConnect = false;

    if (selectedComponentId != null) {
      addComponentToMultipleSelection(selectedComponentId);
      selectedComponentId = null;
    }
  }

  turnOffMultipleSelection() {
    isMultipleSelectionOn = false;
    multipleSelected = [];
    hideAllHighlights();
  }

  addComponentToMultipleSelection(String? componentId) {
    if (componentId == null) return;
    if (!multipleSelected.contains(componentId)) {
      multipleSelected.add(componentId);
    }
  }

  removeComponentFromMultipleSelection(String componentId) {
    multipleSelected.remove(componentId);
  }

  showLinkOption(String linkId, Offset position) {
    selectedLinkId = linkId;
    tapLinkPosition = position;
  }

  hideLinkOption() {
    selectedLinkId = null;
  }
}

mixin CustomBehaviourPolicy implements StatePolicy {
  removeAll() {
    canvasWriter.model.removeAllComponents();
  }

  resetView() {
    canvasWriter.state.resetCanvasView();
  }

  removeSelected() {
    multipleSelected.forEach((compId) {
      canvasWriter.model.removeComponent(compId);
    });
    multipleSelected = [];
  }

  duplicateSelected() {
    List<String> duplicated = [];
    multipleSelected.forEach((componentId) {
      String newId = canvasReader.model.getComponent(componentId).clone().id;
      duplicated.add(newId);
    });
    hideAllHighlights();
    multipleSelected = [];
    duplicated.forEach((componentId) {
      addComponentToMultipleSelection(componentId);
      highlightComponent(componentId);
      canvasWriter.model.moveComponentToTheFront(componentId);
    });
  }

  selectAll() {
    var components = canvasReader.model.canvasModel.components.keys;

    components.forEach((componentId) {
      addComponentToMultipleSelection(componentId);
      highlightComponent(componentId);
    });
  }

  moveHighlighted(KeyEvent event) {
    if (selectedComponentId == null) return KeyEventResult.handled;
    if (event is KeyUpEvent) return KeyEventResult.handled;

    final step = 1.0;
    if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
      final componentData = canvasReader.model.getComponent(selectedComponentId!);
      componentData.move(Offset(0, -step));
    } else if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
      final componentData = canvasReader.model.getComponent(selectedComponentId!);
      componentData.move(Offset(0, step));
    } else if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
      final componentData = canvasReader.model.getComponent(selectedComponentId!);
      componentData.move(Offset(-step, 0));
    } else if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
      final componentData = canvasReader.model.getComponent(selectedComponentId!);
      componentData.move(Offset(step, 0));
    }

    return KeyEventResult.handled;
  }
}