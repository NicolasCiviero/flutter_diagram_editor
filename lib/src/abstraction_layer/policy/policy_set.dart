import 'package:shape_editor/shape_editor.dart';
import 'package:shape_editor/src/abstraction_layer/policy/base_policy_set.dart';
import 'package:shape_editor/src/abstraction_layer/policy/vertex_widgets_policy.dart';

/// Fundamental policy set. Your policy set should extend [PolicySet].
class PolicySet extends BasePolicySet
    with
        CanvasPolicy,
        CanvasControlPolicy,
        CanvasWidgetsPolicy,
        ComponentDesignPolicy,
        ComponentPolicy,
        ComponentWidgetsPolicy,
        InitPolicy,
        StatePolicy,
        ClusteringPolicy,
        VertexWidgetsPolicy {}
