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
      title: 'Tenant Search App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: TenantSearchScreen(), // Default goes to add mode
    );
  }
}

// The add/edit screen. If tenantKey and tenantData are provided,
// the screen will act as an edit screen with pre-populated form fields.
class TenantSearchScreen extends StatefulWidget {
  final String? tenantKey;
  final Map<dynamic, dynamic>? tenantData;

  // If tenantKey and tenantData are null, then we are in "add" mode.
  TenantSearchScreen({this.tenantKey, this.tenantData});

  @override
  _TenantSearchScreenState createState() => _TenantSearchScreenState();
}

class _TenantSearchScreenState extends State<TenantSearchScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers for form fields.
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  bool _hasSection8 = false;
  DateTime? _availabilityDate;

  // Reference to the Firebase Realtime Database node "tenant_leads"
  final DatabaseReference _tenantLeadsRef =
  MR_DBService().getDBRef("tenant_leads");

  @override
  void initState() {
    super.initState();
    // If tenantData is provided, pre-populate the form for editing.
    if (widget.tenantData != null) {
      _nameController.text = widget.tenantData!['name'] ?? '';
      _phoneController.text = widget.tenantData!['phone'] ?? '';
      _descriptionController.text = widget.tenantData!['description'] ?? '';
      _hasSection8 = widget.tenantData!['hasSection8'] ?? false;
      String availDateStr = widget.tenantData!['availabilityDate'] ?? '';
      if (availDateStr.isNotEmpty) {
        _availabilityDate = DateTime.tryParse(availDateStr);
      }
    }
  }

  // Opens a date picker for selecting the availability date.
  Future<void> _selectAvailabilityDate() async {
    DateTime now = DateTime.now();
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _availabilityDate ?? now,
      firstDate: DateTime(now.year - 5),
      lastDate: DateTime(now.year + 5),
    );

    if (pickedDate != null) {
      setState(() {
        _availabilityDate = pickedDate;
      });
    }
  }

  // Submits the form. If in edit mode (tenantKey != null), it updates the record.
  // Otherwise, it creates a new entry.
  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      Map<String, dynamic> tenantData = {
        'name': _nameController.text,
        'phone': _phoneController.text,
        'description': _descriptionController.text,
        'hasSection8': _hasSection8,
        // Store the availability date as ISO8601 string if available.
        'availabilityDate': _availabilityDate?.toIso8601String() ?? "",
        'timestamp': DateTime.now().toIso8601String(),
      };

      try {
        if (widget.tenantKey != null) {
          // Edit mode: update the existing record.
          await _tenantLeadsRef.child(widget.tenantKey!).update(tenantData);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Tenant lead updated!')),
          );
        } else {
          // Add mode: push a new record.
          await _tenantLeadsRef.push().set(tenantData);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Tenant lead saved!')),
          );
        }
        // Clear the form when done.
        _formKey.currentState!.reset();
        _nameController.clear();
        _phoneController.clear();
        _descriptionController.clear();
        setState(() {
          _hasSection8 = false;
          _availabilityDate = null;
        });
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving lead: $e')),
        );
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Give a different title based on mode.
    String title = widget.tenantKey != null ? "Edit Tenant Lead" : "Add Tenant Lead";
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      // Floating action button to navigate to the list screen.
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.list),
        tooltip: "View Saved Tenants",
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => TenantListScreen()),
          );
        },
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Tenant name input field.
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(labelText: 'Tenant Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter tenant name';
                  }
                  return null;
                },
              ),
              SizedBox(height: 10),
              // Phone number input field.
              TextFormField(
                controller: _phoneController,
                decoration: InputDecoration(labelText: 'Phone Number'),
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter phone number';
                  }
                  return null;
                },
              ),
              SizedBox(height: 10),
              // Description input field.
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(
                  labelText: 'Description (Salary, Work Status, etc.)',
                  alignLabelWithHint: true,
                ),
                maxLines: 3,
              ),
              SizedBox(height: 10),
              // Checkbox for Section 8 Voucher.
              Row(
                children: [
                  Checkbox(
                    value: _hasSection8,
                    onChanged: (value) {
                      setState(() {
                        _hasSection8 = value ?? false;
                      });
                    },
                  ),
                  Text("Has Section 8 Voucher"),
                ],
              ),
              SizedBox(height: 10),
              // Row for selecting the availability date.
              Row(
                children: [
                  Expanded(
                    child: Text(
                      _availabilityDate == null
                          ? "Select Availability Date"
                          : "Available on: ${_availabilityDate!.toLocal().toString().split(' ')[0]}",
                    ),
                  ),
                  SizedBox(
                    width: 100, height: 50,
                    child: ElevatedButton(
                      onPressed: _selectAvailabilityDate,
                      child: Text("Pick Date"),
                    ),
                  )
                ],
              ),
              SizedBox(height: 20),
              // Submission button.
              ElevatedButton(
                onPressed: _submitForm,
                child: Text(widget.tenantKey != null ? "Update Tenant Lead" : "Save Tenant Lead"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}



class TenantListScreen extends StatefulWidget {
  @override
  _TenantListScreenState createState() => _TenantListScreenState();
}

class _TenantListScreenState extends State<TenantListScreen> {
  final DatabaseReference _tenantLeadsRef = MR_DBService().getDBRef("tenant_leads");

  String _searchQuery = "";
  bool _isSearching = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _isSearching
            ? TextField(
          decoration: InputDecoration(
            hintText: "Search tenants...",
            border: InputBorder.none,
            hintStyle: TextStyle(color: Colors.white54),
          ),
          style: TextStyle(color: Colors.black, fontSize: 16.0),
          autofocus: true,
          onChanged: (value) {
            setState(() {
              _searchQuery = value;
            });
          },
        )
            : Text("Saved Tenant Leads"),
        actions: [
          IconButton(
            icon: Icon(_isSearching ? Icons.cancel : Icons.search),
            onPressed: () {
              setState(() {
                if (_isSearching) {
                  _isSearching = false;
                  _searchQuery = "";
                } else {
                  _isSearching = true;
                }
              });
            },
          )
        ],
      ),
      body: StreamBuilder<DatabaseEvent>(
        stream: _tenantLeadsRef.onValue,
        builder: (context, snapshot) {
          if (snapshot.hasData && snapshot.data!.snapshot.value != null) {
            // Convert Firebase data into a map.
            Map<dynamic, dynamic> firebaseData =
            snapshot.data!.snapshot.value as Map<dynamic, dynamic>;
            // Convert map entries to a list to access keys.
            List<MapEntry<dynamic, dynamic>> entries =
            firebaseData.entries.toList();

            // If there is a search query, filter entries where the tenant name or description contains the query.
            if (_searchQuery.isNotEmpty) {
              entries = entries.where((entry) {
                Map tenant = entry.value as Map;
                String name = (tenant['name'] ?? "").toString().toLowerCase();
                String description =
                (tenant['description'] ?? "").toString().toLowerCase();
                String phone = (tenant['phone'] ?? "").toString();
                return name.contains(_searchQuery.toLowerCase()) ||
                    description.contains(_searchQuery.toLowerCase()) ||
                phone.contains(_searchQuery);
              }).toList();
            }

            if (entries.isEmpty) {
              return Center(child: Text("No matching tenants found"));
            }

            return ListView.builder(
              padding: EdgeInsets.all(8),
              itemCount: entries.length,
              itemBuilder: (context, index) {
                final key = entries[index].key;
                final tenant = entries[index].value;
                return Card(
                  elevation: 4,
                  margin: EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          tenant['name'] ?? 'No Name',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 8),
                        Text("Phone: ${tenant['phone'] ?? ''}"),
                        if (tenant['description'] != null &&
                            tenant['description'].toString().isNotEmpty)
                          Text("Description: ${tenant['description']}"),
                        Text("Section 8: ${tenant['hasSection8'] == true ? 'Yes' : 'No'}"),
                        if (tenant['availabilityDate'] != null &&
                            tenant['availabilityDate'].toString().isNotEmpty)
                          Text("Available on: ${tenant['availabilityDate']}"),
                        SizedBox(height: 8),
                        Row(
                          children: [
                            // Edit button; navigates to the add/edit screen with pre-populated data.
                            SizedBox(
                              width: 100, height: 50,
                              child: ElevatedButton.icon(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => TenantSearchScreen(
                                        tenantKey: key.toString(),
                                        tenantData: tenant,
                                      ),
                                    ),
                                  );
                                },
                                icon: Icon(Icons.edit, color: Colors.white),
                                label: Text("Edit"),
                                style: ElevatedButton.styleFrom(
                                  foregroundColor: Colors.blue,
                                ),
                              ),
                            ),
                            SizedBox(width: 16),
                            // Delete button.
                            SizedBox(
                              width: 100, height: 50,
                              child: ElevatedButton.icon(
                                onPressed: () async {
                                  try {
                                    await _tenantLeadsRef
                                        .child(key.toString())
                                        .remove();
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                          content:
                                          Text('Tenant record deleted!')),
                                    );
                                  } catch (e) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                          content: Text(
                                              'Error deleting record: $e')),
                                    );
                                  }
                                },
                                icon: Icon(Icons.delete, color: Colors.white),
                                label: Text("Delete"),
                                style: ElevatedButton.styleFrom(
                                    foregroundColor: Colors.red),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          } else if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else {
            return Center(child: Text("No Tenant Leads Found"));
          }
        },
      ),
    );
  }
}








// Screen that displays all tenant leads in cards with edit and delete options.
class TenantListScreen2 extends StatelessWidget {
  final DatabaseReference _tenantLeadsRef = MR_DBService().getDBRef("tenant_leads");

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Saved Tenant Leads"),
      ),
      body: StreamBuilder<DatabaseEvent>(
        stream: _tenantLeadsRef.onValue,
        builder: (context, snapshot) {
          if (snapshot.hasData && snapshot.data!.snapshot.value != null) {
            // Convert the data snapshot into a map.
            Map<dynamic, dynamic> firebaseData = snapshot.data!.snapshot.value as Map<dynamic, dynamic>;
            // Convert map entries to a list in order to access keys for deletion and editing.
            List<MapEntry<dynamic, dynamic>> entries = firebaseData.entries.toList();

            return ListView.builder(
              padding: EdgeInsets.all(8),
              itemCount: entries.length,
              itemBuilder: (context, index) {
                final key = entries[index].key;
                final tenant = entries[index].value;
                return Card(
                  elevation: 4,
                  margin: EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          tenant['name'] ?? 'No Name',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 8),
                        Text("Phone: ${tenant['phone'] ?? ''}"),
                        if (tenant['description'] != null && tenant['description'].toString().isNotEmpty)
                          Text("Description: ${tenant['description']}"),
                        Text("Section 8: ${tenant['hasSection8'] == true ? 'Yes' : 'No'}"),
                        if (tenant['availabilityDate'] != null && tenant['availabilityDate'].toString().isNotEmpty)
                          Text("Available on: ${tenant['availabilityDate']}"),
                        SizedBox(height: 8),
                        Row(
                          children: [
                            // Edit Button: navigates to the TenantSearchScreen in edit mode.
                            SizedBox(
                              width: 100,height:50,
                              child: ElevatedButton.icon(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => TenantSearchScreen(
                                        tenantKey: key.toString(),
                                        tenantData: tenant,
                                      ),
                                    ),
                                  );
                                },
                                icon: Icon(Icons.edit, color: Colors.white),
                                label: Text("Edit"),
                                style: ElevatedButton.styleFrom(foregroundColor: Colors.blue),
                              ),
                            ),
                            SizedBox(width: 16),
                            // Delete Button: removes the record from Firebase.
                            SizedBox(
                              width: 100,height: 50,
                              child: ElevatedButton.icon(
                                onPressed: () async {
                                  try {
                                    await _tenantLeadsRef.child(key.toString()).remove();
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text('Tenant record deleted!')),
                                    );
                                  } catch (e) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text('Error deleting record: $e')),
                                    );
                                  }
                                },
                                icon: Icon(Icons.delete, color: Colors.white),
                                label: Text("Delete"),
                                style: ElevatedButton.styleFrom(foregroundColor: Colors.red),
                              ),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                );
              },
            );
          } else if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else {
            return Center(child: Text("No Tenant Leads Found"));
          }
        },
      ),
    );
  }
}
