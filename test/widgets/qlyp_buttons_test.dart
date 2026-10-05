import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qlyp_core/constants/qlyp_colors.dart';
import 'package:qlyp_core/widgets/qlyp_buttons.dart';
import 'package:qlyp_core/widgets/qlyp_loading.dart';

import 'design_test_helpers.dart';

void main() {
  testWidgets('QlypPrimaryButton label FR/EN and white text', (tester) async {
    await tester.pumpWidget(
      wrapDesignTest(
        child: QlypPrimaryButton(label: 'Continuer', onPressed: () {}),
      ),
    );
    final frStyle = tester.widget<Text>(find.text('Continuer')).style;
    expect(frStyle?.color, QlypColors.white);

    await tester.pumpWidget(
      wrapDesignTest(
        locale: const Locale('en', 'CA'),
        child: QlypPrimaryButton(label: 'Continue', onPressed: () {}),
      ),
    );
    expect(find.text('Continue'), findsOneWidget);
    final enStyle = tester.widget<Text>(find.text('Continue')).style;
    expect(enStyle?.color, QlypColors.white);
  });

  testWidgets('QlypPrimaryButton scales on press and keeps brand gradient',
      (tester) async {
    await tester.pumpWidget(
      wrapDesignTest(
        child: QlypPrimaryButton(label: 'Go', onPressed: () {}),
      ),
    );

    final boxBefore = tester.widget<AnimatedContainer>(
      find.descendant(
        of: find.byType(QlypPrimaryButton),
        matching: find.byType(AnimatedContainer),
      ),
    );
    expect(boxBefore.decoration, isA<BoxDecoration>());
    final decoBefore = boxBefore.decoration! as BoxDecoration;
    expect(decoBefore.gradient, isNotNull);

    await tester.startGesture(tester.getCenter(find.text('Go')));
    await tester.pump();
    final scale = tester.widget<AnimatedScale>(firstAnimatedScale());
    expect(scale.scale, lessThan(1.0));

    final boxPressed = tester.widget<AnimatedContainer>(
      find.descendant(
        of: find.byType(QlypPrimaryButton),
        matching: find.byType(AnimatedContainer),
      ),
    );
    expect((boxPressed.decoration! as BoxDecoration).gradient, isNotNull);
  });

  testWidgets('QlypPrimaryButton loading and disabled', (tester) async {
    await tester.pumpWidget(
      wrapDesignTest(
        child: const QlypPrimaryButton(
          label: 'OK',
          onPressed: null,
          isLoading: true,
        ),
      ),
    );
    expect(find.byType(QlypLoading), findsOneWidget);
  });

  testWidgets('QlypSecondaryButton outlined renders and pressable',
      (tester) async {
    await tester.pumpWidget(
      wrapDesignTest(
        child: QlypSecondaryButton(label: 'Secondaire', onPressed: () {}),
      ),
    );
    expect(find.text('Secondaire'), findsOneWidget);
    await pressCenter(tester, find.text('Secondaire'));
  });

  testWidgets('QlypPrimaryButton reduce motion still renders', (tester) async {
    await tester.pumpWidget(
      wrapDesignTest(
        disableAnimations: true,
        child: QlypPrimaryButton(label: 'Fixe', onPressed: () {}),
      ),
    );
    expect(find.text('Fixe'), findsOneWidget);
  });
}
