import 'package:shape_editor/src/abstraction_layer/policy/base_policy_set.dart';

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
