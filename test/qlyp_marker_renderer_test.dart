import 'package:flutter_test/flutter_test.dart';
import 'package:qlyp_core/services/qlyp_marker_renderer.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('renderSvgMarker returns non-empty PNG bytes for sedan_dark.svg', () async {
    const assetPath = 'assets/markers/sedan_dark.svg';
    final bytes = await QlypMarkerRenderer.renderSvgMarker(
      assetPath,
      sizePx: 64,
    );

    expect(bytes, isNotEmpty);
    expect(bytes[0], 0x89);
    expect(bytes[1], 0x50);
    expect(bytes[2], 0x4E);
    expect(bytes[3], 0x47);
  });
}
