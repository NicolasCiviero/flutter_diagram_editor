import 'package:shape_editor/shape_editor.dart';
import 'package:shape_editor/src/canvas_context/canvas_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Canvas model tests', () {
    test('Given new canvas When no action Then canvas contains no components',
        () {
      PolicySet policySet = PolicySet();
      var model = CanvasModel(policySet);

      expect(model.components.isEmpty, true);
    });

    test(
        'Given new canvas When added one component Then canvas contains one component',
        () {
      PolicySet policySet = PolicySet();
      var model = CanvasModel(policySet);
      ComponentData componentData = ComponentData();

      model.addComponent(componentData);

      expect(model.components.length, 1);
    });

    test(
        'Given canvas with one component When the component is removed Then canvas contains no components',
        () {
      PolicySet policySet = PolicySet();
      var model = CanvasModel(policySet);
      ComponentData componentData = ComponentData();

      String componentId = model.addComponent(componentData);

      model.removeComponent(componentId);

      expect(model.components.isEmpty, true);
    });

  });
}
