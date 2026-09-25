import 'package:qlyp_core/pricing/zone_service_activation.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('v2 logistique only does not expand to express or moving', () {
    const zone = {
      'services_activation_version': 2,
      'services_enabled': ['logistique'],
    };
    final logistique = evaluateTierOfferedInZone(
      zoneDoc: zone,
      serviceDoc: {
        'id': 'byte-log-id',
        'service_key': 'byte',
        'mainServiceIDs': ['c36QVpfmfiwPrbh3R0Oz'],
      },
    );
    final express = evaluateTierOfferedInZone(
      zoneDoc: zone,
      serviceDoc: {
        'id': 'bite-id',
        'service_key': 'bite',
        'mainServiceIDs': ['iPWQ4zlCxVpE3Ud8SnJP'],
      },
    );
    expect(logistique.offered, isTrue);
    expect(express.offered, isFalse);
  });

  test('legacy list without version still offers express tier', () {
    const zone = {
      'services_enabled': ['courses', 'logistique', 'rideshare'],
    };
    final express = evaluateTierOfferedInZone(
      zoneDoc: zone,
      serviceDoc: {
        'id': 'byte-id',
        'service_key': 'byte',
        'mainServiceIDs': ['iPWQ4zlCxVpE3Ud8SnJP'],
      },
    );
    expect(express.offered, isTrue);
  });
}