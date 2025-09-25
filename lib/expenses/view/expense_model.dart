

import 'package:firebase_database/firebase_database.dart';
import 'package:milvertonrealty/common/service.dart';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:csv/csv.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:milvertonrealty/common/service.dart';

Future<Map<String, List<Map<String, dynamic>>>> fetchDataByMonthYear() async {
  // Reference to the node that contains your month-wise data.
  DatabaseReference ref = MR_DBService().getDBRef('Expenses');

  // Fetch the snapshot of the data.
  final snapshot = await ref.get();

  // Check if the snapshot contains any data.
  if (snapshot.exists && snapshot.value != null) {
    // Firebase returns data as a dynamic type.
    final rawData = snapshot.value;

    // Ensure that rawData is a Map.
    if (rawData is Map) {
      Map<String, List<Map<String, dynamic>>> monthYearData = {};

      rawData.forEach((monthKey, value) {
        // We'll convert each entry for the month into a List<Map<String,dynamic>>.
        List<Map<String, dynamic>> list = [];

        // Depending on how the data was saved the structure may be a List or a Map.
        if (value is List) {
          // If stored as a list, map each item to a Map.
          list = value
              .where((item) => item != null)
              .map((item) => Map<String, dynamic>.from(item))
              .toList();
        } else if (value is Map) {
          // Sometimes entries are stored as a Map of keys.
          list = (value as Map)
              .values
              .where((item) => item != null)
              .map((item) => Map<String, dynamic>.from(item as Map))
              .toList();
        }

        // Add the processed list into our monthYearData map.
        monthYearData[monthKey.toString()] = list;
      });

      return monthYearData;
    }
  }
  // In case there is no data found, return an empty map.
  return {};
}

Future<void> pickCsvFile() async {
  FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ['csv']);

  if (result != null) {
    File file = File(result.files.single.path!);
    String content = await file.readAsString();
    List<List<dynamic>> rows = const CsvToListConverter().convert(content);

    Map<String,List<Map<String, dynamic>>> parsedExpenses = {};
    for (var row in rows.skip(1)) { // Skip header
      String expenseDate = row[1]; // Ensure this is in 'yyyy-MM-dd' format
      String monthYear = expenseDate.substring(0, 7);

      // Check if key exists, if not initialize the list
      List<Map<String, dynamic>> value = [];
      if (!parsedExpenses.containsKey(monthYear)) {
        parsedExpenses[monthYear] = [];
      }

      // Append to the list


      Map<String, dynamic> data = {
        "date": row[1],
        "description": row[2],
        "amount": row[3],
        "type": row[4],
        "balance": row[5],
        "category": "Uncategorized",
        "subcategory": "Uncategorized"

      };

      parsedExpenses[monthYear]!.add(data);

    }







    await filterAndUploadExpenses(parsedExpenses);
  }
}
final databaseRef = MR_DBService().getDBRef("Expenses/uncategorized");
Future<void> filterAndUploadExpenses(Map<String, List<Map<String, dynamic>>> parsedExpenses) async {
  DataSnapshot snapshot = await databaseRef.get();
  Map<String, dynamic>? existingData = snapshot.value as Map<String, dynamic>?;

  Set existingDescriptions = existingData?.values.map((e) => e["description"]).toSet() ?? {};

  List<Map<String, dynamic>> uniqueExpenses = parsedExpenses["042005"]!.where((expense) {
    return !existingDescriptions.contains(expense["description"]);
  }).toList();

  for (var expense in uniqueExpenses) {
    //databaseRef.child(monthYear).push().set(expense);
  }


}