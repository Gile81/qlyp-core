import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qlyp_core/constants/qlyp_colors.dart';
import 'package:qlyp_core/constants/qlyp_motion.dart';
import 'package:qlyp_core/widgets/qlyp_floating_nav_pill.dart';

import 'design_test_helpers.dart';
import 'pill_golden_fonts.dart';
import 'pill_golden_harness.dart';

const _goldenRootKey = Key('pill_golden_root');

Finder _pillRoot() => find.byKey(_goldenRootKey);

Finder pillSizedBoxFinder() => find.byWidgetPredicate(
      (w) =>
          w is SizedBox &&
          w.width == QlypStyle.navPillWidth &&
          w.height == QlypStyle.navPillHeight,
    );

Finder pillHideTransformFinder() => find.descendant(
      of: find.byType(QlypFloatingNavPill),
      matching: find.byWidgetPredicate(
        (w) {
          if (w is! Transform) return false;
          final child = w.child;
          return child is SizedBox &&
              child.width == QlypStyle.navPillWidth &&
              child.height == QlypStyle.navPillHeight;
        },
      ),
    );

Finder capsuleFinder() => find.descendant(
      of: find.byType(QlypFloatingNavPill),
      matching: find.byWidgetPredicate(
        (w) =>
            w is AnimatedPositioned &&
            w.width == QlypStyle.navPillCapsuleWidth,
      ),
    );

void main() {
  setUpAll(() async {
    await loadPillGoldenFonts(phosphor: true);
    QlypFloatingNavPill.goldenTestMode = true;
  });

  tearDownAll(() {
    QlypFloatingNavPill.goldenTestMode = false;
  });

  setUp(() async {
    await loadPillGoldenFonts(phosphor: true);
  });

  group('placement', () {
    testWidgets('Scaffold bottomNavigationBar height and body padding (34)', (tester) async {
      await tester.binding.setSurfaceSize(kPillGoldenSize);
      addTearDown(() => tester.binding.setSurfaceSize(null));

      const viewBottom = 34.0;
      await tester.pumpWidget(
        RepaintBoundary(
          key: _goldenRootKey,
          child: pillPiloteScaffoldHarness(
            currentIndex: 0,
            viewBottom: viewBottom,
          ),
        ),
      );
      await tester.pumpAndSettle();

      final barHeight =
          viewBottom + QlypStyle.navPillGap + QlypStyle.navPillHeight;
      final pillBox = find.descendant(
        of: find.byType(QlypFloatingNavPill),
        matching: pillSizedBoxFinder(),
      );
      final listBox = tester.getRect(find.byType(ListView));
      final pillRect = tester.getRect(pillBox);
      expect(kPillGoldenSize.height - pillRect.top, barHeight);
      expect(listBox.height, greaterThan(700));
      expect(pillRect.height, QlypStyle.navPillHeight);
      expect(
        pillRect.bottom,
        kPillGoldenSize.height - viewBottom - QlypStyle.navPillGap,
      );
      expect(listBox.bottom, lessThanOrEqualTo(pillRect.top + 1));
    });

    testWidgets('Scaffold bottomNavigationBar (48)', (tester) async {
      await tester.binding.setSurfaceSize(kPillGoldenSize);
      addTearDown(() => tester.binding.setSurfaceSize(null));

      const viewBottom = 48.0;
      await tester.pumpWidget(
        pillPiloteScaffoldHarness(currentIndex: 0, viewBottom: viewBottom),
      );
      await tester.pumpAndSettle();

      final barHeight =
          viewBottom + QlypStyle.navPillGap + QlypStyle.navPillHeight;
      final pillBox = find.descendant(
        of: find.byType(QlypFloatingNavPill),
        matching: pillSizedBoxFinder(),
      );
      final listBox = tester.getRect(find.byType(ListView));
      final pillRect = tester.getRect(pillBox);
      expect(kPillGoldenSize.height - pillRect.top, barHeight);
      expect(listBox.height, greaterThan(700));
      expect(pillRect.height, QlypStyle.navPillHeight);
      expect(
        pillRect.bottom,
        kPillGoldenSize.height - viewBottom - QlypStyle.navPillGap,
      );
      expect(listBox.bottom, lessThanOrEqualTo(pillRect.top + 1));
    });

    testWidgets('Stack expand keeps pill bottom at 844 - (zone + 6)', (tester) async {
      await tester.binding.setSurfaceSize(kPillGoldenSize);
      addTearDown(() => tester.binding.setSurfaceSize(null));

      const viewBottom = 34.0;
      await tester.pumpWidget(
        pillClientStackHarness(currentIndex: 0, viewBottom: viewBottom),
      );
      await tester.pumpAndSettle();

      expect(
        tester.getRect(pillSizedBoxFinder().first).bottom,
        kPillGoldenSize.height - viewBottom - QlypStyle.navPillGap,
      );
    });
  });

  group('motion numbers', () {
    testWidgets('capsule left at tab switch 0 to 2', (tester) async {
      var index = 0;
      await tester.pumpWidget(
        wrapDesignTest(
          child: StatefulBuilder(
            builder: (context, setState) {
              return QlypFloatingNavPill(
                currentIndex: index,
                onTap: (i) => setState(() => index = i),
                items: materialNavItems,
                bottomInset: 0,
              );
            },
          ),
        ),
      );
      await tester.pumpAndSettle();
      final left0 = tester.getRect(capsuleFinder().first).left;

      final tab2 = find.descendant(
        of: find.byType(QlypFloatingNavPill),
        matching: find.byIcon(materialNavItems[2].icon),
      );
      await pressCenter(tester, tab2);
      await tester.pump(const Duration(milliseconds: 250));
      final left2 = tester.getRect(capsuleFinder().first).left;
      expect(
        left2 - left0,
        closeTo(
          QlypFloatingNavPill.capsuleLeftForIndex(2) -
              QlypFloatingNavPill.capsuleLeftForIndex(0),
          0.5,
        ),
      );
    });

    testWidgets('inactive icon offset animates 6 to 0 in 120 ms', (tester) async {
      var index = 0;
      late StateSetter setIndex;
      final icon0 = find.descendant(
        of: find.byType(QlypFloatingNavPill),
        matching: find.byIcon(materialNavItems[0].icon),
      );
      final icon1 = find.descendant(
        of: find.byType(QlypFloatingNavPill),
        matching: find.byIcon(materialNavItems[1].icon),
      );

      await tester.pumpWidget(
        wrapDesignTest(
          child: StatefulBuilder(
            builder: (context, setState) {
              setIndex = setState;
              return QlypFloatingNavPill(
                currentIndex: index,
                onTap: (_) {},
                items: materialNavItems,
                bottomInset: 0,
              );
            },
          ),
        ),
      );
      await tester.pumpAndSettle();
      final activeBaselineY = tester.getTopLeft(icon0).dy;

      setIndex(() => index = 1);
      await tester.pumpAndSettle();
      expect(
        tester.getTopLeft(icon0).dy - tester.getTopLeft(icon1).dy,
        closeTo(6, 2.5),
      );

      setIndex(() => index = 0);
      await tester.pump(const Duration(milliseconds: 60));
      expect(tester.getTopLeft(icon0).dy, greaterThan(activeBaselineY));
      expect(tester.getTopLeft(icon0).dy, lessThan(activeBaselineY + 10));

      await tester.pump(const Duration(milliseconds: 60));
      expect(tester.getTopLeft(icon0).dy, closeTo(activeBaselineY, 1.5));
      expect(
        tester.getTopLeft(icon1).dy - tester.getTopLeft(icon0).dy,
        closeTo(6, 3.5),
      );
    });

    testWidgets('hide offset reaches 112 at 520 ms', (tester) async {
      await tester.pumpWidget(
        wrapDesignTest(
          child: QlypFloatingNavPill(
            currentIndex: 0,
            onTap: (_) {},
            items: materialNavItems,
            hidden: false,
            bottomInset: 0,
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.pumpWidget(
        wrapDesignTest(
          child: QlypFloatingNavPill(
            currentIndex: 0,
            onTap: (_) {},
            items: materialNavItems,
            hidden: true,
            bottomInset: 0,
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 260));
      final yMid = tester
          .widget<Transform>(pillHideTransformFinder().first)
          .transform
          .getTranslation()
          .y;
      expect(yMid, closeTo(QlypStyle.navHideOffset * kQlypFluid.transform(0.5), 4));

      await tester.pump(const Duration(milliseconds: 260));
      final yEnd = tester
          .widget<Transform>(pillHideTransformFinder().first)
          .transform
          .getTranslation()
          .y;
      expect(yEnd, closeTo(QlypStyle.navHideOffset, 0.5));
    });

    testWidgets('reduce motion uses final hide offset immediately', (tester) async {
      await tester.pumpWidget(
        wrapDesignTest(
          disableAnimations: true,
          child: QlypFloatingNavPill(
            currentIndex: 0,
            onTap: (_) {},
            items: materialNavItems,
            hidden: true,
            bottomInset: 0,
          ),
        ),
      );
      await tester.pump();
      final y = tester
          .widget<Transform>(pillHideTransformFinder().first)
          .transform
          .getTranslation()
          .y;
      expect(y, QlypStyle.navHideOffset);
    });
  });

  group('goldens', () {
    Future<void> pumpGolden(WidgetTester tester, Widget app) async {
      await tester.binding.setSurfaceSize(kPillGoldenSize);
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await tester.pumpWidget(
        RepaintBoundary(key: _goldenRootKey, child: app),
      );
      await tester.pumpAndSettle();
    }

    testWidgets('pill_light_tabs', (tester) async {
      await pumpGolden(
        tester,
        pillTabsPlanche(
          variant: QlypFloatingNavPillVariant.light,
          items: phosphorNavItems,
        ),
      );
      await expectLater(
        _pillRoot(),
        matchesGoldenFile('goldens/pill_light_tabs.png'),
      );
    });

    testWidgets('pill_dark_tabs', (tester) async {
      await pumpGolden(
        tester,
        pillTabsPlanche(
          variant: QlypFloatingNavPillVariant.dark,
          items: materialNavItems,
        ),
      );
      await expectLater(
        _pillRoot(),
        matchesGoldenFile('goldens/pill_dark_tabs.png'),
      );
    });

    testWidgets('pill_hidden', (tester) async {
      await pumpGolden(
        tester,
        pillClientStackHarness(
          currentIndex: 0,
          viewBottom: 34,
          hidden: true,
          phosphor: true,
        ),
      );
      await expectLater(
        _pillRoot(),
        matchesGoldenFile('goldens/pill_hidden.png'),
      );
    });

    testWidgets('placement_client_stack_34', (tester) async {
      await pumpGolden(
        tester,
        pillClientStackHarness(
          currentIndex: 0,
          viewBottom: 34,
          phosphor: true,
        ),
      );
      await expectLater(
        _pillRoot(),
        matchesGoldenFile('goldens/placement_client_stack_34.png'),
      );
    });

    testWidgets('placement_pilote_scaffold_34', (tester) async {
      await pumpGolden(
        tester,
        pillPiloteScaffoldHarness(currentIndex: 0, viewBottom: 34),
      );
      await expectLater(
        _pillRoot(),
        matchesGoldenFile('goldens/placement_pilote_scaffold_34.png'),
      );
    });

    testWidgets('placement_pilote_scaffold_48', (tester) async {
      await pumpGolden(
        tester,
        pillPiloteScaffoldHarness(currentIndex: 0, viewBottom: 48),
      );
      await expectLater(
        _pillRoot(),
        matchesGoldenFile('goldens/placement_pilote_scaffold_48.png'),
      );
    });

    testWidgets('pill tab switch frames', (tester) async {
      await tester.binding.setSurfaceSize(kPillGoldenSize);
      addTearDown(() => tester.binding.setSurfaceSize(null));

      var index = 0;
      Future<void> pumpIndex(int i) async {
        index = i;
        await tester.pumpWidget(
          RepaintBoundary(
            key: _goldenRootKey,
            child: MaterialApp(
              theme: pillGoldenTheme(),
              home: Scaffold(
                body: Center(
                  child: QlypFloatingNavPill(
                    currentIndex: index,
                    onTap: (_) {},
                    items: phosphorNavItems,
                    bottomInset: 0,
                  ),
                ),
              ),
            ),
          ),
        );
      }

      await pumpIndex(0);
      await tester.pumpAndSettle();
      await pumpIndex(2);
      await tester.pump(Duration.zero);
      await expectLater(
        _pillRoot(),
        matchesGoldenFile('goldens/pill_tab_switch_t0.png'),
      );
      await tester.pump(const Duration(milliseconds: 125));
      await expectLater(
        _pillRoot(),
        matchesGoldenFile('goldens/pill_tab_switch_t125.png'),
      );
      await tester.pump(const Duration(milliseconds: 125));
      await expectLater(
        _pillRoot(),
        matchesGoldenFile('goldens/pill_tab_switch_t250.png'),
      );
    });

    testWidgets('pill hide frames', (tester) async {
      await tester.binding.setSurfaceSize(kPillGoldenSize);
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(
        RepaintBoundary(
          key: _goldenRootKey,
          child: MaterialApp(
            theme: pillGoldenTheme(),
            home: Scaffold(
              body: Align(
                alignment: Alignment.bottomCenter,
                child: QlypFloatingNavPill(
                  currentIndex: 0,
                  onTap: (_) {},
                  items: materialNavItems,
                  hidden: false,
                  bottomInset: 0,
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.pumpWidget(
        RepaintBoundary(
          key: _goldenRootKey,
          child: MaterialApp(
            theme: pillGoldenTheme(),
            home: Scaffold(
              body: Align(
                alignment: Alignment.bottomCenter,
                child: QlypFloatingNavPill(
                  currentIndex: 0,
                  onTap: (_) {},
                  items: materialNavItems,
                  hidden: true,
                  bottomInset: 0,
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pump(Duration.zero);
      await expectLater(
        _pillRoot(),
        matchesGoldenFile('goldens/pill_hide_t0.png'),
      );
      await tester.pump(const Duration(milliseconds: 260));
      await expectLater(
        _pillRoot(),
        matchesGoldenFile('goldens/pill_hide_t260.png'),
      );
      await tester.pump(const Duration(milliseconds: 260));
      await expectLater(
        _pillRoot(),
        matchesGoldenFile('goldens/pill_hide_t520.png'),
      );
    });
  });
}
