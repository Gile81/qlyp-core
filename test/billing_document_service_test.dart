import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qlyp_core/constants/billing_contract.dart';
import 'package:qlyp_core/services/billing_document_service.dart';

void main() {
  test('parseBillingFunctionsException maps pdf_not_ready', () {
    final ex = BillingDocumentService.parseBillingFunctionsException(
      FirebaseFunctionsException(
        code: 'failed-precondition',
        message: 'PDF not ready.',
      ),
    );
    expect(ex.code, BillingContract.errorPdfNotReady);
    expect(ex.messageFr, contains('préparation'));
  });

  test('parseBillingFunctionsException maps permission_denied', () {
    final ex = BillingDocumentService.parseBillingFunctionsException(
      FirebaseFunctionsException(
        code: 'permission-denied',
        message: 'Not allowed.',
      ),
    );
    expect(ex.code, BillingContract.errorPermissionDenied);
  });
}
