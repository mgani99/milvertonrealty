import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:milvertonrealty/common/service.dart';

class CategoryManagementPage extends StatefulWidget {
  @override
  _CategoryManagementPageState createState() => _CategoryManagementPageState();
}

class _CategoryManagementPageState extends State<CategoryManagementPage> {
  final databaseRef = MR_DBService().getDBRef("ExpenseCategory");
  Map<String, List<String>> categories = {};
  String newCategory = "";
  String selectedCategory = "";
  String newSubcategory = "";

  @override
  void initState() {
    super.initState();
    fetchCategories();
    listenToCategoryUpdates();
  }

  void listenToCategoryUpdates() {
    databaseRef.onValue.listen((event) {
      Map<dynamic, dynamic>? updatedData = event.snapshot.value as Map<dynamic, dynamic>?;

      if (updatedData != null) {
        setState(() {
          categories = updatedData.map((key, value) => MapEntry(key.toString(), List<String>.from(value)));
        });
      }
    });
    setState(() {

    });
  }
  void fetchCategories() async {
    DataSnapshot snapshot = await databaseRef.get();
    Map<dynamic, dynamic>? data = snapshot.value as Map<dynamic, dynamic>?;

    if (data != null) {
      categories = data.map((key, value) => MapEntry(key.toString(), List<String>.from(value)));
    }
    setState(() {});
  }

  void addCategory() {
    if (newCategory.isNotEmpty) {
      categories[newCategory] = [];
      databaseRef.child(newCategory).set([]);
      setState(() => newCategory = "");
    }
  }

  void addSubcategory() {
    if (selectedCategory.isNotEmpty && newSubcategory.isNotEmpty) {
      categories[selectedCategory]!.add(newSubcategory);
      databaseRef.child(selectedCategory).set(categories[selectedCategory]);
      setState(() => newSubcategory = "");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Manage Categories")),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              decoration: InputDecoration(labelText: "New Category"),
              onChanged: (value) => newCategory = value,
            ),
            ElevatedButton(onPressed: addCategory, child: Text("Add Category")),
            SizedBox(height: 20),
            DropdownButton<String>(
              value: selectedCategory.isNotEmpty ? selectedCategory : null,
              hint: Text("Select Category"),
              items: categories.keys.map((category) {
                return DropdownMenuItem(value: category, child: Text(category));
              }).toList(),
              onChanged: (value) {
                setState(() => selectedCategory = value!);
              },
            ),
            TextField(
              decoration: InputDecoration(labelText: "New Subcategory"),
              onChanged: (value) => newSubcategory = value,
            ),
            ElevatedButton(onPressed: addSubcategory, child: Text("Add Subcategory")),
            SizedBox(height: 20),
            Expanded(
              child: ListView(
                children: categories.entries.map((entry) {
                  return ExpansionTile(
                    title: Text(entry.key),
                    children: entry.value.map((subcategory) => ListTile(title: Text(subcategory))).toList(),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}