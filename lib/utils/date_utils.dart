

import 'package:intl/intl.dart';

class Utils {
  static DateFormat dateFormat = DateFormat("MM/dd/yyyy");
  static String getDayWithSuffix(String dateStr) {
    if (dateStr == null || dateStr.isEmpty) return "0";
    try {
      final date = dateFormat.parse(dateStr);
      int day = date.day;
      String suffix;
      //print ('got **** ${date}');
      if (day % 10 == 1 && day != 11) {
        suffix = 'st';
      } else if (day % 10 == 2 && day != 12) {
        suffix = 'nd';
      } else if (day % 10 == 3 && day != 13) {
        suffix = 'rd';
      } else {
        suffix = 'th';
      }

      return '$day$suffix';
    }
    catch (e) {
      print(e);
      return "0";
    }

  }
}
