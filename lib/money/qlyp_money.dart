import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';

/// Server-side amounts only — display formatting for CAD (no client-side math).
class QlypMoney {
  QlypMoney._();

  static const String defaultCurrency = 'CAD';

  /// When [format] is called without [languageCode], this resolver supplies
  /// the active app language (e.g. Get.locale?.languageCode from the host app).
  static String Function()? resolveLanguageCode;

  static String format(
    Object? amount, {
    String? languageCode,
    String currency = defaultCurrency,
  }) {
    if (currency != defaultCurrency) {
      debugPrint('QlypMoney: unsupported currency $currency, using CAD display');
    }
    final parsed = _parseAmount(amount);
    if (parsed == null) {
      debugPrint('QlypMoney: unparseable amount: $amount');
      return '\u2014';
    }
    final lang =
        (languageCode ?? resolveLanguageCode?.call() ?? 'fr').toLowerCase();
    final locale = lang.startsWith('fr') ? 'fr_CA' : 'en_CA';
    final formatter = NumberFormat.currency(
      locale: locale,
      symbol: r'$',
      decimalDigits: 2,
    );
    return formatter.format(parsed);
  }

  static double? _parseAmount(Object? amount) {
    if (amount == null) return null;
    if (amount is num) return amount.toDouble();
    final raw = amount.toString().trim();
    if (raw.isEmpty || raw.toLowerCase() == 'null') return null;
    return double.tryParse(raw.replaceAll(',', '.'));
  }
}