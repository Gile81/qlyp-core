import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';

import 'billing_golden_harness.dart';

void main() {
  testWidgets('billing golden harness uses 400x1200 at DPR 1', (tester) async {
    configureBillingGoldenSurface(tester);
    expect(tester.view.physicalSize, const Size(400, 1200));
    expect(tester.view.devicePixelRatio, 1.0);
  });
}
