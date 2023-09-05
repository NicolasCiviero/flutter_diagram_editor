import 'package:flutter/material.dart';
import 'dart:math';
import 'dart:ui' as ui;
import 'package:event/event.dart';

import 'model/component_data.dart';

class CanvasState with ChangeNotifier {
  final componentUpdateEvent = Event<ComponentEvent>();

  Offset _position = Offset(0, 0);
  double _scale = 1.0;

  double mouseScaleSpeed = 0.8;

  double maxScale = 8.0;
  double minScale = 1.0;

  ui.Image? _image;
  Size _imageSize = Size(0,0);
  ui.Image? get image => _image;
  Size get imageSize => _imageSize;
  setImage(ui.Image image) {
    _image = image;
    _imageSize = Size(image.width.toDouble(), image.height.toDouble());
    setPosition(Offset.zero);

  }

  Size? _canvasSize;
  Size? get canvasSize {
    if (_canvasSize == null) updateCanvasSize();
    return _canvasSize;
  }
  updateCanvasSize(){
    final RenderBox renderBox = canvasGlobalKey.currentContext?.findRenderObject() as RenderBox;
    if (renderBox == null) return null;
    _canvasSize = renderBox.size;
  }

  double canvasAutoScale() {
    var size = canvasSize;
    if (size == null) return 1;
    return min(size.height / imageSize.height, size.width / imageSize.width);
  }
  double canvasFinalScale() {
    return _scale * canvasAutoScale();
  }

  Color color = Colors.white;

  GlobalKey canvasGlobalKey = GlobalKey();

  bool shouldAbsorbPointer = false;

  bool isInitialized = false;

  Offset get position => _position;

  double get scale => _scale;

  updateCanvas() {
    notifyListeners();
  }

  setPosition(Offset position) {
    _position = position;
    _verifyPosition();
  }

  setScale(double scale) {
    _scale = scale;
  }

  updatePosition(Offset offset) {
    _position += offset;
    _verifyPosition();
  }

  _verifyPosition(){
    var position = _position;
    var canvas = canvasSize;
    var img = imageSize * canvasFinalScale();
    canvas ??= img;

    var dx = position.dx;
    var dy = position.dy;

    if (img.width < canvas.width) dx = (canvas.width - img.width) / 2;
    else {
      dx = max(dx, canvas.width - img.width);
      dx = min(dx, 0);
    }

    if (img.height < canvas.height) dy = (canvas.height - img.height) / 2;
    else {
      dy = max(dy, canvas.height - img.height);
      dy = min(dy, 0);
    }
    position = Offset(dx, dy);

    _position = position;
  }

  updateScale(double scale) {
    _scale *= scale;
  }

  resetCanvasView() {
    _position = Offset(0, 0);
    _scale = 1.0;
    notifyListeners();
  }

  Offset fromCanvasCoordinates(Offset position) {
    return (position - this.position) / scale;
  }

  Offset toCanvasCoordinates(Offset position) {
    return position * scale + this.position;
  }

  Offset fromCanvasFinalCoordinates(Offset position) {
    return (position - this.position) / scale / canvasAutoScale();
  }

  Offset toCanvasFinalCoordinates(Offset position) {
    return position * scale * canvasAutoScale() + this.position;
  }
}
