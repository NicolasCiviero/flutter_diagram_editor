import 'package:shape_editor/src/abstraction_layer/rw/model_writer.dart';
import 'package:shape_editor/src/abstraction_layer/rw/state_writer.dart';

/// Takes care of writing to model and state of the canvas.
class CanvasWriter {
  /// Access to canvas model (components, vertexClusters and all the functions to change the model).
  final CanvasModelWriter model;

  /// Access to canvas state data (canvas scale, position..).
  final CanvasStateWriter state;

  CanvasWriter(this.model, this.state);
}
