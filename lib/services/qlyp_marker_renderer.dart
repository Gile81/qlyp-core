import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Renders qlyp-core SVG map markers to PNG bytes for map SDKs (Google / Mapbox).
class QlypMarkerRenderer {
  QlypMarkerRenderer._();

  static final Map<String, Uint8List> _cache = {};

  /// Renders [assetPath] (e.g. packages/qlyp_core/assets/markers/sedan_dark.svg)
  /// to PNG bytes sized [sizePx] x [sizePx], preserving aspect ratio.
  static Future<Uint8List> renderSvgMarker(
    String assetPath, {
    required int sizePx,
  }) async {
    if (sizePx <= 0) {
      return Uint8List(0);
    }

    final cacheKey = '$assetPath@$sizePx';
    final cached = _cache[cacheKey];
    if (cached != null) {
      return cached;
    }

    final bytes = await _render(assetPath, sizePx);
    _cache[cacheKey] = bytes;
    return bytes;
  }

  static void clearCache() => _cache.clear();

  static Future<Uint8List> _render(String assetPath, int sizePx) async {
    PictureInfo? pictureInfo;
    ui.Image? image;

    try {
      pictureInfo = await vg.loadPicture(
        SvgAssetLoader(assetPath),
        null,
      );

      final svgSize = pictureInfo.size;
      if (svgSize.width <= 0 || svgSize.height <= 0) {
        return Uint8List(0);
      }

      final scale = sizePx / math.max(svgSize.width, svgSize.height);
      final drawWidth = svgSize.width * scale;
      final drawHeight = svgSize.height * scale;
      final offsetX = (sizePx - drawWidth) / 2;
      final offsetY = (sizePx - drawHeight) / 2;

      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder);
      canvas.translate(offsetX, offsetY);
      canvas.scale(scale);
      canvas.drawPicture(pictureInfo.picture);

      final picture = recorder.endRecording();
      image = await picture.toImage(sizePx, sizePx);
      final byteData =
          await image.toByteData(format: ui.ImageByteFormat.png);

      if (byteData == null) {
        return Uint8List(0);
      }

      return byteData.buffer.asUint8List();
    } catch (_) {
      return Uint8List(0);
    } finally {
      pictureInfo?.picture.dispose();
      image?.dispose();
    }
  }
}
