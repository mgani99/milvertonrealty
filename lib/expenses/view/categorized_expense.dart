import 'dart:math';

import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:milvertonrealty/common/service.dart';

import 'category_management.dart';

class CategorizeExpensePage extends StatefulWidget {
  final Map<String, dynamic> expense;
  CategorizeExpensePage({required this.expense});

  @override
  _CategorizeExpensePageState createState() => _CategorizeExpensePageState();
}

class _CategorizeExpensePageState extends State<CategorizeExpensePage> {
  final databaseRef = FirebaseDatabase.instance.ref();
  List<String> categories = [];
  List<String> subcategories = [];
  String selectedCategory = "";
  String selectedSubcategory = "";
  String expenseNote = "";

  @override
  void initState() {
    super.initState();
    fetchCategories();

  }

  void fetchCategories() async {
    DataSnapshot snapshot =  await MR_DBService().getDBRef("ExpenseCategory").get();
    Map<dynamic, dynamic>? data = snapshot.value as Map<dynamic, dynamic>?;

    if (data != null) {
      categories = data.keys.map((e) => e.toString()).toList();
    }
    setState(() {});
  }

  void fetchSubcategories(String category) async {
    DataSnapshot snapshot = await MR_DBService().getDBRef("ExpenseCategory/$category").get();
    List<dynamic>? data = snapshot.value as List<dynamic>?;

    subcategories = data != null ? data.map((e) => e.toString()).toList() : [];
    setState(() {});
  }



  void deleteExpense(BuildContext context, String expenseKey, Map<String, dynamic> expense) {
    String monthYear = expense["date"].substring(0, 2) + expense["date"].substring(6, 10);

    MR_DBService().getDBRef("Expenses/$monthYear/$expenseKey").remove().then((_) {
      //Navigator.pop(context); // Go back after deletion
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Expense deleted successfully!")));
    }).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error deleting expense: $error")));
    });
  }

  void addNewCategory() {
    // TODO: Implement Add Category Screen
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Categorize Expense"),
        actions: [
          IconButton(icon: Icon(Icons.settings), onPressed: (){
          Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => CategoryManagementPage()),
          );
          },
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Card(
              child: ListTile(
                title: Text(widget.expense["description"]),
                subtitle: Text("Amount: \$${widget.expense["amount"]} | Date: ${widget.expense["date"]}"),
              ),
            ),
            SizedBox(height: 25),
            DropdownButton<String>(
              value: selectedCategory.isNotEmpty ? selectedCategory : widget.expense["category"], // Pre-filled category
              hint: Text("Select Category"),
              items: categories.map((category) {
                return DropdownMenuItem(value: category, child: Text(category));
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedCategory = value!;
                  if (selectedCategory == "Uncategorized") {
                    selectedSubcategory = "Uncategorized";
                  }
                  fetchSubcategories(value);
                });
              },
            ),
            SizedBox(height: 30),
            DropdownButton<String>(
              value: selectedSubcategory.isNotEmpty ? selectedSubcategory : null,
              hint: Text("Select Subcategory"),
              items: subcategories.map((subcategory) {
                return DropdownMenuItem(value: subcategory, child: Text(subcategory));
              }).toList(),
              onChanged: (value) {
                print("select $value");
                selectedSubcategory = value!;
              },
            ),

            SizedBox(height: 30),
            TextField(
              decoration: InputDecoration(
                labelText: "Note",
                hintText: "Add additional details",
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() {
                  expenseNote = value;
                });
              },
            ),
            SizedBox(height: 25,),

            ElevatedButton(
            onPressed:(){
              String monthYear = widget.expense["date"].substring(0, 2) + widget.expense["date"].substring(6, 10);
              String expenseKey = widget.expense["key"];
              MR_DBService().getDBRef("Expenses/$monthYear/$expenseKey").update({
                "category": selectedCategory.isNotEmpty ? selectedCategory : "Uncategorized",
                "subcategory": selectedSubcategory.isNotEmpty ? selectedSubcategory : "Uncategorized"
              }).then((_) {
                print("Expense updated successfully!");
              }).catchError((error) {
                print("Failed to update expense: $error");
              });
              Navigator.pop(context);},
            child: Text("Save Expense")),
            SizedBox(height: 10,),
            ElevatedButton(
                onPressed:(){
                  //String monthYear = widget.expense["date"].substring(0, 2) + widget.expense["date"].substring(6, 10);
                  String expenseKey = widget.expense["key"];
                  deleteExpense(context, expenseKey, widget.expense);
                  Navigator.pop(context);},
                child: Text("Delete Expense", style: TextStyle(color: Colors.redAccent),)),

          ],
        ),
      ),
    );
  }
}