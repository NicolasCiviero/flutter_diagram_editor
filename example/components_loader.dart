import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:shape_editor/shape_editor.dart';

List<ComponentData> loadComponentsFromJson(String jsonString, {
      Color color = Colors.orange,
      Color borderColor = Colors.deepOrange,
      double borderWidth = 2.0,
      Size minSize = const Size(5, 5),
    }) {
  final data = jsonDecode(jsonString);
  final shapes = data['Shapes'] as List<dynamic>;

  return shapes.map((shape) {
    final verticesData = shape['Vertices'] as List<dynamic>? ?? [];
    final vertices = verticesData.map((v) => Offset((v['X'] ?? 0).toDouble(), (v['Y'] ?? 0).toDouble())).toList();

    return ComponentData(
      text: '',//shape['Name'] ?? '',
      type: shape['Type'] ?? 'rectangle',
      position: Offset((shape['X'] ?? 0).toDouble(), (shape['Y'] ?? 0).toDouble()),
      size: Size((shape['Width'] ?? 0).toDouble(), (shape['Height'] ?? 0).toDouble()),
      minSize: minSize,
      color: color,
      borderColor: borderColor,
      borderWidth: borderWidth,
      vertices: vertices,
    );
  }).toList();
}
