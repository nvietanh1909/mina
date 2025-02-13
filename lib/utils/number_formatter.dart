import 'package:intl/intl.dart';

class NumberFormatter {
  static String formatCurrency(double amount) {
    final formatCurrency =
        NumberFormat.currency(locale: 'vi_VN', symbol: 'VND');
    return formatCurrency.format(amount);
  }

  static String formatNumber(double number) {
    final formatter = NumberFormat("#,###", "vi_VN");
    return formatter.format(number);
  }
}
