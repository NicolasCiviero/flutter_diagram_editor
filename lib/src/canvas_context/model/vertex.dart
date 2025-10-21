import 'dart:ui';
import 'package:shape_editor/shape_editor.dart';
import 'package:uuid/uuid.dart';

class Vertex {
  final String id;
  Offset position;
  ComponentData componentData;


  Vertex(this.position, this.componentData) : id = const Uuid().v4();

  void moveTo(Offset newPos) => position = newPos;

  Offset absolutePosition() => position + componentData.position;
}
