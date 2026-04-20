import 'package:intl/intl.dart';

class PriceFormatter {
  static String format(double price, {String currency = 'DZD'}) {
    final formatter = NumberFormat.currency(
      symbol: currency == 'DZD' ? 'DA' : currency,
      decimalDigits: currency == 'DZD' ? 0 : 2,
    );
    return formatter.format(price);
  }
  
  static String formatSavings(double original, double current) {
    final savings = original - current;
    final percent = (savings / original * 100).round();
    return 'Save $percent%';
  }
  
  static String formatWithoutSymbol(double price) {
    final formatter = NumberFormat('#,##0.00');
    return formatter.format(price);
  }
}