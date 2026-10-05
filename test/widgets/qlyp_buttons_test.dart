import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qlyp_core/config/qlyp_theme.dart';
import 'package:qlyp_core/widgets/qlyp_buttons.dart';
import 'package:qlyp_core/widgets/qlyp_loading.dart';

void main() {
  testWidgets('QlypPrimaryButton shows label and scales on press', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: qlypLightTheme(),
        home: Scaffold(
          body: QlypPrimaryButton(
            label: 'Continuer',
            onPressed: () {},
          ),
        ),
      ),
    );

    expect(find.text('Continuer'), findsOneWidget);

    final scaleFinder = find.byType(AnimatedScale);
    expect(scaleFinder, findsWidgets);

    await tester.startGesture(tester.getCenter(find.text('Continuer')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 10));
  });

  testWidgets('QlypPrimaryButton loading shows QlypLoading', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: qlypLightTheme(),
        home: const Scaffold(
          body: QlypPrimaryButton(
            label: 'OK',
            onPressed: null,
            isLoading: true,
          ),
        ),
      ),
    );

    expect(find.byType(QlypLoading), findsOneWidget);
  });
}
