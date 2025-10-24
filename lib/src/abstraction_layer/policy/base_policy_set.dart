import '../rw/model_reader.dart';
import '../rw/model_writer.dart';
import '../rw/state_reader.dart';
import '../rw/state_writer.dart';

class BasePolicySet {
  /// Access to canvas model (components, vertexClusters and all the functions to change the model).
  late final CanvasModelReader modelReader;
  late final CanvasModelWriter modelWriter;

  /// Access to canvas state data (canvas scale, position..).
  late final CanvasStateReader stateReader;
  late final CanvasStateWriter stateWriter;


  /// Initialize policy in [DiagramEditorContext].
  initializePolicy(CanvasModelReader modelReader, CanvasModelWriter modelWriter, CanvasStateReader stateReader, CanvasStateWriter stateWriter) {
    this.modelReader = modelReader;
    this.modelWriter = modelWriter;
    this.stateReader = stateReader;
    this.stateWriter = stateWriter;
  }
}
