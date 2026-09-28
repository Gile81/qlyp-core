/// A single server-written display line in the firm-price breakdown.
///
/// The server writes lines in order:
///   ride | redevance ids | gst | qst | additional_tax_{id}
/// Labels come from the server (e.g. 'GST/TPS', 'QST/TVQ', 'CTQ Levy').
class FirmPriceBreakdownLine {
  const FirmPriceBreakdownLine({
    required this.key,
    required this.label,
    required this.amount,
  });

  /// Server key: 'ride', redevance id, 'gst', 'qst', 'additional_tax_{id}'.
  final String key;

  /// Server-provided label (e.g. 'GST/TPS', 'CTQ Levy'). Not translated locally
  /// except for [key] == 'ride', which the UI overrides with a local string.
  final String label;

  final double amount;

  factory FirmPriceBreakdownLine.fromMap(Map<String, dynamic> m) {
    double amtOf(dynamic v) {
      if (v is num) return v.toDouble();
      return double.tryParse('$v') ?? 0.0;
    }
    return FirmPriceBreakdownLine(
      key: (m['key'] as String?) ?? '',
      label: (m['label'] as String?) ?? '',
      amount: amtOf(m['amount']),
    );
  }
}

/// Read-only firm price breakdown from `orders/{id}/server_pricing` doc `firm`.
///
/// No calculations performed — all values come from the server.
/// Tax lines are in [lines] in the order the server wrote them.
/// There are no named tax fields (no tps, tvq, gst, qst): use [lines].
///
/// Server breakdown shape:
/// ```
/// {
///   ride: number, redevances: number, taxes: number, total: number,
///   pricing_mode: 'bidding_firm',
///   lines: [{ key, label, amount }, ...]
/// }
/// ```
class FirmPriceBreakdown {
  const FirmPriceBreakdown({
    required this.amount,
    this.ride,
    this.redevances,
    this.taxes,
    this.total,
    this.lines = const [],
  });

  /// Total TTC at the document level (used for display).
  final double amount;

  /// Pre-tax ride base (breakdown.ride).
  final double? ride;

  /// Redevances total (breakdown.redevances).
  final double? redevances;

  /// Total taxes (breakdown.taxes — server computed, no named taxes).
  final double? taxes;

  /// Server total (breakdown.total — equals [amount]).
  final double? total;

  /// Ordered display lines from the server, in the order the server wrote them.
  final List<FirmPriceBreakdownLine> lines;

  factory FirmPriceBreakdown.fromJson(Map<String, dynamic> json) {
    double? n(dynamic v) {
      if (v == null) return null;
      if (v is num) return v.toDouble();
      return double.tryParse('$v');
    }

    final bd = json['breakdown'] is Map
        ? Map<String, dynamic>.from(json['breakdown'] as Map)
        : <String, dynamic>{};

    final rawLines = bd['lines'];
    final lines = <FirmPriceBreakdownLine>[];
    if (rawLines is List) {
      for (final item in rawLines) {
        if (item is Map) {
          lines.add(FirmPriceBreakdownLine.fromMap(
            Map<String, dynamic>.from(item),
          ));
        }
      }
    }

    return FirmPriceBreakdown(
      amount: n(json['amount']) ?? 0.0,
      ride: n(bd['ride']),
      redevances: n(bd['redevances']),
      taxes: n(bd['taxes']),
      total: n(bd['total']),
      lines: lines,
    );
  }
}