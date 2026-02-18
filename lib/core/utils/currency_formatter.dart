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

  static String formatWithThousands(double amount) {
    return _formatWithThousands(amount, 2);
  }

  static String formatCompact(double amount) {
    if (amount >= 1000000) {
      return '\$${(amount / 1000000).toStringAsFixed(1)}M';
    } else if (amount >= 1000) {
      return '\$${(amount / 1000).toStringAsFixed(1)}K';
    }
    return format(amount);
  }

  static String _formatWithThousands(double value, int decimals) {
    final parts = value.toStringAsFixed(decimals).split('.');
    final intPart = int.parse(parts[0]);
    final decPart = decimals > 0 ? parts[1] : '';
    
    final intStr = intPart.abs().toString();
    final buffer = StringBuffer();
    
    for (int i = 0; i < intStr.length; i++) {
      if (i > 0 && (intStr.length - i) % 3 == 0) {
        buffer.write('.');
      }
      buffer.write(intStr[i]);
    }
    
    var result = intPart < 0 ? '-${buffer.toString()}' : buffer.toString();
    
    if (decimals > 0 && decPart.isNotEmpty) {
      result = '$result,$decPart';
    }
    
    return '\$$result';
  }
}
