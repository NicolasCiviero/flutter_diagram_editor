import 'dart:ui';

import 'package:shape_editor/shape_editor.dart';
import 'package:shape_editor/src/canvas_context/model/vertex.dart';

class VertexCluster {
  final List<Vertex> vertices;

  VertexCluster({List<Vertex>? vertices}) : vertices = vertices ?? [];

  void addVertex(Vertex vertex) {
    if (!vertices.contains(vertex)) { vertices.add(vertex); }
    vertex.componentData.vertexClusters[vertex.id] = this;
  }

  void removeVertex(Vertex vertex) {
    vertex.componentData.vertexClusters.remove(vertex.id);
    vertices.remove(vertex);
    if (vertices.length == 1) vertices[0].componentData.vertexClusters.remove(vertices[0].id);
  }

  @override
  String toString() {
    return 'VertexCluster(${vertices.length} vertices)';
  }
}


