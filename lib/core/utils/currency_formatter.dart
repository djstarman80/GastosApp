import 'package:intl/intl.dart';

class CurrencyFormatter {
  static final NumberFormat _formatter = NumberFormat.currency(
    locale: 'es_UY',
    symbol: '\$',
    decimalDigits: 2,
  );

  static String format(double amount) {
    return _formatter.format(amount);
  }

  static String formatSimple(double amount) {
    final formatted = _formatter.format(amount);
    return formatted.replaceAll('\$', '').trim();
  }
}
