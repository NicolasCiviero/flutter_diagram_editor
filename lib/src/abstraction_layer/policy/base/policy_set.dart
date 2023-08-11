import 'package:shape_editor/diagram_editor.dart';
import 'package:shape_editor/src/abstraction_layer/policy/base_policy_set.dart';

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
        LinkAttachmentPolicy,
        LinkJointPolicy,
        LinkPolicy,
        LinkWidgetsPolicy,
        StatePolicy,
        CustomBehaviourPolicy
    {}
