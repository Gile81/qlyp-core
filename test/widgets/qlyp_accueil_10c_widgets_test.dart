import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:phosphor_icons/phosphor_icons.dart';
import 'package:qlyp_core/constants/qlyp_colors.dart';
import 'package:qlyp_core/constants/qlyp_motion.dart';
import 'package:qlyp_core/widgets/qlyp_bottom_nav.dart';
import 'package:qlyp_core/widgets/qlyp_floating_nav_pill.dart';
import 'package:qlyp_core/widgets/qlyp_landing_cascade.dart';
import 'package:qlyp_core/widgets/qlyp_logo_refresh.dart';
import 'package:qlyp_core/widgets/qlyp_paged_row.dart';

import 'design_test_helpers.dart';

const _navItems = [
  QlypNavItem(icon: Icons.home_outlined, label: 'Accueil'),
  QlypNavItem(icon: Icons.grid_view_outlined, label: 'Services'),
  QlypNavItem(icon: Icons.event_note_outlined, label: 'Activite'),
  QlypNavItem(icon: Icons.groups_2_outlined, label: 'Cast'),
  QlypNavItem(icon: Icons.person_outline, label: 'Compte'),
];

Finder _pillTransform() =>
    find.descendant(of: find.byType(QlypFloatingNavPill), matching: find.byType(Transform));

void main() {
  test('QlypFloatingNavPill capsule positions', () {
    expect(QlypFloatingNavPill.capsuleLeftForIndex(0), 8);
    expect(QlypFloatingNavPill.capsuleLeftForIndex(2), closeTo(8 + 60.4 * 2, 0.01));
  });

  testWidgets('QlypFloatingNavPill size 312x58', (tester) async {
    await tester.pumpWidget(
      wrapDesignTest(
        child: QlypFloatingNavPill(
          currentIndex: 0,
          onTap: (_) {},
          items: _navItems,
        ),
      ),
    );
    final pill = find.byWidgetPredicate(
      (w) =>
          w is SizedBox &&
          w.width == QlypStyle.navPillWidth &&
          w.height == QlypStyle.navPillHeight,
    );
    expect(tester.getSize(pill), const Size(312, 58));
  });

  testWidgets('QlypFloatingNavPill hidden slides 112px', (tester) async {
    var hidden = false;
    await tester.pumpWidget(
      wrapDesignTest(
        child: StatefulBuilder(
          builder: (context, setState) {
            return QlypFloatingNavPill(
              currentIndex: 0,
              onTap: (_) {},
              items: _navItems,
              hidden: hidden,
            );
          },
        ),
      ),
    );
    hidden = true;
    await tester.pumpWidget(
      wrapDesignTest(
        child: QlypFloatingNavPill(
          currentIndex: 0,
          onTap: (_) {},
          items: _navItems,
          hidden: true,
        ),
      ),
    );
    await tester.pump(kDurNavHide);
    final transform = tester.widget<Transform>(_pillTransform().first);
    expect(transform.transform.getTranslation().y, QlypStyle.navHideOffset);
  });

  testWidgets('QlypLandIn and QlypTextReveal reduce motion', (tester) async {
    await tester.pumpWidget(
      wrapDesignTest(
        disableAnimations: true,
        child: QlypLandingScope(
          totalDuration: kDurLand,
          child: Column(
            children: const [
              QlypLandIn(child: Text('Bloc')),
              QlypTextReveal(child: Text('Texte')),
            ],
          ),
        ),
      ),
    );
    expect(find.text('Bloc'), findsOneWidget);
    expect(find.text('Texte'), findsOneWidget);
  });

  testWidgets('QlypLandIn animates opacity', (tester) async {
    final scopeKey = GlobalKey<QlypLandingScopeState>();
    await tester.pumpWidget(
      wrapDesignTest(
        child: QlypLandingScope(
          key: scopeKey,
          totalDuration: kDurLand,
          child: const QlypLandIn(child: Text('Bloc')),
        ),
      ),
    );
    expect(
      tester.widget<Opacity>(find.byType(Opacity)).opacity,
      0,
    );
    scopeKey.currentState!.play();
    await tester.pump(kDurLand ~/ 2);
    expect(tester.widget<Opacity>(find.byType(Opacity)).opacity, lessThan(1));
    await tester.pump(kDurLand);
    expect(tester.widget<Opacity>(find.byType(Opacity)).opacity, 1);
  });

  testWidgets('QlypPagedRow shows 3 items at 390px', (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      wrapDesignTest(
        child: SizedBox(
          width: 390,
          child: QlypPagedRow(
            hint: false,
            itemCount: 6,
            itemBuilder: (_, i) => SizedBox(
              height: 40,
              child: Center(child: Text('Item $i')),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Item 0'), findsOneWidget);
    expect(find.text('Item 1'), findsOneWidget);
    expect(find.text('Item 2'), findsOneWidget);
    final clip = tester.getRect(find.byType(QlypPagedRow));
    final item3 = tester.getRect(find.text('Item 3'));
    expect(clip.overlaps(item3), isFalse);

    final pageWidth = QlypPagedRow.pageWidthForScreen(390);
    expect(pageWidth, 368);

    await tester.drag(find.byType(PageView), const Offset(-368, 0));
    await tester.pumpAndSettle();
    expect(find.text('Item 3'), findsOneWidget);
  });

  testWidgets('QlypLogoRefresh calls onRefresh once', (tester) async {
    var count = 0;
    await tester.pumpWidget(
      wrapDesignTest(
        child: QlypLogoRefresh(
          onRefresh: () async {
            count++;
          },
          child: ListView.builder(
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            itemCount: 20,
            itemBuilder: (_, i) => ListTile(title: Text('Row $i')),
          ),
        ),
      ),
    );
    await tester.drag(find.byType(ListView), const Offset(0, 120));
    await tester.pump();
    await tester.pump(kDurRefreshPull);
    await tester.pump(kDurRefreshPull);
    await tester.pump(kDurLogoStrokeDelay + kDurLogoStroke);
    expect(count, 1);
  });

  testWidgets('golden QlypFloatingNavPill light', (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      wrapDesignTest(
        child: Align(
          alignment: Alignment.bottomCenter,
          child: QlypFloatingNavPill(
            currentIndex: 0,
            onTap: _noop,
            items: _navItems,
            variant: QlypFloatingNavPillVariant.light,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('goldens/qlyp_floating_nav_pill_light.png'),
    );
  });

  testWidgets('golden QlypFloatingNavPill dark', (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      wrapDesignTest(
        child: DecoratedBox(
          decoration: const BoxDecoration(
            gradient: LinearGradient(colors: QlypColors.gradientDeepDark),
          ),
          child: Align(
            alignment: Alignment.bottomCenter,
            child: QlypFloatingNavPill(
              currentIndex: 1,
              onTap: _noop,
              items: _navItems,
              variant: QlypFloatingNavPillVariant.dark,
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('goldens/qlyp_floating_nav_pill_dark.png'),
    );
  });
}

void _noop(int _) {}
