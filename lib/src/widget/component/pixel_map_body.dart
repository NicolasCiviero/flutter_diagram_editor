import 'dart:async';
import 'dart:ui' as ui;
import 'dart:typed_data';

import 'package:shape_editor/shape_editor.dart';
import 'package:shape_editor/src/widget/component/base_component_body.dart';
import 'package:flutter/material.dart';

final _imageCache = <String, PixelMapCachable>{};

class PixelMapBody extends StatelessWidget {
  final ComponentData componentData;

  PixelMapBody({
    required this.componentData,
  }) : super(key: ValueKey(componentData.id));

  static Uint8List decompressRleBinary(Uint8List encoded) {
    List<int> result = [];
    int current = 0;

    for (int count in encoded) {
      for (int i = 0; i < count; i++) {
        result.add(current);
      }
      current = current == 0 ? 255 : 0;
    }

    return Uint8List.fromList(result);
  }

  static Future<PixelMapCachable> prepareImages(Uint8List encoded, int width, int height, Color normalColor, Color highlightColor) async {
    final Uint8List decompressed = encoded.length < width * height
        ? decompressRleBinary(encoded)
        : encoded;

    Future<ui.Image> gen(Color color) async {
      final int pixelCount = width * height;
      final Uint8List imgData = Uint8List(pixelCount * 4);

      for (int i = 0; i < pixelCount; i++) {
        final int byteOffset = i * 4;
        if (decompressed[i] == 255) {
          imgData[byteOffset] = color.red;
          imgData[byteOffset + 1] = color.green;
          imgData[byteOffset + 2] = color.blue;
          imgData[byteOffset + 3] = color.alpha;
        } else {
          imgData[byteOffset + 3] = 0;
        }
      }

      final completer = Completer<ui.Image>();
      ui.decodeImageFromPixels(
        imgData,
        width,
        height,
        ui.PixelFormat.rgba8888,
        completer.complete,
      );

      final image = await completer.future;
      return image;
    }

    final ui.Image normal = await gen(normalColor);
    final ui.Image highlight = await gen(highlightColor);

    return PixelMapCachable(
      imageNormal: normal,
      imageHighlight: highlight,
      binaryData: decompressed,
    );
  }

  Future<PixelMapCachable> getOrCreateImages(String id, Uint8List encoded, int width, int height, Color normalColor, Color highlightColor) async {
    if (_imageCache.containsKey(id)) {
      return _imageCache[id]!;
    }

    final pair = await PixelMapBody.prepareImages(
      encoded,
      width,
      height,
      normalColor,
      highlightColor,
    );

    _imageCache[id] = pair;
    return pair;
  }
  @override
  Widget build(BuildContext context) {
    final data = componentData.encodedBinaryData;
    if (data == null) return const SizedBox();
    final width = componentData.size.width.toInt();
    final height = componentData.size.height.toInt();

    final isHighlighted = componentData.isHighlightVisible;
    final cached = _imageCache[componentData.id];

    if (cached != null) {
      final image = isHighlighted ? cached.imageHighlight : cached.imageNormal;
      final pixels = cached.binaryData;
      return _buildWithResources(image, pixels, width, height);
    }

    return FutureBuilder<PixelMapCachable>(
      future: getOrCreateImages(componentData.id, data, width, height, componentData.color, componentData.highlightColor),
      builder: (context, snapshot) {
        final cache = snapshot.data;
        final image = cache == null ? null : isHighlighted ? cache.imageHighlight : cache.imageNormal;
        final pixels = cache?.binaryData;
        return _buildWithResources(image, pixels, width, height);
      },
    );
  }

  Widget _buildWithResources(ui.Image? image, Uint8List? pixels, int width, int height) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = Size(constraints.maxWidth, constraints.maxHeight);
        return BaseComponentBody(
          componentData: componentData,
          componentPainter: PixelMapPainter(
            image: image,
            pixelData: pixels,
            imageWidth: width,
            imageHeight: height,
            availableSize: size,
          ),
        );
      },
    );
  }
}

class PixelMapPainter extends CustomPainter {
  final ui.Image? image;
  final Uint8List? pixelData;
  final int imageWidth;
  final int imageHeight;
  final availableSize;

  PixelMapPainter({
    required this.image,
    required this.pixelData,
    required this.imageWidth,
    required this.imageHeight,
    required this.availableSize,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (image == null) return;
    //availableSize = size;
    final paint = Paint();
    canvas.drawImageRect(
      image!,
      Rect.fromLTWH(0, 0, imageWidth.toDouble(), imageHeight.toDouble()),
      Rect.fromLTWH(0, 0, availableSize.width, availableSize.height),
      paint,
    );
  }

  @override
  bool hitTest(Offset position) {
    if (availableSize.width == 0 || availableSize.height == 0) return false;
    if (pixelData == null || image == null) return false;

    final scaleX = image!.width / availableSize.width;
    final scaleY = image!.height / availableSize.height;

    final int x = (position.dx * scaleX).floor();
    final int y = (position.dy * scaleY).floor();

    if (x < 0 || y < 0 || x >= image!.width || y >= image!.height) return false;

    final int index = y * image!.width + x;
    return pixelData![index] > 0;
  }

  @override
  bool shouldRepaint(covariant PixelMapPainter oldDelegate) {
    return oldDelegate.image != image ||
        oldDelegate.pixelData != pixelData ||
        oldDelegate.imageWidth != imageWidth ||
        oldDelegate.imageHeight != imageHeight;
  }
}


class PixelMapCachable {
  final ui.Image imageNormal;
  final ui.Image imageHighlight;
  final Uint8List binaryData;

  PixelMapCachable({
    required this.imageNormal,
    required this.imageHighlight,
    required this.binaryData,
  });
}

class GeneratedImage {
  final ui.Image image;
  final Uint8List pixels;

  GeneratedImage(this.image, this.pixels);
}

