import 'package:flutter_test/flutter_test.dart';
import 'package:qlyp_core/qlyp_core.dart';

void main() {
  test('QlypRoutes exposes shared paths', () {
    expect(QlypRoutes.initial, '/splash');
    expect(QlypRoutes.clientTabs.length, 5);
    expect(QlypRoutes.piloteTabs.length, 5);
  });
}
