import 'package:shape_editor/src/abstraction_layer/policy/base_policy_set.dart';
import 'package:shape_editor/src/canvas_context/model/component_data.dart';
import 'package:shape_editor/src/canvas_context/model/vertex.dart';
import 'package:shape_editor/src/canvas_context/model/vertex_cluster.dart';

mixin ClusteringPolicy on BasePolicySet {
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
        2;
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
}
