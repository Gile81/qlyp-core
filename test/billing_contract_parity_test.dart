import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qlyp_core/constants/billing_contract.dart';

void main() {
  late Map<String, dynamic> contract;

  setUpAll(() {
    final path = '${Directory.current.path}/test/fixtures/billing_contract.json';
    contract = jsonDecode(File(path).readAsStringSync()) as Map<String, dynamic>;
  });

  List<String> keysOf(Map<String, dynamic> section) =>
      section.keys.toList()..sort();

  test('billing_contract.json SHA-256 matches BillingContract', () {
    final path = 'test/fixtures/billing_contract.json';
    final raw = File(path).readAsStringSync();
    final digest = sha256.convert(utf8.encode(raw)).toString().toUpperCase();
    expect(digest, BillingContract.contractSha256);
  });

  test('getBillingDocumentUrl callable wire names', () {
    final callables = contract['callables'] as Map<String, dynamic>;
    expect(callables.keys, contains(BillingContract.callableGetBillingDocumentUrl));
    final urlCallable =
        callables[BillingContract.callableGetBillingDocumentUrl] as Map;
    final input = urlCallable['input'] as Map<String, dynamic>;
    expect(keysOf(input), [
      BillingContract.inputDocumentId,
      BillingContract.inputDocumentType,
    ]);
    final output = urlCallable['output'] as Map<String, dynamic>;
    expect(keysOf(output), [
      BillingContract.outputExpiresAt,
      BillingContract.outputUrl,
    ]);
    final errors = (urlCallable['error_codes'] as List).cast<String>()..sort();
    expect(errors, BillingContract.getBillingDocumentUrlErrorCodes.toList()..sort());
  });

  test('order_fields keys match BillingContract.orderFieldKeys', () {
    final orderFields = contract['order_fields'] as Map<String, dynamic>;
    expect(keysOf(orderFields), BillingContract.orderFieldKeys.toList()..sort());
  });

  test('ride_financials keys match BillingContract.rideFinancialsKeys', () {
    final ride = contract['ride_financials'] as Map<String, dynamic>;
    expect(keysOf(ride), BillingContract.rideFinancialsKeys.toList()..sort());
  });

  test('invoice document keys match constants', () {
    final invoices = contract['invoices'] as Map<String, dynamic>;
    final doc = invoices['document'] as Map<String, dynamic>;
    expect(keysOf(doc), BillingContract.invoiceDocumentKeys.toList()..sort());
    expect(invoices['collection'], BillingContract.collectionInvoices);
  });

  test('driver statement document keys match constants', () {
    final statements = contract['driver_statements'] as Map<String, dynamic>;
    final doc = statements['document'] as Map<String, dynamic>;
    expect(
      keysOf(doc),
      BillingContract.driverStatementDocumentKeys.toList()..sort(),
    );
    expect(statements['collection'], BillingContract.collectionDriverStatements);
  });

  test('marketplace_bid_fields match payout field keys', () {
    final bids = contract['marketplace_bid_fields'] as Map<String, dynamic>;
    expect(
      keysOf(bids),
      BillingContract.marketplaceBidPayoutFieldKeys.toList()..sort(),
    );
  });

  test('internalAdminBilling actions match constants', () {
    final callables = contract['callables'] as Map<String, dynamic>;
    final admin = callables['internalAdminBilling'] as Map<String, dynamic>;
    final actions = (admin['actions'] as List).cast<String>()..sort();
    expect(actions, BillingContract.internalAdminBillingActions.toList()..sort());
  });

  test('error_codes keys match billingErrorCodes', () {
    final errors = contract['error_codes'] as Map<String, dynamic>;
    expect(keysOf(errors), BillingContract.billingErrorCodes.toList()..sort());
  });
}
