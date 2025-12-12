import 'package:shape_editor/src/abstraction_layer/policy/policy_set.dart';
import 'package:shape_editor/src/abstraction_layer/rw/model_reader.dart';
import 'package:shape_editor/src/abstraction_layer/rw/model_writer.dart';
import 'package:shape_editor/src/abstraction_layer/rw/state_reader.dart';
import 'package:shape_editor/src/abstraction_layer/rw/state_writer.dart';
import 'package:shape_editor/src/canvas_context/canvas_model.dart';
import 'package:shape_editor/src/canvas_context/canvas_state.dart';

class DiagramEditorContext {
  final CanvasModel _canvasModel;
  final CanvasState _canvasState;

  /// Set of policies where all the diagram customization is defined.
  final PolicySet policySet;

  /// Canvas model containing all components with all the functions.
  CanvasModel get canvasModel => _canvasModel;

  /// Canvas state containing for example canvas position and scale.
  CanvasState get canvasState => _canvasState;

  /// [DiagramEditorContext] is taken as parameter by [DiagramEditor] widget.
  ///
  /// Its not generated automatically because you want to use it to copy model or state to another [DiagramEditor].
  DiagramEditorContext({
    required this.policySet,
  })  : this._canvasModel = CanvasModel(policySet),
        this._canvasState = CanvasState() {
    policySet.initializePolicy(
        CanvasModelReader(canvasModel, canvasState),
        CanvasModelWriter(canvasModel, canvasState),
        CanvasStateReader(canvasState),
        CanvasStateWriter(canvasState),
    );
  }

}
