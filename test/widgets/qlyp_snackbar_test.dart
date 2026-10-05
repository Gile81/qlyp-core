import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:qlyp_core/constants/qlyp_motion.dart';
import 'package:qlyp_core/widgets/qlyp_snackbar.dart';

class _SnackHarness extends StatefulWidget {
  const _SnackHarness({required this.message});

  final String message;

  @override
  State<_SnackHarness> createState() => _SnackHarnessState();
}

class _SnackHarnessState extends State<_SnackHarness> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      QlypSnackbar.show(
        widget.message,
        context: context,
        duration: const Duration(hours: 1),
      );
    });
  }

  @override
  Widget build(BuildContext context) => const Scaffold(body: SizedBox());
}

void main() {
  setUp(() => Get.testMode = true);
  tearDown(() async {
    QlypSnackbar.dismissImmediate();
    Get.reset();
  });

  Future<void> pumpHarness(
    WidgetTester tester, {
    required String message,
    Locale? locale,
    bool disableAnimations = false,
  }) async {
    await tester.pumpWidget(
      GetMaterialApp(
        locale: locale,
        home: disableAnimations
            ? MediaQuery(
                data: const MediaQueryData(disableAnimations: true),
                child: _SnackHarness(message: message),
              )
            : _SnackHarness(message: message),
      ),
    );
    await tester.pump();
    await tester.pump();
    await tester.pump();
  }

  Future<void> closeSnackbar(WidgetTester tester) async {
    QlypSnackbar.dismissImmediate();
    await tester.pump();
    await tester.pump(kDurSheet);
  }

  testWidgets('QlypSnackbar shows FR message', (tester) async {
    await pumpHarness(tester, message: 'Enregistre');
    expect(find.text('Enregistre'), findsOneWidget);
    await closeSnackbar(tester);
  });

  testWidgets('QlypSnackbar shows EN message', (tester) async {
    await pumpHarness(
      tester,
      message: 'Saved',
      locale: const Locale('en', 'CA'),
    );
    expect(find.text('Saved'), findsOneWidget);
    await closeSnackbar(tester);
  });

  testWidgets('QlypSnackbar reduce motion still shows content', (tester) async {
    await pumpHarness(tester, message: 'Fixe', disableAnimations: true);
    expect(find.text('Fixe'), findsOneWidget);
    await closeSnackbar(tester);
  });
}