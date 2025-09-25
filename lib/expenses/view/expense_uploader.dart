import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:csv/csv.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:intl/intl.dart';
import 'package:milvertonrealty/common/service.dart';

import '../../utils/number_formatter.dart';
import 'package:flutter/foundation.dart' show kIsWeb;


class ExpensePage extends StatefulWidget {

  ExpensePage({super.key});

  @override
  _ExpensePageState createState() => _ExpensePageState();

}

class _ExpensePageState extends State<ExpensePage> {
  final databaseRef = MR_DBService().getDBRef("Expenses");
  List<Map<String, dynamic>> filteredExpenses = [];
  TextEditingController searchController = TextEditingController();

  double totalAmount = 0.0;
  Set<String> existingKeys = {};
  List<Map<String, dynamic>> expenses = [];
  int duplicateExpense = 0;

  Future<void> getExistingExpenseKeys() async {
    DataSnapshot snapshot = await databaseRef.get();
    Map<dynamic, dynamic>? data = snapshot.value as Map<dynamic, dynamic>?;

    if (data != null) {
      data.forEach((monthYear, expenseData) {
        expenseData.forEach((key, expense) {
          existingKeys.add("${expense["date"]}_${expense["description"]}");
        });
      });
    }
  }

  Future<void> uploadCsvFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['csv'],
    );

    if (result != null) {
      String content = "";

      if (kIsWeb) {
        // Handle Web: Read file as bytes and convert to string
        content = String.fromCharCodes(result.files.single.bytes!);
      } else {
        // Handle Android/iOS: Read file using dart:io.File
        File file = File(result.files.single.path!);
        content = await file.readAsString();
      }

      List<List<dynamic>> rows = const CsvToListConverter().convert(content);

      await getExistingExpenseKeys(); // Load existing expenses first

      expenses.clear();
      totalAmount = 0.0;
      duplicateExpense = 0;

      for (var row in rows.skip(1)) { // Skip header
        String expenseDate = row[1]; // Expected format: MM/dd/yyyy
        DateTime parsedDate = DateFormat('MM/dd/yyyy').parse(expenseDate);
        // String monthYear = DateFormat('MMyyyy').format(parsedDate);
        String expenseKey = "${DateFormat('MM-dd-yyyy').format(
            parsedDate)}_${row[2]}";
         existingKeys.contains(expenseKey) ? ++duplicateExpense: duplicateExpense;

        double amount = double.parse(row[3].toString());
        if (amount < 0) { //only upload the credit
          totalAmount = totalAmount + amount;
          expenses.add({
            "date": DateFormat('MM-dd-yyyy').format(parsedDate),
            "description": row[2],
            "amount": amount,
            "type": row[4],
            "balance": row[5],
            "category": existingKeys.contains(expenseKey)
                ? "Duplicate"
                : "Uncategorized",
            "subcategory": existingKeys.contains(expenseKey)
                ? "Duplicate"
                : "Uncategorized",
          });
        }
      }

      // Sort expenses by date
      expenses.sort((a, b) {
        DateTime dateA = DateFormat('MM-dd-yyyy').parse(a["date"]);
        DateTime dateB = DateFormat('MM-dd-yyyy').parse(b["date"]);
        return dateA.compareTo(dateB);
      });

      setState(() { expenses; });
    }
  }



  @override
  void initState() {
    super.initState();

  }

  @override
  void didChangeDependencies() {
    if (expenses.isEmpty || expenses.length == 0) {
      uploadCsvFile();
    }
  }
  void saveExpensesToFirebase() {
    for (var expense in expenses) {
      if (expense['category']!= "Duplicate") {
        String monthYear = DateFormat('MMyyyy').format(
            DateFormat('MM-dd-yyyy').parse(expense["date"]));
        //double check on duplicate
        var expenseKey = "${expense["date"]}_${expense['description']}";
        DatabaseReference dbRef = databaseRef.child(monthYear).push();
        expense['key'] = dbRef.key;
        dbRef.set(expense);

      }
    }
  }

  void fetchUncategorizedExpenses() async {
    DataSnapshot snapshot = await databaseRef.get();
    Map<dynamic, dynamic>? data = snapshot.value as Map<dynamic, dynamic>?;

    expenses.clear();
    if (data != null) {
      data.forEach((monthYear, expenseData) {
        expenseData.forEach((key, expense) {
          if (expense["category"] == "Uncategorized") {
            expenses.add(Map<String, dynamic>.from(expense));
          }
        });
      });
    }


    setState(() {});
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:  Text("Expense Uploader")),


      body: Column(
        children: [
        Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Expense Summary",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Total Count:",
                    style: TextStyle(fontSize: 16),
                  ),
                  Text(
                    "${expenses.length}",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              SizedBox(height: 6),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Total Amount:",
                    style: TextStyle(fontSize: 16),
                  ),
                  Text(
                    "\$${formatAmount(totalAmount)}",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),

                ],
              ),
              SizedBox(height: 6,),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Duplicate Entry:",
                    style: TextStyle(fontSize: 16),
                  ),
                  Text(
                    "${duplicateExpense}",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),

                ],
              ),
            ],
          ),
        ),
      ),
          Expanded(
            child: ListView.builder(
              itemCount: expenses.length,
              itemBuilder: (context, index) {
                var expense = expenses[index];
                return Card(
                  child: ListTile(
                    title: Text(expense["description"]),
                    subtitle: Text("Amount: \$${formatAmount(expense["amount"])} | Date: ${expense["date"]}"),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (expense["category"] == "Duplicate")
                          Icon(Icons.warning, color: Colors.red, size: 20), // Duplicate marker
                        IconButton(
                          icon: Icon(Icons.delete, color: Colors.red),
                          onPressed: () {
                            expenses.removeAt(index);
                            setState(() {
                              expenses;
                            });

                          }//expense.remove(expense.)),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          ElevatedButton(
              onPressed:(){

                Navigator.pop(context);},
              child: Text("Save Expenses")),
          SizedBox(height: 10,),
          ElevatedButton(
              onPressed:() {

                int i = 0;
                List<Map<String, dynamic>> deletedDxpenses = [];
                expenses.forEach((expense) {
                  if (expense["category"] != "Duplicate") {
                    deletedDxpenses.add( expense);
                  }
                });
                setState(() {
                  expenses =deletedDxpenses;
                  duplicateExpense = 0;
                });
              },
                //Navigator.pop(context);},
              child: Text("Delete Dup Expenses")),
        ],
      )
    );
  }
}