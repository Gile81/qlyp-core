import 'package:flutter_test/flutter_test.dart';
import 'package:qlyp_core/billing/ride_tip_errors.dart';
import 'package:qlyp_core/constants/billing_contract.dart';
import 'package:qlyp_core/services/ride_tip_service.dart';

void main() {
  final setRideTipCodes = BillingContract.setRideTipErrorCodes;
  final setPromptCodes = BillingContract.setTipPromptStateErrorCodes;
  final allCodes = {...setRideTipCodes, ...setPromptCodes}.toList()..sort();

  for (final code in allCodes) {
    test('rideTipErrorFallback fr for $code', () {
      final msg = rideTipErrorFallback(code, 'fr');
      expect(msg, isNotEmpty);
      expect(msg, isNot(code));
    });

    test('rideTipErrorFallback en for $code', () {
      final msg = rideTipErrorFallback(code, 'en');
      expect(msg, isNotEmpty);
      expect(msg, isNot(code));
    });

    test('RideTipService.localizedErrorMessage fr for $code', () {
      final msg = RideTipService.localizedErrorMessage(
        error: RideTipException(code: code, messageFr: '', messageEn: ''),
        languageCode: 'fr',
      );
      expect(msg, isNotEmpty);
      expect(msg, isNot(code));
    });

    test('RideTipService.localizedErrorMessage en for $code', () {
      final msg = RideTipService.localizedErrorMessage(
        error: RideTipException(code: code, messageFr: '', messageEn: ''),
        languageCode: 'en',
      );
      expect(msg, isNotEmpty);
      expect(msg, isNot(code));
    });
  }
}
