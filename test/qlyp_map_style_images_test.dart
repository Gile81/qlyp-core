import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:qlyp_core/services/qlyp_map_style_images.dart';

void main() {
  test('qlypMapStyleImageBytesAreValidPng detects PNG magic', () {
    expect(qlypMapStyleImageBytesAreValidPng(Uint8List.fromList([0x89, 0x50, 0x4E, 0x47])), isTrue);
    expect(qlypMapStyleImageBytesAreValidPng(Uint8List.fromList([0, 0, 0])), isFalse);
  });
}
