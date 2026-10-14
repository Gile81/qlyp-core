import '../constants/billing_contract.dart';

class RideTipOptionView {
  const RideTipOptionView({required this.pct, required this.amount});

  final int pct;
  final double amount;

  static RideTipOptionView? tryFromMap(Map<String, dynamic>? map) {
    if (map == null) return null;
    final pctRaw = map[BillingContract.tipOptionPct];
    final amountRaw = map[BillingContract.tipOptionAmount];
    if (pctRaw is! num || amountRaw is! num) return null;
    if (pctRaw <= 0 || amountRaw <= 0) return null;
    return RideTipOptionView(pct: pctRaw.round(), amount: amountRaw.toDouble());
  }

  static List<RideTipOptionView> listFromOrderField(Object? raw) {
    if (raw is! List) return const [];
    final out = <RideTipOptionView>[];
    for (final item in raw) {
      if (item is! Map) continue;
      final view = tryFromMap(Map<String, dynamic>.from(item));
      if (view != null) out.add(view);
    }
    return out;
  }
}
