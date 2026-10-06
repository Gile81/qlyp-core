import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:phosphor_icons/phosphor_icons.dart';
import 'package:qlyp_core/config/qlyp_page_transitions.dart';
import 'package:qlyp_core/config/qlyp_theme.dart';
import 'package:qlyp_core/constants/qlyp_motion.dart';
import 'package:qlyp_core/widgets/qlyp_accordion.dart';
import 'package:qlyp_core/widgets/qlyp_hero.dart';
import 'package:qlyp_core/widgets/qlyp_map_button.dart';
import 'package:qlyp_core/widgets/qlyp_slide_in.dart';
import 'package:qlyp_core/widgets/qlyp_switch.dart';

import 'design_test_helpers.dart';

void main() {
  testWidgets('QlypTheme page transitions builder', (tester) async {
    final theme = QlypTheme.light();
    expect(
      theme.pageTransitionsTheme.builders[TargetPlatform.android],
      isA<QlypSlidePageTransitionsBuilder>(),
    );
  });

  testWidgets('QlypSlideIn animates then settles', (tester) async {
    await tester.pumpWidget(
      wrapDesignTest(child: const QlypSlideIn(child: Text('Ligne'))),
    );
    await tester.pump();
    await tester.pump(kDurSlideIn);
    expect(find.text('Ligne'), findsOneWidget);
  });

  testWidgets('QlypAccordion toggles size', (tester) async {
    await tester.pumpWidget(
      wrapDesignTest(
        child: QlypAccordion(title: 'FAQ', child: const Text('Answer')),
      ),
    );
    final collapsed = tester.widget<SizeTransition>(find.byType(SizeTransition));
    expect(collapsed.sizeFactor.value, 0);
    await tester.tap(find.text('FAQ'));
    await tester.pump();
    await tester.pump(kDurList);
    expect(tester.widget<SizeTransition>(find.byType(SizeTransition)).sizeFactor.value, 1);
  });

  testWidgets('QlypSwitch toggles', (tester) async {
    var on = false;
    await tester.pumpWidget(
      wrapDesignTest(
        child: QlypSwitch(value: on, onChanged: (v) => on = v),
      ),
    );
    await tester.tap(find.byType(QlypSwitch));
    await tester.pump();
    expect(on, isTrue);
  });

  testWidgets('QlypHero wraps Hero', (tester) async {
    await tester.pumpWidget(
      wrapDesignTest(
        child: QlypHero(tag: 'tile-1', child: const Text('Tile')),
      ),
    );
    expect(find.byType(Hero), findsOneWidget);
  });

  testWidgets('QlypMapButton danger variant', (tester) async {
    await tester.pumpWidget(
      wrapDesignTest(
        child: QlypMapButton(
          icon: PhosphorIcons.siren(),
          variant: QlypMapButtonVariant.danger,
          onTap: () {},
        ),
      ),
    );
    expect(find.byType(QlypMapButton), findsOneWidget);
  });
}