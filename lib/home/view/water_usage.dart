import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class WaterUsagePage extends StatefulWidget {
  @override
  _WaterUsagePageState createState() => _WaterUsagePageState();
}

class _WaterUsagePageState extends State<WaterUsagePage> {
  final DatabaseReference _ref = FirebaseDatabase.instance.ref("water_usage");
  Map<String, dynamic> _usageData = {};

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  void _fetchData() async {
    final snapshot = await _ref.get();
    if (snapshot.exists) {
      setState(() {
        _usageData = Map<String, dynamic>.from(snapshot.value as Map);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final sortedDates = _usageData.keys.toList()..sort();

    return Scaffold(
      appBar: AppBar(title: Text("Water Usage")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _usageData.isEmpty
            ? Center(child: CircularProgressIndicator())
            : DataTable(
          columns: const [
            DataColumn(label: Text("Date")),
            DataColumn(label: Text("Usage (Gallons)")),
          ],
          rows: sortedDates.map((date) {
            final usage = _usageData[date]["usage"];
            return DataRow(cells: [
              DataCell(Text(date)),
              DataCell(Text(usage.toString())),
            ]);
          }).toList(),
        ),
      ),
    );
  }
}

