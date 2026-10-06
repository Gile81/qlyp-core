import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qlyp_core/constants/qlyp_colors.dart';
import 'package:qlyp_core/widgets/qlyp_buttons.dart';

import 'design_test_helpers.dart';

void main() {
  testWidgets('primary large default height and expanded', (tester) async {
    await tester.pumpWidget(
      wrapDesignTest(
        child: QlypPrimaryButton(label: 'Continuer', onPressed: () {}),
      ),
    );
    final box = tester.getSize(
      find.descendant(
        of: find.byType(QlypPrimaryButton),
        matching: find.byType(AnimatedContainer),
      ),
    );
    expect(box.height, QlypStyle.buttonHeightLarge);
    expect(box.width, tester.getSize(find.byType(Scaffold)).width);
  });

  testWidgets('button sizes medium and small not expanded by default', (tester) async {
    await tester.pumpWidget(
      wrapDesignTest(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            QlypPrimaryButton(
              label: 'M',
              onPressed: () {},
              size: QlypButtonSize.medium,
            ),
            QlypPrimaryButton(
              label: 'S',
              onPressed: () {},
              size: QlypButtonSize.small,
            ),
          ],
        ),
      ),
    );
    Finder sizedPrimary(String label) => find.byWidgetPredicate(
          (w) => w is QlypPrimaryButton && w.label == label,
        );

    expect(tester.getSize(sizedPrimary('M')).height, QlypStyle.buttonHeightMedium);
    expect(tester.getSize(sizedPrimary('S')).height, QlypStyle.buttonHeightSmall);
    expect(
      tester.getSize(sizedPrimary('M')).width,
      lessThan(tester.getSize(find.byType(Scaffold)).width),
    );
  });

  testWidgets('QlypTextButton has semantics label', (tester) async {
    await tester.pumpWidget(
      wrapDesignTest(
        child: QlypTextButton(label: 'Plus tard', onPressed: () {}),
      ),
    );
    expect(find.text('Plus tard'), findsOneWidget);
    expect(find.byType(InkWell), findsNothing);
    expect(
      tester.getSemantics(find.byType(QlypTextButton)).label,
      contains('Plus tard'),
    );
  });

  testWidgets('QlypIconButton requires accessibility label', (tester) async {
    await tester.pumpWidget(
      wrapDesignTest(
        child: QlypIconButton(
          icon: Icons.close,
          semanticsLabel: 'Fermer',
          onPressed: () {},
        ),
      ),
    );
    expect(find.bySemanticsLabel('Fermer'), findsOneWidget);
    final box = tester.getSize(find.byType(QlypIconButton));
    expect(box.width, QlypStyle.iconButtonSize);
    expect(box.height, QlypStyle.iconButtonSize);
  });

  testWidgets('secondary danger has red border without brand gradient', (tester) async {
    await tester.pumpWidget(
      wrapDesignTest(
        child: QlypSecondaryButton(
          label: 'Supprimer',
          onPressed: () {},
          tone: QlypButtonTone.danger,
        ),
      ),
    );
    final decoration = tester.widget<AnimatedContainer>(find.byType(AnimatedContainer).first).decoration! as BoxDecoration;
    expect(decoration.gradient, isNull);
    final border = decoration.border! as Border;
    expect(border.top.color, QlypColors.red);
  });
}
