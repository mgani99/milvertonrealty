import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:milvertonrealty/common/service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(); // Initialize Firebase
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Rental Unit Repairs',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: RepairRequestScreen(),
    );
  }
}

class RepairRequestScreen extends StatefulWidget {
  @override
  _RepairRequestScreenState createState() => _RepairRequestScreenState();
}

class _RepairRequestScreenState extends State<RepairRequestScreen> {
  // Controllers for custom category and repair description.
  final TextEditingController _customCategoryController = TextEditingController();
  final TextEditingController _repairDescriptionController = TextEditingController();

  // The currently selected room. Default is "Bedroom" (you can change as needed).
  String _selectedRoom = "Bedroom";

  // Predefined list of rooms.
  final List<String> _rooms = ["Bedroom", "Bathroom", "Kitchen", "Hallway"];

  // List of categories fetched from the database for the selected room.
  List<String> _categories = [];

  // The currently selected category (via chip) if any.
  String? _selectedCategory;

  // Firebase Realtime Database references.
  // Expecting the data structure for categories as:
  // repair_categories/
  //    bedroom: { key1: "Leaky Faucet", key2: "Broken Lamp", ... }
  final DatabaseReference _categoriesRef = MR_DBService().getDBRef("RepairCategories");
  final DatabaseReference _repairRequestsRef = FirebaseDatabase.instance.ref("repair_requests");

  @override
  void initState() {
    super.initState();
    // Fetch categories for the default room.
    _fetchCategoriesForRoom(_selectedRoom);
  }

  /// Fetches repair categories for the given room (by reading "repair_categories/{room}").
  void _fetchCategoriesForRoom(String room) {
    String roomKey = room.toLowerCase(); // Ensure consistency with your database keys.
    _categoriesRef.child(roomKey).onValue.listen((DatabaseEvent event) {
      List<String> fetchedCategories = [];
      final data = event.snapshot.value;
      if (data != null) {
        print(data);
        // Data is expected to be a map of key/value pairs.
        Map<dynamic, dynamic> categoryMap = data as Map<dynamic, dynamic>;
        categoryMap.forEach((key, value) {
          if (value != null) {
            fetchedCategories.add(value.toString());
          }
        });
      }
      setState(() {
        _categories = fetchedCategories;
        // If the previously selected category isn't in the new list, clear it.
        if (!_categories.contains(_selectedCategory)) {
          _selectedCategory = null;
        }
      });
    });
  }

  /// Submits the repair request. If a custom category is provided and is new,
  /// it is added to the database under repair_categories/{room}.
  Future<void> _submitRepairRequest() async {
    // Determine the category value:
    // If the custom text field is non-empty, use it.
    // Otherwise, use the selected chip.
    String category = "";
    if (_customCategoryController.text.trim().isNotEmpty) {
      category = _customCategoryController.text.trim();

      // If this category doesn't already exist, add it to the current room node.
      if (!_categories.contains(category)) {
        await _categoriesRef.child(_selectedRoom.toLowerCase()).push().set(category);
      }
    } else if (_selectedCategory != null) {
      category = _selectedCategory!;
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please select a category or enter a custom category")),
      );
      return;
    }

    // Validate that a repair description is provided.
    String repairDescription = _repairDescriptionController.text.trim();
    if (repairDescription.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please provide repair details")),
      );
      return;
    }

    // Build repair request data.
    Map<String, dynamic> repairData = {
      'room': _selectedRoom,
      'category': category,
      'description': repairDescription,
      'timestamp': DateTime.now().toIso8601String(),
    };

    try {
      await _repairRequestsRef.push().set(repairData);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Repair request submitted!")),
      );
      // Clear selections and text fields.
      setState(() {
        _selectedCategory = null;
      });
      _customCategoryController.clear();
      _repairDescriptionController.clear();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error submitting repair request: $e")),
      );
    }
  }

  @override
  void dispose() {
    _customCategoryController.dispose();
    _repairDescriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Rental Unit Repairs"),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Dropdown for selecting a room.
            Text(
              "Select Room:",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            DropdownButton<String>(
              value: _selectedRoom,
              items: _rooms
                  .map((room) => DropdownMenuItem(
                value: room,
                child: Text(room),
              ))
                  .toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _selectedRoom = value;
                    _selectedCategory = null;
                    _customCategoryController.clear();
                  });
                  // Fetch categories for the newly selected room.
                  _fetchCategoriesForRoom(value);
                }
              },
            ),
            SizedBox(height: 16),
            // Display fetched categories as ChoiceChips.
            Text(
              "Select a Repair Category:",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Wrap(
              spacing: 8.0,
              children: _categories.map((category) {
                return ChoiceChip(
                  label: Text(category),
                  selected: _selectedCategory == category,
                  onSelected: (selected) {
                    setState(() {
                      _selectedCategory = selected ? category : null;
                      // Clear custom category if a chip is selected.
                      if (selected) _customCategoryController.clear();
                    });
                  },
                );
              }).toList(),
            ),
            SizedBox(height: 16),
            // Field to enter a custom category.
            Text(
              "Or Enter Custom Category:",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            TextField(
              controller: _customCategoryController,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                hintText: "Custom Category",
              ),
              onChanged: (value) {
                // If the user types in a custom category, unselect any chip.
                if (value.trim().isNotEmpty) {
                  setState(() {
                    _selectedCategory = null;
                  });
                }
              },
            ),
            SizedBox(height: 16),
            // Field for repair description.
            Text(
              "Repair Description:",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            TextField(
              controller: _repairDescriptionController,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                hintText: "Describe the repair issue...",
              ),
              maxLines: 4,
            ),
            SizedBox(height: 24),
            // Submission button.
            Center(
              child: ElevatedButton(
                onPressed: _submitRepairRequest,
                child: Text("Submit Repair Request"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
