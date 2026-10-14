double? billingAsDouble(dynamic value) {
  if (value == null) return null;
  if (value is num) return value.toDouble();
  final raw = value.toString().trim();
  if (raw.isEmpty || raw.toLowerCase() == 'null') return null;
  return double.tryParse(raw.replaceAll(',', '.'));
}

bool? billingAsBool(dynamic value) {
  if (value == null) return null;
  if (value is bool) return value;
  final raw = value.toString().trim().toLowerCase();
  if (raw == 'true') return true;
  if (raw == 'false') return false;
  return null;
}

String? billingOptionalString(dynamic value) {
  if (value == null) return null;
  final s = value.toString().trim();
  return s.isEmpty ? null : s;
}

String billingLabelForLanguage({
  required String languageCode,
  required String labelFr,
  required String labelEn,
}) {
  final lang = languageCode.toLowerCase();
  if (lang.startsWith('fr')) {
    return labelFr.isNotEmpty ? labelFr : labelEn;
  }
  return labelEn.isNotEmpty ? labelEn : labelFr;
}
