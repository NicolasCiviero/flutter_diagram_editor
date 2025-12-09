import 'package:flutter/services.dart';
import 'package:shape_editor/src/abstraction_layer/policy/base_policy_set.dart';
import 'package:flutter/material.dart';

import 'package:shape_editor/src/canvas_context/model/vertex.dart';

mixin StatePolicy on BasePolicySet {
  bool isGridVisible = true;

  List<String> bodies = [
    'rect',
    'polygon',
    'ellipse',
    'text',
    'arrow',
  ];

  String? selectedComponentId;
  Vertex? selectedVertex;

  bool isMultipleSelectionOn = false;
  List<String> multipleSelected = [];

  hideAllHighlights() {
    modelReader.getAllComponents().values.forEach((component) {
      if (component.isHighlightVisible) {
        component.isHighlightVisible = false;
        modelWriter.updateComponent(component.id);
      }
    });
  }

  highlightComponent(String componentId) {
    final component = modelReader.getComponent(componentId);
    component.isHighlightVisible = true;
    component.updateComponent();
  }

  hideComponentHighlight(String componentId) {
    final component = modelReader.getComponent(componentId);
    component.isHighlightVisible = false;
    component.updateComponent();
  }

  turnOnMultipleSelection() {
    isMultipleSelectionOn = true;

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
}

mixin CustomBehaviourPolicy implements StatePolicy {
  removeAll() {
    modelWriter.removeAllComponents();
  }

  resetView() {
    stateWriter.resetCanvasView();
  }

  removeSelected() {
    multipleSelected.forEach((compId) {
      modelWriter.removeComponent(compId);
    });
    multipleSelected = [];
  }

  duplicateSelected() {
    List<String> duplicated = [];
    multipleSelected.forEach((componentId) {
      String newId = modelReader.getComponent(componentId).clone().id;
      duplicated.add(newId);
    });
    hideAllHighlights();
    multipleSelected = [];
    duplicated.forEach((componentId) {
      addComponentToMultipleSelection(componentId);
      highlightComponent(componentId);
      modelWriter.moveComponentToTheFront(componentId);
    });
  }

  selectAll() {
    var components = modelReader.canvasModel.components.keys;

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
      final componentData = modelReader.getComponent(selectedComponentId!);
      componentData.move(Offset(0, -step));
    } else if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
      final componentData = modelReader.getComponent(selectedComponentId!);
      componentData.move(Offset(0, step));
    } else if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
      final componentData = modelReader.getComponent(selectedComponentId!);
      componentData.move(Offset(-step, 0));
    } else if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
      final componentData = modelReader.getComponent(selectedComponentId!);
      componentData.move(Offset(step, 0));
    }

    return KeyEventResult.handled;
  }
}
