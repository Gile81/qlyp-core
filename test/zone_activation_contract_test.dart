import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:qlyp_core/pricing/zone_service_activation.dart';

void main() {
  test('shared zone activation contract', () {
    final fixturePath =
        '${Directory.current.path}/../qlyp-admin/tests/fixtures/zone_activation_contract/cases.json';
    final raw = File(fixturePath).readAsStringSync();
    final cases = (jsonDecode(raw) as Map<String, dynamic>)['cases'] as List;
    for (final c in cases) {
      final caseMap = c as Map<String, dynamic>;
      final result = evaluateTierOfferedInZone(
        zoneDoc: Map<String, dynamic>.from(caseMap['zone'] as Map),
        serviceDoc: Map<String, dynamic>.from(caseMap['service'] as Map),
      );
      expect(result.offered, caseMap['offered'], reason: '${caseMap['id']}');
      if (caseMap['missing_key'] != null) {
        expect(result.missingKey, caseMap['missing_key']);
      }
      if (caseMap['reason'] != null) {
        expect(result.reason, caseMap['reason']);
      }
    }
  });
}