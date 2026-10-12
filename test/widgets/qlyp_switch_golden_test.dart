import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qlyp_core/config/qlyp_theme.dart';
import 'package:qlyp_core/widgets/qlyp_switch.dart';

void main() {
  testWidgets('QlypSwitch on and off', (tester) async {
    var value = false;
    await tester.pumpWidget(
      MaterialApp(
        theme: QlypTheme.light(),
        home: Scaffold(
          body: Center(
            child: QlypSwitch(
              value: value,
              onChanged: (v) => value = v,
            ),
          ),
        ),
      ),
    );
    await expectLater(
      find.byType(QlypSwitch),
      matchesGoldenFile('goldens/qlyp_switch_off.png'),
    );

    value = true;
    await tester.pumpWidget(
      MaterialApp(
        theme: QlypTheme.light(),
        home: Scaffold(
          body: Center(
            child: QlypSwitch(
              value: value,
              onChanged: (v) => value = v,
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await expectLater(
      find.byType(QlypSwitch),
      matchesGoldenFile('goldens/qlyp_switch_on.png'),
    );
  });
}
