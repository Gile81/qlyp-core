import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qlyp_core/models/ride_tip_option_view.dart';
import 'package:qlyp_core/widgets/qlyp_tip_selector.dart';

import '../design_test_helpers.dart';
import '../pill_golden_fonts.dart';
import 'billing_golden_harness.dart';

Future<List<RideTipOptionView>> loadMaquetteETipOptions() async {
  final raw =
      await rootBundle.loadString('test/fixtures/tip_options_maquette_e.json');
  final list = jsonDecode(raw) as List<dynamic>;
  return RideTipOptionView.listFromOrderField(list);
}

void main() {
  setUpAll(() async {
    await loadPillGoldenFonts();
  });

  testWidgets('golden', (tester) async {
    configureBillingGoldenSurface(tester);
    final options = await loadMaquetteETipOptions();
    await tester.pumpWidget(
      wrapDesignTest(
        child: billingGoldenScroll(
          Padding(
            padding: const EdgeInsets.all(16),
            child: QlypTipSelector(
              options: options,
              languageCode: 'fr',
              onGive: (_) {},
              onLater: () {},
              onDecline: () {},
            ),
          ),
        ),
      ),
    );
    await expectLater(
      find.byKey(billingGoldenKey),
      matchesGoldenFile('../goldens/qlyp_tip_selector_e_fr.png'),
    );
  });
}
