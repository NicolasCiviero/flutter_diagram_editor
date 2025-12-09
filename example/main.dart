import 'dart:convert';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:shape_editor/shape_editor.dart';
import 'package:flutter/material.dart';

import 'components_loader.dart';

void main() => runApp(DiagramApp());

class DiagramApp extends StatefulWidget {
  const DiagramApp({Key? key}) : super(key: key);

  @override
  _DiagramAppState createState() => _DiagramAppState();
}

class _DiagramAppState extends State<DiagramApp> {
  //MyPolicySet myPolicySet = MyPolicySet();
  PolicySet policySet = PolicySet();
  late DiagramEditorContext diagramEditorContext;

  @override
  void initState() {
    diagramEditorContext = DiagramEditorContext(policySet: policySet);
    policySet.isGridVisible = false;
    policySet.buttonBackColor = Colors.deepOrange;
    policySet.loadingIndicatorColor = Colors.deepOrange;
    policySet.stateReader.componentUpdateEvent
        .subscribe(onComponentEvent);

    super.initState();

    SchedulerBinding.instance.addPostFrameCallback((_) async {
      compute(initializeComponents, false);
    });
  }

  Future<void> initializeComponents(bool removeExistingRois) async {
    final jsonString = await rootBundle.loadString('assets/up_front_shapes.json');
    var json_components = loadComponentsFromJson(jsonString, color: Colors.orange.withAlpha(30));
    for (var component in json_components) {
      diagramEditorContext.canvasModel.addComponent(component);
    }
    diagramEditorContext.canvasModel.createClusters();
    // diagramEditorContext.canvasModel.addComponent(ComponentData(
    //     position: Offset(50, 50),
    //     size: Size(80, 150),
    //     minSize: Size(5, 5),
    //     color: Colors.orange,
    //     borderColor: Colors.deepOrange,
    //     borderWidth: 2.0,
    //     type: "rectangle",
    //     vertices: []));
    // diagramEditorContext.canvasModel.addComponent(ComponentData(
    //     position: Offset(250, 50),
    //     size: Size(180, 120),
    //     minSize: Size(5, 5),
    //     color: Colors.orange,
    //     borderColor: Colors.deepOrange,
    //     borderWidth: 2.0,
    //     type: "ellipse",
    //     vertices: []));
    diagramEditorContext.canvasModel.addComponent(ComponentData(
        position: Offset(50, 250),
        size: Size(30, 35),
        minSize: Size(5, 5),
        locked: true,
        color: Color.fromARGB(30, 255, 87, 34),
        highlightColor: Color.fromARGB(30, 34, 71, 255),
        borderColor: Colors.deepOrange,
        borderWidth: 2.0,
        type: "pixel_map",
        encodedBinaryData: base64Decode("EgMaBhcIFgkUCxMMEg0RDhAPDw8PDxANEQwRCgYGBwkHFggWCRUJFggWCRYIFgkWChQOEBAOEQwTCxMKFAoUCRUIFQgWBxcFDQ=="),
        vertices: []));




    var image = await loadUiImageFromAsset('assets/up_front_image.jpg');
    //var image = await debugImage();
    policySet.stateReader.canvasState.setImage(image);
    policySet.stateReader.canvasState.imageRescaleFactor = 1;
    setState(() { });
  }

  void onComponentEvent(ComponentEvent? args) {
    if (args == null) return;
  }

  Future<ui.Image> loadUiImageFromAsset(String assetPath) async {
    final data = await rootBundle.load(assetPath);
    final bytes = data.buffer.asUint8List();
    final codec = await ui.instantiateImageCodec(bytes);
    final frame = await codec.getNextFrame();
    return frame.image;
  }

  Future<ui.Image> debugImage() async {
    final url = 'https://63293d826eeab0f978a0119f8726d455.cdn.bubble.io/f1746189111268x549167210405818500/005.jpg?_gl=1*j3emgr*_gcl_au*MjA3MTgyMTczMS4xNzUwNjgwNTU4*_ga*MTc1NTYxMzM3My4xNzA2NzIxMzkw*_ga_BFPVR2DEE2*czE3NTA4Njk3MzkkbzMwMCRnMCR0MTc1MDg2OTczOSRqNjAkbDAkaDA.'; // 200x200 random image
    final response = await http.get(Uri.parse(url));
    final codec = await ui.instantiateImageCodec(response.bodyBytes);
    final frame = await codec.getNextFrame();
    return frame.image;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: SafeArea(
          child: Stack(
            children: [
              Container(color: Colors.grey),
              Padding(
                padding: const EdgeInsets.all(36),
                child: DiagramEditor(diagramEditorContext: diagramEditorContext),
              ),
              Positioned(
                top: 0,
                left: 0,
                bottom: 0,
                child: Row(
                  children: [
                    Container(
                      width: 100,
                      height: 290,
                      decoration: BoxDecoration(
                        //color: FlutterFlowTheme.of(context).secondary,
                        color: Color.fromARGB(255, 150, 150, 150),
                        borderRadius: const BorderRadius.only(
                          topRight: Radius.circular(20.0),
                          bottomRight: Radius.circular(20.0),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.5),
                            spreadRadius: 1,
                            blurRadius: 3,
                            offset: Offset(2, 1), // changes position of shadow
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(0.0, 20.0, 0.0, 0.0),
                        child: DraggableMenu(
                            myPolicySet: policySet,
                            color: Color.fromARGB(30, 255, 87, 34),
                            borderColor: Colors.deepOrange,
                            scale: 0.8),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Custom component Data which you can assign to a component to dynamic data property.
class MyComponentData {
  MyComponentData();

  bool isHighlightVisible = false;
  Color color =
      Color((math.Random().nextDouble() * 0xFFFFFF).toInt()).withOpacity(1.0);

  showHighlight() {
    isHighlightVisible = true;
  }

  hideHighlight() {
    isHighlightVisible = false;
  }

  // Function used to deserialize the diagram. Must be passed to `modelWriter.deserializeDiagram` for proper deserialization.
  MyComponentData.fromJson(Map<String, dynamic> json)
      : isHighlightVisible = json['highlight'],
        color = Color(int.parse(json['color'], radix: 16));

  // Function used to serialization of the diagram. E.g. to save to a file.
  Map<String, dynamic> toJson() => {
        'highlight': isHighlightVisible,
        'color': color.toString().split('(0x')[1].split(')')[0],
      };
}

// A set of policies compound of mixins. There are some custom policy implementations and some policies defined by diagram_editor library.
class MyPolicySet extends PolicySet with
        MyInitPolicy,
        MyCanvasPolicy,
        MyComponentPolicy,
        CustomPolicy {}

// A place where you can init the canvas or your diagram (eg. load an existing diagram).
mixin MyInitPolicy implements InitPolicy {
  @override
  initializeDiagramEditor() {
    stateWriter.setCanvasColor(Colors.grey[300]!);
  }
}

// You can override the behavior of any gesture on canvas here.
// Note that it also implements CustomPolicy where own variables and functions can be defined and used here.
mixin MyCanvasPolicy implements CanvasPolicy, CustomPolicy {
  @override
  onCanvasTapUp(TapUpDetails details) {
    if (selectedComponentId != null) {
      hideComponentHighlight(selectedComponentId);
    } else {
      modelWriter.addComponent(
        ComponentData(
          size: const Size(96, 72),
          position:
              stateReader.fromCanvasCoordinates(details.localPosition),
          data: MyComponentData(),
        ),
      );
    }
  }
}

// Mixin where component behaviour is defined. In this example it is the movement and highlight.
mixin MyComponentPolicy implements ComponentPolicy, CustomPolicy {
  // variable used to calculate delta offset to move the component.
  late Offset lastFocalPoint;

  @override
  onComponentTap(String componentId) {
    hideComponentHighlight(selectedComponentId);
    highlightComponent(componentId);
  }

  @override
  onComponentLongPress(String componentId) {
    hideComponentHighlight(selectedComponentId);
    modelWriter.removeComponent(componentId);
  }

  @override
  onComponentScaleStart(componentId, details) {
    lastFocalPoint = details.localFocalPoint;
  }

  @override
  onComponentScaleUpdate(componentId, details) {
    Offset positionDelta = details.localFocalPoint - lastFocalPoint;
    modelWriter.moveComponent(componentId, positionDelta);
    lastFocalPoint = details.localFocalPoint;
  }

}

// You can create your own Policy to define own variables and functions with canvasReader and canvasWriter.
mixin CustomPolicy implements PolicySet {
  String? selectedComponentId;
  String serializedDiagram = '{"components": []}';

  highlightComponent(String componentId) {
    modelReader.getComponent(componentId).data.showHighlight();
    modelReader.getComponent(componentId).updateComponent();
    selectedComponentId = componentId;
  }

  hideComponentHighlight(String? componentId) {
    if (componentId != null) {
      modelReader.getComponent(componentId).data.hideHighlight();
      modelReader.getComponent(componentId).updateComponent();
      selectedComponentId = null;
    }
  }

  deleteAllComponents() {
    selectedComponentId = null;
    modelWriter.removeAllComponents();
  }

  // Save the diagram to String in json format.
  serialize() {
    serializedDiagram = modelReader.serializeDiagram();
  }

  // Load the diagram from json format. Do it cautiously, to prevent unstable state remove the previous diagram (id collision can happen).
  deserialize() {
    modelWriter.removeAllComponents();
    modelWriter.deserializeDiagram(
      serializedDiagram,
      decodeCustomComponentData: (json) => MyComponentData.fromJson(json),
    );
  }
}
