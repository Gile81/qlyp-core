import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qlyp_core/constants/cancellation_contract.dart';

void main() {
  test('CancellationContract matches JSON fixture SHA and callables', () {
    final path = 'test/fixtures/cancellation_contract.json';
    final raw = File(path).readAsStringSync();
    final digest = sha256.convert(utf8.encode(raw)).toString().toUpperCase();
    expect(digest, CancellationContract.contractSha256);

    final json = jsonDecode(raw) as Map<String, dynamic>;
    final callables = (json['callables'] as Map<String, dynamic>).keys.toList()
      ..sort();
    expect(callables, contains(CancellationContract.callablePreviewCancelRide));
    expect(callables, contains(CancellationContract.callableCancelRide));
    expect(callables, contains(CancellationContract.callableMarkPassengerNoShow));

    final errors = (json['error_codes'] as Map<String, dynamic>).keys.toList()
      ..sort();
    expect(errors, CancellationContract.errorCodes.toList()..sort());
  });
}
