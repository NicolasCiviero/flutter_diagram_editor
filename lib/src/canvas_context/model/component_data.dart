import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:shape_editor/src/canvas_context/model/vertex.dart';
import 'package:shape_editor/src/canvas_context/model/vertex_cluster.dart';
import 'package:uuid/uuid.dart';
import 'package:event/event.dart';
import 'dart:typed_data';

class ComponentData with ChangeNotifier {
  /// Unique id of this component.
  final String id;

  /// Position on the canvas.
  Offset position;

  /// Size of the component.
  Size size;


  /// Minimal size of a component.
  ///
  /// When [resizeDelta] is called the size will not go under this value.
  final Size minSize;

  /// Responsible for prevent this ComponentData from moving
  bool locked;

  /// Component type to distinguish components.
  ///
  /// You can use it for example to distinguish what [data] type this component has.
  final String? type;

  /// Store data to build the pixelmap.
  final Uint8List? encodedBinaryData;

  /// This value determines if this component will be above or under other components.
  /// Higher value means on the top.
  int zOrder = 0;

  /// List of vertices of a polygon.
  ///
  /// Each point's position is related to the current [position].
  List<Vertex> vertices = [];

  /// Map potential clusters with component's vertices
  HashMap<String, VertexCluster> vertexClusters = HashMap();


  Color color;
  Color highlightColor;
  Color borderColor;
  double borderWidth;
  String text;
  Alignment textAlignment;
  double textSize;
  Color textColor;
  bool isHighlightVisible = false;

  /// Dynamic data for you to define your own data for this component.
  dynamic data;

  /// Represents data of a component in the model.
  ComponentData({
    String? id,
    this.position = Offset.zero,
    this.vertices = const [],
    this.size = const Size(80, 80),
    this.minSize = const Size(4, 4),
    this.locked = false,
    this.type,
    this.data,
    this.color = Colors.white,
    this.highlightColor = Colors.white,
    this.borderColor = Colors.black,
    this.borderWidth = 0.0,
    this.text = '',
    this.encodedBinaryData = null,
    this.textAlignment = Alignment.center,
    this.textSize = 20,
    this.textColor = Colors.black,
  })  : assert(minSize <= size),
        this.id = id ?? Uuid().v4();

  /// Updates this component on the canvas.
  ///
  /// Use this function if you somehow changed the component data and you want to propagate the change to canvas.
  /// Usually this is already called in most functions such as [move] or [setSize] so it's not necessary to call it again.
  ///
  /// It calls [notifyListeners] function of [ChangeNotifier].
  updateComponent() {
    notifyListeners();
  }

  /// Translates the component by [offset] value.
  move(Offset offset) {
    this.position += offset;
    notifyListeners();
  }

  /// Translates component's vertex by [offset] value.
  moveVertex(Vertex vertex, Offset newPosition) {
    for (int i = 0; i < vertices.length; i++){
      if (vertices[i] == vertex){
        vertices[i].position = newPosition - position;

        updateComponentPositionAndSize();
        notifyListeners();
        return;
      }
    }
  }
  /// Add a new vertex at [position] given.
  addVertex(Offset position, int? index) {
    if (index == null || index == vertices.length) vertices.add(Vertex(position, this));
    else vertices.insert(index, Vertex(position, this));
  }
  /// Remove vertex at [position] given.
  removeVertex(Vertex? vertex) {
    if (vertices.contains(vertex)) {
      vertices.remove(vertex);
    }
  }

  updateComponentPositionAndSize() {
    double minX=double.infinity, minY=double.infinity, maxX=0, maxY=0;
    for (int i = 0; i < vertices.length; i++) {
      final position = vertices[i].position;
      if (position.dx < minX) minX = position.dx;
      if (position.dy < minY) minY = position.dy;
      if (position.dx > maxX) maxX = position.dx;
      if (position.dy > maxY) maxY = position.dy;
    }
    if (minX != 0) {
      var componentOffset = Offset(minX, 0);
      this.position += componentOffset;
      for (int i = 0; i < vertices.length; i++) vertices[i].position -= componentOffset;
    }
    if (minY != 0) {
      var componentOffset = Offset(0, minY);
      this.position += componentOffset;
      for (int i = 0; i < vertices.length; i++) vertices[i].position -= componentOffset;
    }

    size = new Size(maxX - minX, maxY - minY);
  }

  /// Sets the position of the component to [position] value.
  setPosition(Offset position) {
    this.position = position;
    notifyListeners();
  }

  /// Changes the component's size by [deltaSize].
  ///
  /// You cannot change its size to smaller than [minSize] defined on the component.
  resizeDelta(Offset deltaSize) {
    var tempSize = size + deltaSize;
    if (tempSize.width < minSize.width) {
      tempSize = Size(minSize.width, tempSize.height);
    }
    if (tempSize.height < minSize.height) {
      tempSize = Size(tempSize.width, minSize.height);
    }
    size = tempSize;
    notifyListeners();
  }

  /// Sets the component's to [size].
  setSize(Size size) {
    this.size = size;
    notifyListeners();
  }

  /// Returns Offset position on this component from [alignment].
  ///
  /// [Alignment.topLeft] returns [Offset.zero]
  ///
  /// [Alignment.center] or [Alignment(0, 0)] returns the center coordinates on this component.
  ///
  /// [Alignment.bottomRight] returns offset that is equal to size of this component.
  Offset getPointOnComponent(Alignment alignment) {
    return Offset(
      size.width * ((alignment.x + 1) / 2),
      size.height * ((alignment.y + 1) / 2),
    );
  }

  /// Returns true for non-shape components
  bool isOverlay() {
    if (this.type == "arrow") return true;
    if (this.type == "text") return true;
    return false;
  }

  /// Create a copy of this ComponentData
  ComponentData clone(){
    return ComponentData(
      position: this.position,
      size: this.size,
      minSize: this.minSize,
      type: this.type,
      vertices: this.vertices.map<Vertex>((e) => Vertex(Offset(e.position.dx, e.position.dy), this)).toList(),
      color: this.color,
      borderColor: this.borderColor,
      borderWidth: this.borderWidth,
      text: this.text,
      textAlignment: this.textAlignment,
      textSize: this.textSize,
    );
  }

  @override
  String toString() {
    return 'Component data ($id), position: $position';
  }

  ComponentData.fromJson(
    Map<String, dynamic> json, {
    Function(Map<String, dynamic> json)? decodeCustomComponentData,
  })  : id = json['id'],
        position = Offset(json['position'][0], json['position'][1]),
        size = Size(json['size'][0], json['size'][1]),
        minSize = Size(json['min_size'][0], json['min_size'][1]),
        locked = json['locked'],
        type = json['type'],
        zOrder = json['z_order'],
        color = json['color'],
        highlightColor = json['highlightColor'],
        borderColor = json['borderColor'],
        borderWidth = json['borderWidth'],
        text = json['text'],
        encodedBinaryData = json['encodedBinaryData'],
        textAlignment = json['textAlignment'],
        textSize = json['textSize'],
        textColor = json['textColor'],
        data = decodeCustomComponentData?.call(json['dynamic_data']) {}

  Map<String, dynamic> toJson() => {
        'id': id,
        'position': [position.dx, position.dy],
        'size': [size.width, size.height],
        'min_size': [minSize.width, minSize.height],
        'type': type,
        'z_order': zOrder,
        //'vertices': vertices,
        'color': color,
        'borderColor': borderColor,
        'borderWidth': borderWidth,
        'text': text,
        'textAlignment': textAlignment,
        'textSize': textSize,
        'textColor': textColor,
        'dynamic_data': data?.toJson(),
      };
}

class ComponentEvent extends EventArgs {
  String description;
  ComponentData component;

  ComponentEvent(this.description, this.component);

  static String created = "created";
  static String removed = "removed";
  static String selected = "selected";
  static String deselected = "deselected";
  static String move = "move";
  static String moveEnded = "moveEnded";
  static String moveVertex = "moveVertex";
  static String moveVertexEnded = "moveVertexEnded";
  static String addVertex = "addVertex";
  static String removeVertex = "removeVertex";
  static String setPosition = "setPosition";
  static String update = "update";
  static String resize = "resize";
  static String resizeEnded = "resizeEnded";
}
