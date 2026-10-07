import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/widgets.dart';

import '../constants/qlyp_colors.dart';

enum BookingRouteMarkerRole { pickup, intermediateStop, destination }

/// Label on map pin: A, 1..N, or B.
String bookingRouteMarkerLabel(
  BookingRouteMarkerRole role, {
  int stopIndex = 0,
}) {
  switch (role) {
    case BookingRouteMarkerRole.pickup:
      return 'A';
    case BookingRouteMarkerRole.destination:
      return 'B';
    case BookingRouteMarkerRole.intermediateStop:
      return '${stopIndex + 1}';
  }
}

/// Renders a circular numbered/letter pin for booking preview maps.
Future<Uint8List> renderBookingRouteMarkerPng({
  required String label,
  required bool nightMode,
  int sizePx = 44,
}) async {
  if (sizePx <= 0 || label.isEmpty) return Uint8List(0);

  final fill = nightMode ? QlypColors.midnightMid : QlypColors.midnightQlyp;
  const ring = QlypColors.emeraldLight;
  const textColor = QlypColors.white;

  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder);
  final center = Offset(sizePx / 2, sizePx / 2);
  final radius = sizePx * 0.38;

  final fillPaint = Paint()..color = fill;
  final ringPaint = Paint()
    ..color = ring
    ..style = PaintingStyle.stroke
    ..strokeWidth = sizePx * 0.06;

  canvas.drawCircle(center, radius, fillPaint);
  canvas.drawCircle(center, radius, ringPaint);

  final fontSize = label.length > 1 ? sizePx * 0.32 : sizePx * 0.42;
  final builder = ui.ParagraphBuilder(
    ui.ParagraphStyle(
      textAlign: TextAlign.center,
      fontSize: fontSize,
      fontWeight: FontWeight.w700,
    ),
  )
    ..pushStyle(ui.TextStyle(color: textColor))
    ..addText(label);

  final paragraph = builder.build()
    ..layout(ui.ParagraphConstraints(width: sizePx.toDouble()));

  canvas.drawParagraph(
    paragraph,
    Offset(0, center.dy - paragraph.height / 2),
  );

  final picture = recorder.endRecording();
  final image = await picture.toImage(sizePx, sizePx);
  final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
  image.dispose();
  if (byteData == null) return Uint8List(0);
  return byteData.buffer.asUint8List();
}
