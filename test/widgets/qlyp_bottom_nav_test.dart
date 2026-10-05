import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qlyp_core/widgets/qlyp_bottom_nav.dart';

import 'design_test_helpers.dart';

void main() {
  testWidgets('QlypBottomNav renders default FR labels', (tester) async {
    await tester.pumpWidget(
      wrapDesignTest(
        child: QlypBottomNav(
          currentIndex: 0,
          onTap: (_) {},
        ),
      ),
    );
    expect(find.text('Accueil'), findsOneWidget);
  });

  testWidgets('QlypBottomNav EN custom items', (tester) async {
    const items = [
      QlypNavItem(icon: Icons.home_outlined, label: 'Home'),
      QlypNavItem(icon: Icons.person_outline, label: 'Account'),
    ];
    await tester.pumpWidget(
      wrapDesignTest(
        locale: const Locale('en', 'CA'),
        child: QlypBottomNav(
          currentIndex: 1,
          onTap: (_) {},
          items: items,
        ),
      ),
    );
    expect(find.text('Account'), findsOneWidget);
  });

  testWidgets('QlypBottomNav onTap fires', (tester) async {
    var index = 0;
    await tester.pumpWidget(
      wrapDesignTest(
        child: QlypBottomNav(
          currentIndex: index,
          onTap: (i) => index = i,
          items: const [
            QlypNavItem(icon: Icons.home_outlined, label: 'A'),
            QlypNavItem(icon: Icons.grid_view, label: 'B'),
          ],
        ),
      ),
    );
    await tester.tap(find.text('B'));
    await tester.pump();
    expect(index, 1);
  });

  testWidgets('QlypBottomNav reduce motion', (tester) async {
    await tester.pumpWidget(
      wrapDesignTest(
        disableAnimations: true,
        child: QlypBottomNav(currentIndex: 0, onTap: (_) {}),
      ),
    );
    expect(find.byType(QlypBottomNav), findsOneWidget);
  });
}
