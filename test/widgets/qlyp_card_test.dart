import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qlyp_core/widgets/qlyp_card.dart';

import 'design_test_helpers.dart';

void main() {
  testWidgets('QlypCard renders child FR/EN', (tester) async {
    await tester.pumpWidget(
      wrapDesignTest(child: const QlypCard(child: Text('Contenu carte'))),
    );
    expect(find.text('Contenu carte'), findsOneWidget);

    await tester.pumpWidget(
      wrapDesignTest(
        locale: const Locale('en', 'CA'),
        child: const QlypCard(child: Text('Card content')),
      ),
    );
    expect(find.text('Card content'), findsOneWidget);
  });

  testWidgets('QlypCard onTap scales via QlypPressable', (tester) async {
    var tapped = false;
    await tester.pumpWidget(
      wrapDesignTest(
        child: QlypCard(onTap: () => tapped = true, child: const Text('Touch')),
      ),
    );
    await pressCenter(tester, find.text('Touch'));
    expect(tapped, isTrue);
    expect(find.byType(AnimatedScale), findsWidgets);
  });

  testWidgets('QlypCard reduce motion', (tester) async {
    await tester.pumpWidget(
      wrapDesignTest(
        disableAnimations: true,
        child: const QlypCard(child: Text('Static')),
      ),
    );
    expect(find.text('Static'), findsOneWidget);
  });
}