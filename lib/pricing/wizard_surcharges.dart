import 'dart:math';

/// Port of `functions/src/pricing/steps/step3b_wizard_surcharges.ts`.
/// Used for client/server parity tests (display price comes from the server).

class WizardSurchargeLine {
  const WizardSurchargeLine({
    required this.key,
    required this.label,
    required this.amount,
  });

  final String key;
  final String label;
  final double amount;
}

class WizardSurchargesResult {
  const WizardSurchargesResult({
    required this.delta,
    required this.lines,
  });

  final double delta;
  final List<WizardSurchargeLine> lines;
}

typedef ZoneNumReader = double Function(String key, double fallback);

bool isDemenagementWizardKind(String wizardKind) {
  return wizardKind.trim().toLowerCase() == 'demenagement';
}

bool isLogisticsGroupWizardKind(String wizardKind) {
  final w = wizardKind.trim().toLowerCase();
  return w == 'logistique_group' || w == 'logistiquegroup';
}

double roundWizardMoney(double value, {int digits = 2}) {
  final factor = pow(10, digits).toDouble();
  return (value * factor).roundToDouble() / factor;
}

double floorSurchargeAmount(ZoneNumReader zoneNum, String floor) {
  switch (floor.trim().toLowerCase()) {
    case 'ground':
      return 0;
    case '1':
      return zoneNum('moving_floor_1_surcharge', 10);
    case '2':
      return zoneNum('moving_floor_2_surcharge', 20);
    case '3':
      return zoneNum('moving_floor_3_surcharge', 30);
    case '4plus':
      return zoneNum('moving_floor_3plus_surcharge', 45);
    default:
      return 0;
  }
}

WizardSurchargesResult computeWizardSurcharges({
  required String wizardKind,
  required ZoneNumReader zoneNum,
  int crewCount = 1,
  String? floorDeparture,
  String? floorArrival,
  bool elevatorDeparture = false,
  bool elevatorArrival = false,
  bool heavyItems = false,
  double logisticsWeightKg = 0,
  int currencyDigits = 2,
}) {
  final wk = wizardKind.trim().toLowerCase();
  var delta = 0.0;
  final lines = <WizardSurchargeLine>[];

  if (isDemenagementWizardKind(wk)) {
    final extraMovers = max(0, crewCount - 1);
    if (extraMovers > 0) {
      final rate = zoneNum('moving_extra_mover_rate', 35);
      final amount =
          roundWizardMoney(extraMovers * rate, digits: currencyDigits);
      delta += amount;
      lines.add(WizardSurchargeLine(
        key: 'moving_extra_movers',
        label: 'Extra movers',
        amount: amount,
      ));
    }

    final dep = floorDeparture?.trim() ?? '';
    if (dep.isNotEmpty && !elevatorDeparture) {
      final amount = roundWizardMoney(
        floorSurchargeAmount(zoneNum, dep),
        digits: currencyDigits,
      );
      if (amount > 0) {
        delta += amount;
        lines.add(WizardSurchargeLine(
          key: 'moving_floor_departure',
          label: 'Departure floor surcharge',
          amount: amount,
        ));
      }
    }

    final arr = floorArrival?.trim() ?? '';
    if (arr.isNotEmpty && !elevatorArrival) {
      final amount = roundWizardMoney(
        floorSurchargeAmount(zoneNum, arr),
        digits: currencyDigits,
      );
      if (amount > 0) {
        delta += amount;
        lines.add(WizardSurchargeLine(
          key: 'moving_floor_arrival',
          label: 'Arrival floor surcharge',
          amount: amount,
        ));
      }
    }

    if (heavyItems) {
      final amount = roundWizardMoney(
        zoneNum('moving_heavy_item_surcharge', 45),
        digits: currencyDigits,
      );
      delta += amount;
      lines.add(WizardSurchargeLine(
        key: 'moving_heavy_items',
        label: 'Heavy items surcharge',
        amount: amount,
      ));
    }
  }

  if (isLogisticsGroupWizardKind(wk) && logisticsWeightKg > 0) {
    final tiers = (logisticsWeightKg / 50).ceil();
    final rate = zoneNum('logistics_weight_per_50kg', 5);
    final amount =
        roundWizardMoney(tiers * rate, digits: currencyDigits);
    delta += amount;
    lines.add(WizardSurchargeLine(
      key: 'logistics_weight',
      label: 'Weight surcharge',
      amount: amount,
    ));
  }

  return WizardSurchargesResult(delta: delta, lines: lines);
}
