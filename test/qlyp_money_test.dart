import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';
import 'package:qlyp_core/money/qlyp_money.dart';

void main() {
  test('fr formats with intl fr_CA spacing and comma decimals', () {
    final expected = NumberFormat.currency(
      locale: 'fr_CA',
      symbol: r'$',
      decimalDigits: 2,
    ).format(12.5);
    expect(QlypMoney.format(12.5, languageCode: 'fr'), expected);
    expect(expected, contains('12,50'));
    expect(expected, contains(r'$'));
  });

  test('en formats as dollar prefix', () {
    expect(QlypMoney.format(12.5, languageCode: 'en'), r'$12.50');
  });

  test('string amounts parse', () {
    final nbsp = String.fromCharCode(0xA0);
    expect(
      QlypMoney.format('7', languageCode: 'fr'),
      '7,00${nbsp}\$',
    );
    expect(QlypMoney.format('7', languageCode: 'en'), r'$7.00');
  });

  test('null and invalid return em dash', () {
    expect(QlypMoney.format(null), '\u2014');
    expect(QlypMoney.format('abc'), '\u2014');
  });

  test('zero formats in both locales', () {
    final nbsp = String.fromCharCode(0xA0);
    expect(
      QlypMoney.format(0, languageCode: 'fr'),
      '0,00${nbsp}\$',
    );
    expect(QlypMoney.format(0, languageCode: 'en'), r'$0.00');
  });

  test('resolveLanguageCode fallback', () {
    QlypMoney.resolveLanguageCode = () => 'en';
    addTearDown(() => QlypMoney.resolveLanguageCode = null);
    expect(QlypMoney.format(1), r'$1.00');
  });
}
