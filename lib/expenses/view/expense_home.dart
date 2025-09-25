import 'dart:io';

import 'package:csv/csv.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:intl/intl.dart';
import 'package:milvertonrealty/common/service.dart';
import 'package:milvertonrealty/expenses/view/expense_uploader.dart';

import '../../utils/number_formatter.dart';
import 'categorized_expense.dart';

class ExpenseSummaryPage extends StatefulWidget {
  @override
  _ExpenseSummaryPageState createState() => _ExpenseSummaryPageState();
}

class _ExpenseSummaryPageState extends State<ExpenseSummaryPage> {
  final databaseRef = MR_DBService().getDBRef("Expenses");
  String selectedMonthYear = DateFormat('MMM yyyy').format(DateTime.now());
  Map<String, List<Map<String, dynamic>>> groupedExpenses = {};
  Map<String, double> categoryTotals = {};
  double totalExpenseAmount = 0.0;
  Set<String> existingKeys = {};
  TextEditingController searchController = TextEditingController();


  void fetchExpenses(DateTime date) async {
    DataSnapshot snapshot = await databaseRef.child(DateFormat('MMyyyy').format(date)).get();
    Map<dynamic, dynamic>? data = snapshot.value as Map<dynamic, dynamic>?;

    groupedExpenses.clear();
     totalExpenseAmount = 0.0;


    if (data != null) {
      data.forEach((key, expense) {
        double amount = double.parse(expense["amount"].toString());
        totalExpenseAmount += amount;

        String category = expense["category"];
        if (!groupedExpenses.containsKey(category)) {
          groupedExpenses[category] = [];
          categoryTotals[category] = 0.0;

        }

        groupedExpenses[category]!.add(Map<String, dynamic>.from(expense));
        categoryTotals[category] = categoryTotals[category]! + amount;

      });
    }

    setState(() {
      this.totalExpenseAmount = totalExpenseAmount;
    });
  }



  void changeMonth(bool next) {
    print(selectedMonthYear);
    DateTime currentDate = DateFormat("MMM yyyy").parse(selectedMonthYear);

    DateTime newDate = next
        ? DateTime(currentDate.year, currentDate.month + 1)
        : DateTime(currentDate.year, currentDate.month - 1);

    setState(() {
      selectedMonthYear = DateFormat('MMM yyyy').format(newDate);
      fetchExpenses(DateFormat("MMM yyyy").parse(selectedMonthYear));
    });
  }
  String formatAmount(double amount) {
    return NumberFormat("#,##0.00", "en_US").format(amount);
  }



  @override
  void initState() {
    super.initState();
    fetchExpenses(DateFormat("MMM yyyy").parse(selectedMonthYear));

  }

  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    listenToAllExpenses();
    super.didChangeDependencies();
  }


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

  void listenToAllExpenses() {
    MR_DBService().getDBRef("Expenses").onValue.listen((event) {
      Map<dynamic, dynamic>? allMonthsData = event.snapshot.value as Map<dynamic, dynamic>?;

      groupedExpenses.clear();
      totalExpenseAmount = 0.0;

      if (allMonthsData != null) {
        allMonthsData.forEach((monthYear, expenses) {
          expenses.forEach((key, expense) {
            double amount = double.parse(expense["amount"].toString());
            totalExpenseAmount += amount;

            String category = expense["category"];
            if (!groupedExpenses.containsKey(category)) {
              groupedExpenses[category] = [];
            }
            groupedExpenses[category]!.add(Map<String, dynamic>.from(expense));
          });
        });
        print("update");
        print("update");
      }

      setState(() {}); // Update UI automatically when changes occur
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Expense Summary"),
       actions: [
          IconButton(
          icon: Icon(Icons.clear),
      onPressed: () {
        searchController.clear();
      },
    ),

         PopupMenuButton<String>(
           onSelected: (value) {
             if (value == "Upload Expense") {
              // uploadCsvFile();

                 Navigator.push(
                   context,
                   MaterialPageRoute(builder: (context) => (ExpensePage())),
                 );
             }
             //if (value == "View Uncategorized Expenses") fetchUncategorizedExpenses();

           },
           itemBuilder: (BuildContext context) {
             return [
               PopupMenuItem(value: "Upload Expense", child: Text("Upload Expense")),
              // PopupMenuItem(value: "View Uncategorized Expenses", child: Text("View Uncat Expenses")),

             ];
           },
         ),
      ],
      ),
      body: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(icon: Icon(Icons.arrow_back), onPressed: () => changeMonth(false)),
              Text(selectedMonthYear, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87)),
              IconButton(icon: Icon(Icons.arrow_forward), onPressed: () => changeMonth(true)),
            ],
          ),
          Card(
            margin: EdgeInsets.all(16),
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                children:[
                  Text("Total Expenses: ${formatAmount(totalExpenseAmount)}",
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87)),

                ],

              ),
            ),
          ),
          Expanded(
            child: ListView(
              children: groupedExpenses.keys.map((category) {
                double totalCategoryAmount = categoryTotals.containsKey(category) ? categoryTotals[category]! : 0.0;
                return ExpansionTile(
                  title: Text("$category (${formatAmount(totalCategoryAmount)})",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black45)),
                  children: groupedExpenses[category]!.map((expense) {
                    return ListTile(
                 title: ExpenseCard(
                   expense: expense,
                   onTap: () {
                     Navigator.push(
                       context,
                       MaterialPageRoute(
                         builder: (context) => CategorizeExpensePage(expense: expense),

                       ),

                     );
                     setState(() {
                       
                     });
                   },
                 )

                    );
                  }).toList(),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}



class ExpenseCard extends StatelessWidget {
  final Map<String, dynamic> expense;
  final VoidCallback onTap;

  ExpenseCard({required this.expense, required this.onTap});



  String formatDate(String date) {
    DateTime parsedDate = DateFormat('MM-dd-yyyy').parse(date);
    String month = DateFormat('MMMM').format(parsedDate);
    int day = parsedDate.day;

    String suffix = "th";
    if (day % 10 == 1 && day != 11) suffix = "st";
    else if (day % 10 == 2 && day != 12) suffix = "nd";
    else if (day % 10 == 3 && day != 13) suffix = "rd";

    return "$month $day$suffix";
  }
  void openSplitExpenseDialog(BuildContext context, Map<String, dynamic> expense) {
    List<double> splitAmounts = [];
    TextEditingController amountController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text("Split Expense"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ...splitAmounts.map((amount) => Text("\$${formatAmount(amount)}")).toList(),
                  TextField(
                    controller: amountController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(hintText: "Enter Amount"),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      double enteredAmount = double.tryParse(amountController.text) ?? 0.0;
                      if (enteredAmount > 0) {
                        setState(() {
                          splitAmounts.add(enteredAmount);
                          amountController.clear();
                        });
                      }
                    },
                    child: Text("Add Split Amount"),
                  ),
                ],
              ),
              actions: [
                ElevatedButton(onPressed: () => Navigator.pop(context), child: Text("Cancel")),
                ElevatedButton(
                  onPressed: () {
                    saveSplitExpenses(expense, splitAmounts);
                    Navigator.pop(context);
                  },
                  child: Text("Save"),
                ),
              ],
            );
          },
        );
      },
    );
  }
  void saveSplitExpenses(Map<String, dynamic> expense, List<double> splitAmounts) {
    String monthYear = expense["date"].substring(0, 2) + expense["date"].substring(6, 10);

    for (double amount in splitAmounts) {
      DatabaseReference expenseRef = MR_DBService().getDBRef("Expenses/$monthYear").push();
      expenseRef.set({
        "date": expense["date"],
        "description": expense["description"] + " (Split)",
        "amount": amount,
        "category": expense["category"],
        "subcategory": expense["subcategory"],
        "key": expenseRef.key,
      });
    }
  }
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap, // Calls the provided function when tapped
      child: Card(
        margin: EdgeInsets.zero,
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
          child: Row(
            children: [
              Expanded(
                flex: 5,
                child: Text(expense["description"],
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Row(
                    children: [
                      Text("\$${formatAmount(double.parse(expense["amount"].toString()))}",
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.green[700])),
                     // SizedBox(width: 1),
                      IconButton(
                        icon: Icon(Icons.add, size: 20, color: Colors.blue),
                        onPressed: () => openSplitExpenseDialog(context, expense),
                      ),
                    ],
                  ),
                  Text(formatDate(expense["date"]),
                      style: TextStyle(fontSize: 14, color: Colors.grey[600])),
                ],
              ),
            ],
          ),
        ),
      ),

    );
  }
}