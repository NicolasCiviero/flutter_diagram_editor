import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:shape_editor/src/abstraction_layer/policy/base_policy_set.dart';
import 'package:shape_editor/src/canvas_context/model/component_data.dart';
import 'package:shape_editor/src/canvas_context/model/vertex.dart';
import 'package:shape_editor/src/canvas_context/model/vertex_cluster.dart';

mixin ClusteringPolicy on BasePolicySet {
  static const double autoClusteringDistance = 2.0;
  static const double userClusteringDistance = 10.0;
  static Color clusterIndicatorColor = Colors.blue.withOpacity(0.5);

  createClusters() {
    final componentList =
        modelReader.canvasModel.getAllComponents().values.toList();

    for (int i = 0; i < componentList.length; i++) {
      final A = componentList[i];
      if (A.vertices.isEmpty) continue;

      for (int j = i + 1; j < componentList.length; j++) {
        final B = componentList[j];
        if (B.vertices.isEmpty) continue;

        _checkComponentPair(A, B);
      }
    }
  }

  void _checkComponentPair(ComponentData A, ComponentData B) {
    for (final vertexA in A.vertices) {
      for (final vertexB in B.vertices) {
        if (_areVerticesClose(vertexA, vertexB)) {
          clusterVertices(vertexA, vertexB);
        }
      }
    }
  }

  bool _areVerticesClose(Vertex vertexA, Vertex vertexB) {
    return (vertexA.absolutePosition() - vertexB.absolutePosition()).distance <
        autoClusteringDistance;
  }

  void clusterVertices(Vertex vertexA, Vertex vertexB) {
    final clusterA = vertexA.componentData.vertexClusters[vertexA.id];
    final clusterB = vertexB.componentData.vertexClusters[vertexB.id];
    if (clusterA == null && clusterB == null) {
      final cluster = VertexCluster();
      cluster.addVertex(vertexA);
      cluster.addVertex(vertexB);
      modelReader.canvasModel.clusters.add(cluster);
      return;
    } else {
      final target = clusterA ?? clusterB!;
      target.addVertex(vertexA);
      target.addVertex(vertexB);
    }
  }

  void findClusterableVertices(Vertex sourceVertex, double radius) {
    final componentList = modelReader.canvasModel.getAllComponents().values.toList();
    final sourceAbsPos = sourceVertex.absolutePosition();

    for (final component in componentList) {
      if (component.id == sourceVertex.componentData.id) continue;
      if (component.vertices.isEmpty) continue;
      final cPos = component.position;

      // Optimization: Skip components far from source vertex.
      if (sourceAbsPos.dx < cPos.dx - radius) continue;
      if (sourceAbsPos.dy < cPos.dy - radius) continue;
      if (sourceAbsPos.dx > cPos.dx + component.size.width + radius) continue;
      if (sourceAbsPos.dy > cPos.dy + component.size.height + radius) continue;
      // Skip Component if both already share a cluster
      final sourceCluster =
          sourceVertex.componentData.vertexClusters[sourceVertex.id];
      if (component.vertexClusters.containsValue(sourceCluster)) continue;

      // Check each vertex in the candidate component
      for (final targetVertex in component.vertices) {
        final dist = (sourceAbsPos - targetVertex.absolutePosition()).distance;
        if (dist <= radius) {
          clusterVertices(sourceVertex, targetVertex);
        }
      }
    }
  }

  void detachVertexFromCluster(Vertex vertex) {
    final cluster = vertex.componentData.vertexClusters[vertex.id];
    if (cluster == null) return;

    cluster.removeVertex(vertex);

    if (cluster.vertices.length < 2) {
      modelReader.canvasModel.clusters.remove(cluster);
      for (final v in cluster.vertices) {
        v.componentData.vertexClusters.remove(v.id);
      }
    }
  }
}
