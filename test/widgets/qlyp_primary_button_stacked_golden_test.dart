import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qlyp_core/config/qlyp_theme.dart';
import 'package:qlyp_core/widgets/qlyp_buttons.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('QlypPrimaryButton stacked offer CTA golden', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: QlypTheme.light(),
        home: Scaffold(
          body: Center(
            child: SizedBox(
              width: 320,
              child: QlypPrimaryButton(
                label: 'Faire une offre',
                stackedCaption: 'Prix indicatif',
                stackedDetail: '24,50 \$',
                onPressed: () {},
                expanded: true,
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pump();
    await expectLater(
      find.byType(QlypPrimaryButton),
      matchesGoldenFile('goldens/qlyp_primary_button_stacked.png'),
    );
  });
}
