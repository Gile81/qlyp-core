import 'package:qlyp_core/constants/qlyp_service_key_assets.dart';

import 'official_service_order.dart';

/// Shared display sort: Firestore [sequence] ascending, then label; missing sequence last.
int readDisplayOrder(Map<String, dynamic>? doc) {
  if (doc == null) return 1 << 30;
  final raw = doc['sequence'] ?? doc['order'];
  if (raw is int) return raw;
  final parsed = int.tryParse(raw?.toString() ?? '');
  return parsed ?? (1 << 30);
}

int compareByDisplayOrder({
  required int orderA,
  required int orderB,
  required String labelA,
  required String labelB,
}) {
  if (orderA != orderB) return orderA.compareTo(orderB);
  return labelA.toLowerCase().compareTo(labelB.toLowerCase());
}

int compareServiceMaps(
  Map<String, dynamic> a,
  Map<String, dynamic> b, {
  required String Function(Map<String, dynamic>) labelOf,
}) {
  return compareByDisplayOrder(
    orderA: readDisplayOrder(a),
    orderB: readDisplayOrder(b),
    labelA: labelOf(a),
    labelB: labelOf(b),
  );
}

String normalizeServiceKey(String? raw) =>
    QlypServiceKeyAssets.normalizeServiceKey(raw) ?? '';

int readDisplayOrderFromServiceKey(String? serviceKey) {
  final key = normalizeServiceKey(serviceKey);
  if (key.isEmpty) return 1 << 30;
  return OfficialServiceOrder.sequenceForTierKey(key) ?? (1 << 30);
}

int compareServiceModels<T>({
  required T a,
  required T b,
  required int Function(T) readOrder,
  required String Function(T) readLabel,
}) {
  return compareByDisplayOrder(
    orderA: readOrder(a),
    orderB: readOrder(b),
    labelA: readLabel(a),
    labelB: readLabel(b),
  );
}
