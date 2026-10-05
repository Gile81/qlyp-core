import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qlyp_core/widgets/qlyp_glass_sheet.dart';

import 'design_test_helpers.dart';

void main() {
  testWidgets('QlypGlassSheet.show displays builder content', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) {
            return TextButton(
              onPressed: () {
                QlypGlassSheet.show<void>(
                  context: context,
                  builder: (_) => const Text('Sheet body'),
                );
              },
              child: const Text('open'),
            );
          },
        ),
      ),
    );

    await tester.tap(find.text('open'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.text('Sheet body'), findsOneWidget);
  });

  testWidgets('QlypGlassSheet reduce motion still opens', (tester) async {
    await tester.pumpWidget(
      wrapDesignTest(
        disableAnimations: true,
        child: Builder(
          builder: (context) {
            return TextButton(
              onPressed: () {
                QlypGlassSheet.show<void>(
                  context: context,
                  builder: (_) => const Text('Static sheet'),
                );
              },
              child: const Text('open'),
            );
          },
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pump();
    expect(find.text('Static sheet'), findsOneWidget);
  });
}
