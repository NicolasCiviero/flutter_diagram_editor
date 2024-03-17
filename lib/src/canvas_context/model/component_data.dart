import 'package:shape_editor/src/canvas_context/model/connection.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:event/event.dart';

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

  /// Component type to distinguish components.
  ///
  /// You can use it for example to distinguish what [data] type this component has.
  final String? type;

  /// This value determines if this component will be above or under other components.
  /// Higher value means on the top.
  int zOrder = 0;

  /// Assigned parent to this component.
  ///
  /// Use for hierarchical components.
  /// Functions such as [moveComponentWithChildren] work with this property.
  String? parentId;

  /// List of children of this component.
  ///
  /// Use for hierarchical components.
  /// Functions such as [moveComponentWithChildren] work with this property.
  final List<String> childrenIds = [];

  /// Defines to which components is this components connected and what is the [connectionId].
  ///
  /// The connection can be [ConnectionOut] for link going from this component
  /// or [ConnectionIn] for link going from another to this component.
  final List<Connection> connections = [];

  /// List of vertices of a polygon.
  ///
  /// Each point's position is related to the current [position].
  List<Offset> vertices = [];

  Color color;
  Color borderColor;
  double borderWidth;
  String text;
  Alignment textAlignment;
  double textSize;
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
    this.type,
    this.data,
    this.color = Colors.white,
    this.borderColor = Colors.black,
    this.borderWidth = 0.0,
    this.text = '',
    this.textAlignment = Alignment.center,
    this.textSize = 20,
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
  moveVertex(Offset vertex, Offset newPosition) {
    for (int i = 0; i < vertices.length; i++){
      if (vertices[i] == vertex){
        vertices[i] = newPosition - position;

        updateComponentPositionAndSize();
        notifyListeners();
        return;
      }
    }
  }
  /// Add a new vertex at [position] given.
  addVertex(Offset vertex, int position) {
    if (position == vertices.length) vertices.add(vertex);
    else vertices.insert(position, vertex);
  }

  updateComponentPositionAndSize() {
    double minX=double.infinity, minY=double.infinity, maxX=0, maxY=0;
    for (int i = 0; i < vertices.length; i++) {
      if (vertices[i].dx < minX) minX = vertices[i].dx;
      if (vertices[i].dy < minY) minY = vertices[i].dy;
      if (vertices[i].dx > maxX) maxX = vertices[i].dx;
      if (vertices[i].dy > maxY) maxY = vertices[i].dy;
    }
    if (minX != 0) {
      var componentOffset = Offset(minX, 0);
      this.position += componentOffset;
      for (int i = 0; i < vertices.length; i++) vertices[i] -= componentOffset;
    }
    if (minY != 0) {
      var componentOffset = Offset(0, minY);
      this.position += componentOffset;
      for (int i = 0; i < vertices.length; i++) vertices[i] -= componentOffset;
    }

    size = new Size(maxX - minX, maxY - minY);
  }

  /// Sets the position of the component to [position] value.
  setPosition(Offset position) {
    this.position = position;
    notifyListeners();
  }

  /// Adds new connection to this component.
  ///
  /// Do not use it if you are not sure what you do. This is called in [connectTwoComponents] function.
  addConnection(Connection connection) {
    connections.add(connection);
  }

  /// Removes existing connection.
  ///
  /// Do not use it if you are not sure what you do. This is called eg. in [removeLink] function.
  removeConnection(String connectionId) {
    connections.removeWhere((conn) => conn.connectionId == connectionId);
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

  /// Sets the component's parent.
  ///
  /// It's not possible to make a parent-child loop. (its ancestor cannot be its child)
  ///
  /// You should use it only with [addChild] on the parent's component.
  setParent(String parentId) {
    this.parentId = parentId;
  }

  /// Removes parent's id from this component data.
  ///
  /// You should use it only with [removeChild] on the parent's component.
  removeParent() {
    this.parentId = null;
  }

  /// Sets the component's parent.
  ///
  /// It's not possible to make a parent-child loop. (its ancestor cannot be its child)
  ///
  /// You should use it only with [setParent] on the child's component.
  addChild(String childId) {
    childrenIds.add(childId);
  }

  /// Removes child's id from children.
  ///
  /// You should use it only with [removeParent] on the child's component.
  removeChild(String childId) {
    childrenIds.remove(childId);
  }

  /// Create a copy of this ComponentData
  ComponentData clone(){
    return ComponentData(
      position: this.position,
      size: this.size,
      minSize: this.minSize,
      type: this.type,
      vertices: this.vertices.map<Offset>((e) => Offset(e.dx, e.dy)).toList(),
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
        type = json['type'],
        zOrder = json['z_order'],
        parentId = json['parent_id'],
        color = json['color,'],
        borderColor = json['borderColor'],
        borderWidth = json['borderWidth'],
        text = json['text'],
        textAlignment = json['textAlignment'],
        textSize = json['textSize'],
        data = decodeCustomComponentData?.call(json['dynamic_data']) {
    this.childrenIds.addAll(
        (json['children_ids'] as List).map((id) => id as String).toList());
    this.connections.addAll((json['connections'] as List)
        .map((connectionJson) => Connection.fromJson(connectionJson)));
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'position': [position.dx, position.dy],
        'size': [size.width, size.height],
        'min_size': [minSize.width, minSize.height],
        'type': type,
        'z_order': zOrder,
        'parent_id': parentId,
        'children_ids': childrenIds,
        'connections': connections,
        //'vertices': vertices,
        'color': color,
        'borderColor': borderColor,
        'borderWidth': borderWidth,
        'text': text,
        'textAlignment': textAlignment,
        'textSize': textSize,
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
  static String move = "move";
  static String moveEnded = "moveEnded";
  static String moveVertex = "moveVertex";
  static String addVertex = "addVertex";
  static String setPosition = "setPosition";
  static String update = "update";
  static String resize = "resize";
  static String resizeEnded = "resizeEnded";
}
