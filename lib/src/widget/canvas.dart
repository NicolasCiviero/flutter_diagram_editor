import 'package:shape_editor/src/abstraction_layer/policy/base/policy_set.dart';
import 'package:shape_editor/src/abstraction_layer/policy/defaults/canvas_control_policy.dart';
import 'package:shape_editor/src/canvas_context/canvas_model.dart';
import 'package:shape_editor/src/canvas_context/canvas_state.dart';
import 'package:shape_editor/src/canvas_context/model/component_data.dart';
import 'package:shape_editor/src/canvas_context/model/link_data.dart';
import 'package:shape_editor/src/widget/component.dart';
import 'package:shape_editor/src/widget/link.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';


class DiagramEditorCanvas extends StatefulWidget {
  final PolicySet policy;
  final bool noEditing;

  /// The canvas where all components and links are shown on.
  const DiagramEditorCanvas({
    Key? key,
    required this.policy,
    this.noEditing = false
  }) : super(key: key);

  @override
  _DiagramEditorCanvasState createState() => _DiagramEditorCanvasState();
}

class _DiagramEditorCanvasState extends State<DiagramEditorCanvas>
    with TickerProviderStateMixin {
  PolicySet? withControlPolicy;

  bool _onKey(KeyEvent event) {
    final key = event.logicalKey;

    if (event is KeyUpEvent && key == LogicalKeyboardKey.delete) {
      if (widget.policy.selectedComponentId != null) {
        widget.policy.canvasWriter.model.removeComponent(widget.policy.selectedComponentId!);
        widget.policy.selectedComponentId = null;
      }
    }
    return false;
  }

  @override
  void initState() {
    ServicesBinding.instance.keyboard.addHandler(_onKey);
    withControlPolicy = (widget.policy is CanvasControlPolicy || widget.policy is CanvasMovePolicy)
        ? widget.policy : null;

    (withControlPolicy as CanvasControlPolicy?)?.setAnimationController(
      AnimationController(
        duration: const Duration(seconds: 1),
        vsync: this,
      ),
    );
    super.initState();

  }

  @override
  void dispose() {
    (withControlPolicy as CanvasControlPolicy?)?.disposeAnimationController();
    super.dispose();
  }

  List<Widget> showComponents(CanvasModel canvasModel) {
    var zOrderedComponents = canvasModel.components.values.toList();
    zOrderedComponents.sort((a, b) {
      if (a.type != "arrow" && b.type == "arrow") { return -1;}
      else if (a.type == "arrow" && b.type != "arrow") { return 1; } else {
      return a.zOrder.compareTo(b.zOrder);
      }
    });

    return zOrderedComponents.map(
          (componentData) => ChangeNotifierProvider<ComponentData>.value(
            value: componentData,
            child: Component(
              policy: widget.policy,
            ),
          ),
        )
        .toList();
  }

  List<Widget> showLinks(CanvasModel canvasModel) {
    return canvasModel.links.values.map((LinkData linkData) {
      return ChangeNotifierProvider<LinkData>.value(
        value: linkData,
        child: Link(
          policy: widget.policy,
        ),
      );
    }).toList();
  }

  List<Widget> showOtherWithComponentDataUnder(CanvasModel canvasModel) {
    return canvasModel.components.values.map((ComponentData componentData) {
      return ChangeNotifierProvider<ComponentData>.value(
        value: componentData,
        builder: (context, child) {
          return Consumer<ComponentData>(
            builder: (context, data, child) {
              return widget.policy
                  .showCustomWidgetWithComponentDataUnder(context, data);
            },
          );
        },
      );
    }).toList();
  }

  List<Widget> showOtherWithComponentDataOver(CanvasModel canvasModel) {
    return canvasModel.components.values.map((ComponentData componentData) {
      return ChangeNotifierProvider<ComponentData>.value(
        value: componentData,
        builder: (context, child) {
          return Consumer<ComponentData>(
            builder: (context, data, child) {
              return widget.policy
                  .showCustomWidgetWithComponentDataOver(context, data);
            },
          );
        },
      );
    }).toList();
  }

  List<Widget> showBackgroundWidgets() {
    return widget.policy.showCustomWidgetsOnCanvasBackground(context);
  }

  List<Widget> showForegroundWidgets() {
    return widget.policy.showCustomWidgetsOnCanvasForeground(context);
  }

  Widget canvasStack(CanvasModel canvasModel) {
    return Stack(
      clipBehavior: Clip.none,
      fit: StackFit.expand,

      children: [
        ...showBackgroundWidgets(),
        ...showOtherWithComponentDataUnder(canvasModel),
        ...showComponents(canvasModel),
        ...showLinks(canvasModel),
        ...showOtherWithComponentDataOver(canvasModel),
        ...showForegroundWidgets(),
      ],
    );
  }

  Widget canvasAnimated(CanvasModel canvasModel) {
    return AnimatedBuilder(
      animation:
          (withControlPolicy as CanvasControlPolicy).getAnimationController(),
      builder: (BuildContext context, Widget? child) {
        (withControlPolicy as CanvasControlPolicy).canUpdateCanvasModel = true;
        return Transform(
          transform: Matrix4.identity()
            ..translate(
                (withControlPolicy as CanvasControlPolicy).transformPosition.dx,
                (withControlPolicy as CanvasControlPolicy).transformPosition.dy)
            ..scale((withControlPolicy as CanvasControlPolicy).transformScale),
          child: child,
        );
      },
      child: DragTarget<ComponentData>(
        builder: (_, __, ___) => canvasStack(canvasModel),
        onWillAccept: (ComponentData? data) => true,
        onAcceptWithDetails: (DragTargetDetails<ComponentData> details) =>
            widget.policy.receiveDraggedComponent(details, context),

      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final canvasModel = Provider.of<CanvasModel>(context);
    final canvasState = Provider.of<CanvasState>(context);

    if (widget.noEditing) return Container(
      color: canvasState.color,
      child: ClipRect(
        child: (withControlPolicy != null)
            ? canvasAnimated(canvasModel)
            : canvasStack(canvasModel),
      ),
    );

    return NotificationListener<SizeChangedLayoutNotification>(
      onNotification: gotNotification,
      child: SizeChangedLayoutNotifier(
          child: RepaintBoundary(
            key: canvasState.canvasGlobalKey,
            child: canvasState.image == null ?
            Container(
              color: canvasState.color,
              child: Center(
                child: CircularProgressIndicator(
                  color: widget.policy.loadingIndicatorColor,
                ),
              ),
            ) :
            AbsorbPointer(
              absorbing: canvasState.shouldAbsorbPointer,
              child: Listener(
                onPointerSignal: (PointerSignalEvent event) => widget.policy.onCanvasPointerSignal(event),
                child: GestureDetector(
                  onScaleStart: (details) => widget.policy.onCanvasScaleStart(details),
                  onScaleUpdate: (details) => widget.policy.onCanvasScaleUpdate(details),
                  onScaleEnd: (details) => widget.policy.onCanvasScaleEnd(details),
                  onTap: () => widget.policy.onCanvasTap(),
                  onTapDown: (TapDownDetails details) => widget.policy.onCanvasTapDown(details),
                  onTapUp: (TapUpDetails details) => widget.policy.onCanvasTapUp(details),
                  onTapCancel: () => widget.policy.onCanvasTapCancel(),
                  onLongPress: () => widget.policy.onCanvasLongPress(),
                  onLongPressStart: (LongPressStartDetails details) => widget.policy.onCanvasLongPressStart(details),
                  onLongPressMoveUpdate: (LongPressMoveUpdateDetails details) => widget.policy.onCanvasLongPressMoveUpdate(details),
                  onLongPressEnd: (LongPressEndDetails details) => widget.policy.onCanvasLongPressEnd(details),
                  onLongPressUp: () => widget.policy.onCanvasLongPressUp(),
                  child: Container(
                    color: canvasState.color,
                    child: ClipRect(
                      child: (withControlPolicy != null)
                          ? canvasAnimated(canvasModel)
                          : canvasStack(canvasModel),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      );

  }

  bool gotNotification(SizeChangedLayoutNotification notification) {
    return true;
  }

}
