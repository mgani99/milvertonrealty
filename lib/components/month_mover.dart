import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class MonthYearNavigator extends StatefulWidget {
  final Function(DateTime) onDateChanged; // Callback function

  DateTime currentDate;
  MonthYearNavigator({Key? key, required this.onDateChanged, required this.currentDate}) : super(key: key);

  @override
  _MonthYearNavigatorState createState() => _MonthYearNavigatorState();
}

class _MonthYearNavigatorState extends State<MonthYearNavigator> {
  late DateTime currentDate;
  DateTime today = DateTime.now();

  void changeMonth(int delta) {
    setState(() {
      currentDate = DateTime(currentDate.year, currentDate.month + delta, 1);
      widget.onDateChanged(currentDate); // Call the callback function
    });
  }

  @override
  void initState() {
    currentDate = widget.currentDate;
    super.initState();
  }
  bool isCurrentMonthAndYear() {
    return currentDate.year == today.year && currentDate.month == today.month;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min, // Minimize horizontal space
      children: [
        IconButton(
          iconSize: 16, // Make the icon smaller
          padding: EdgeInsets.zero, // Remove extra padding
          constraints: BoxConstraints(), // Remove default constraints
          icon: Icon(Icons.arrow_back),
          onPressed: () => changeMonth(-1), // Move one month back
        ),
        Text(
          DateFormat('MMM yyyy').format(currentDate), // Format: "Apr 2025"
          style: TextStyle(fontSize: 14, color: Colors.black), // Smaller font size
        ),
        if (!isCurrentMonthAndYear())
          IconButton(
            iconSize: 14, // Make the icon smaller
            padding: EdgeInsets.zero, // Remove extra padding
            constraints: BoxConstraints(), // Remove default constraints
            icon: Icon(Icons.arrow_forward),
            onPressed: () => changeMonth(1), // Move one month forward
          ),
      ],
    );
  }
}


