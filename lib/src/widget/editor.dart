import 'package:shape_editor/src/canvas_context/canvas_model.dart';
import 'package:shape_editor/src/canvas_context/canvas_state.dart';
import 'package:shape_editor/src/widget/canvas.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../diagram_editor.dart';

class DiagramEditor extends StatefulWidget {
  final DiagramEditorContext diagramEditorContext;

  /// The main widget of [diagram_editor] library.
  ///
  /// In this widget all the editing of a diagram happens.
  ///
  /// How to use it: [diagram_editor](https://pub.dev/packages/diagram_editor).
  ///
  /// Source code: [github](https://github.com/Arokip/fdl).
  ///
  /// It takes [DiagramEditorContext] as required parameter.
  /// You should define its size in its parent widget, eg. Container.
  DiagramEditor({
    Key? key,
    required this.diagramEditorContext,
  }) : super(key: key);

  @override
  _DiagramEditorState createState() => _DiagramEditorState();
}

class _DiagramEditorState extends State<DiagramEditor> {
  @override
  void initState() {
    if (!widget.diagramEditorContext.canvasState.isInitialized) {
      this.widget.diagramEditorContext.policySet.initializeDiagramEditor();
      widget.diagramEditorContext.canvasState.isInitialized = true;
    }

    // TEST: loading components before on editor creation
    final c1 = ComponentData(
      position: Offset(50, 50),
      size: Size(50, 50),
      minSize: Size(0, 0),
      color: Colors.transparent,
      borderColor: Colors.white,
      borderWidth: 2.0,
      type: 'polygon',
      vertices: [Offset(0,0), Offset(50,0), Offset(50,50), Offset(0,50)],
    );
    final c2 = ComponentData(
      position: Offset(150, 50),
      size: Size(50, 50),
      minSize: Size(0, 0),
      color: Colors.transparent,
      borderColor: Colors.white,
      borderWidth: 2.0,
      type: 'polygon',
      vertices: [Offset(0,0), Offset(50,0), Offset(50,50), Offset(0,50)],
    );
    final c3 = ComponentData(
      position: Offset(100, 100),
      size: Size(50, 50),
      minSize: Size(0, 0),
      color: Colors.transparent,
      borderColor: Colors.white,
      borderWidth: 2.0,
      type: 'polygon',
      vertices: [Offset(0,0), Offset(50,0), Offset(50,50), Offset(0,50)],
    );
    final c4 = ComponentData(
      position: Offset(0, 100),
      size: Size(50, 50),
      minSize: Size(0, 0),
      color: Colors.transparent,
      borderColor: Colors.white,
      borderWidth: 2.0,
      type: 'polygon',
      vertices: [Offset(0,0), Offset(50,0), Offset(50,50), Offset(0,50)],
    );
    final c5 = ComponentData(
      position: Offset(0, 0),
      size: Size(50, 50),
      minSize: Size(0, 0),
      color: Colors.transparent,
      borderColor: Colors.white,
      borderWidth: 2.0,
      type: 'polygon',
      vertices: [Offset(0,0), Offset(50,0), Offset(50,50), Offset(0,50)],
    );
    widget.diagramEditorContext.canvasModel.addComponent(c1);
    widget.diagramEditorContext.canvasModel.addComponent(c2);
    widget.diagramEditorContext.canvasModel.addComponent(c3);
    widget.diagramEditorContext.canvasModel.addComponent(c4);
    widget.diagramEditorContext.canvasModel.addComponent(c5);


    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<CanvasModel>.value(
          value: widget.diagramEditorContext.canvasModel,
        ),
        ChangeNotifierProvider<CanvasState>.value(
          value: widget.diagramEditorContext.canvasState,
        ),
      ],
      builder: (context, child) {
        return DiagramEditorCanvas(
          policy: widget.diagramEditorContext.policySet,
        );
      },
    );
  }
}
