import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qlyp_core/config/qlyp_theme.dart';
import 'package:qlyp_core/widgets/qlyp_otp_field.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Widget harness({
    required TextEditingController controller,
    bool hasError = false,
  }) {
    return MaterialApp(
      theme: QlypTheme.light(),
      home: Scaffold(
        body: Center(
          child: SizedBox(
            width: 320,
            child: QlypOtpField(
              length: 6,
              controller: controller,
              hasError: hasError,
            ),
          ),
        ),
      ),
    );
  }

  testWidgets('QlypOtpField empty with client input theme', (tester) async {
    final controller = TextEditingController();
    addTearDown(controller.dispose);
    await tester.pumpWidget(harness(controller: controller));
    await expectLater(
      find.byType(QlypOtpField),
      matchesGoldenFile('goldens/qlyp_otp_field_empty.png'),
    );
  });

  testWidgets('QlypOtpField wraps AutofillGroup for SMS autofill', (tester) async {
    final controller = TextEditingController();
    addTearDown(controller.dispose);
    await tester.pumpWidget(harness(controller: controller));
    expect(find.byType(AutofillGroup), findsWidgets);
  });

  testWidgets('QlypOtpField filled', (tester) async {
    final controller = TextEditingController(text: '123456');
    addTearDown(controller.dispose);
    await tester.pumpWidget(harness(controller: controller));
    await tester.pump();
    await expectLater(
      find.byType(QlypOtpField),
      matchesGoldenFile('goldens/qlyp_otp_field_filled.png'),
    );
  });

  testWidgets('QlypOtpField error', (tester) async {
    final controller = TextEditingController(text: '12');
    addTearDown(controller.dispose);
    await tester.pumpWidget(
      harness(controller: controller, hasError: true),
    );
    await tester.pump();
    await expectLater(
      find.byType(QlypOtpField),
      matchesGoldenFile('goldens/qlyp_otp_field_error.png'),
    );
  });
}
