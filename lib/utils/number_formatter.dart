


import 'package:intl/intl.dart';

String formatAmount(double amount) {
  return NumberFormat("#,##0.00", "en_US").format(amount);
}