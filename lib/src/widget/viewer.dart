import 'package:shape_editor/src/canvas_context/canvas_model.dart';
import 'package:shape_editor/src/canvas_context/canvas_state.dart';
import 'package:shape_editor/src/widget/canvas.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../shape_editor.dart';

class DiagramViewer extends StatefulWidget {
  final DiagramEditorContext diagramEditorContext;
  /// It takes [DiagramEditorContext] as required parameter.
  /// You should define its size in its parent widget, eg. Container.
  DiagramViewer({
    Key? key,
    required this.diagramEditorContext,
  }) : super(key: key);

  @override
  _DiagramViewerState createState() => _DiagramViewerState();
}

class _DiagramViewerState extends State<DiagramViewer> {
  final GlobalKey _key = GlobalKey();
  Size _lastSize = Size(0, 0);

  @override
  void initState() {
    if (!widget.diagramEditorContext.canvasState.isInitialized) {
      this.widget.diagramEditorContext.policySet.initializeDiagramEditor();
      widget.diagramEditorContext.canvasState.isInitialized = true;
    }
    super.initState();

  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkSize());
    return MultiProvider(
      key: _key,
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
          policy: widget.diagramEditorContext.policySet, noEditing: true,
        );
      },
    );
  }

  void _checkSize() {
    final RenderObject? renderObject = _key.currentContext?.findRenderObject();
    if (renderObject == null) return;
    final RenderBox renderBox = renderObject as RenderBox;
    final Size newSize = renderBox.size;

    if (_lastSize != newSize) {
      widget.diagramEditorContext.canvasState.setCanvasSize(newSize.width, newSize.height);
      _lastSize = newSize;
      setState(() { });
    }
  }
}
