import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:milvertonrealty/common/service.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:typed_data';

import '../../utils/google_drive.dart';

/// Helper function to format a phone number as (XXX) XXX-XXXX if 10 digits.
String formatPhone(String phone) {
  String digits = phone.replaceAll(RegExp(r'\D'), '');
  if (digits.length == 10) {
    return "(${digits.substring(0, 3)}) ${digits.substring(3, 6)}-${digits.substring(6, 10)}";
  }
  return phone;
}

/// Helper function to normalize a phone number (remove non-digit characters).
String normalizePhone(String phone) {
  return phone.replaceAll(RegExp(r'\D'), '');
}

/// A simple HTTP client that adds Google authentication headers.
class GoogleAuthClient extends http.BaseClient {
  final Map<String, String> _headers;
  final http.Client _client = http.Client();
  GoogleAuthClient(this._headers);

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    request.headers.addAll(_headers);
    return _client.send(request);
  }
}

/// Main entry point: Initialize Firebase.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(); // Add your firebase configuration.
  runApp(MyApp());
}

/// The root widget.
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tenant Lead Maintenance',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: TenantLeadHomePage(), // Changed here
    );
  }
}

/// TenantLeadHomePage displays a filtered, searchable, and sorted list
/// of tenant leads along with schedule filtering (if Status is "Scheduled").
/// The list is rendered in ascending order by createTimeStamp.
class TenantLeadHomePage extends StatefulWidget {
  @override
  _TenantLeadHomePageState createState() => _TenantLeadHomePageState();
}

class _TenantLeadHomePageState extends State<TenantLeadHomePage> {
  // Firebase references.
  final DatabaseReference leadsRef = MR_DBService().getDBRef("tenant_leads");
  final DatabaseReference scheduleRef = MR_DBService().getDBRef("schedule_times");

  List<Map<dynamic, dynamic>> tenantLeads = [];
  String filterStatus = "All"; // Status dropdown filter.
  List<String> scheduleTimes = [];
  String? scheduleFilter;

  @override
  void initState() {
    super.initState();
    // Listen for realtime changes from the tenant leads node.
    leadsRef.onValue.listen((event) {
      final data = event.snapshot.value as Map<dynamic, dynamic>?;
      List<Map<dynamic, dynamic>> leadsList = [];
      if (data != null) {
        data.forEach((key, value) {
          final Map lead = value as Map;
          lead['key'] = key;
          leadsList.add(Map<dynamic, dynamic>.from(lead));
        });
      }
      setState(() {
        tenantLeads = leadsList;
      });
    });
    // Fetch schedule times.
    fetchScheduleTimes();
  }

  /// Fetch schedule times from Firebase.
  Future<void> fetchScheduleTimes() async {
    final snapshot = await scheduleRef.get();
    List<String> times = [];
    if (snapshot.exists) {
      final data = snapshot.value as Map<dynamic, dynamic>;
      data.forEach((key, value) {
        times.add(value.toString());
      });
    }
    setState(() {
      scheduleTimes = times;
    });
  }

  /// Opens the Tenant Lead Form.
  void _showTenantLeadForm({Map? tenantLead}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TenantLeadForm(tenantLead: tenantLead),
      ),
    );
  }

  /// Displays a dialog to manage schedule times.
  void _addScheduleTime() {
    TextEditingController newScheduleController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(builder: (context, setStateDialog) {
          return AlertDialog(
            title: Text("Schedule Times"),
            content: Container(
              width: double.maxFinite,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  FutureBuilder(
                    future: scheduleRef.get(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(child: CircularProgressIndicator());
                      } else if (snapshot.hasData && snapshot.data!.exists) {
                        final data = snapshot.data!.value as Map<dynamic, dynamic>;
                        List<Map<String, dynamic>> scheduleList = [];
                        data.forEach((key, value) {
                          scheduleList.add({"key": key, "time": value});
                        });
                        return Container(
                          height: 150,
                          child: ListView.builder(
                            itemCount: scheduleList.length,
                            itemBuilder: (context, index) {
                              final scheduleEntry = scheduleList[index];
                              return ListTile(
                                title: Text(scheduleEntry["time"].toString()),
                                trailing: IconButton(
                                  icon: Icon(Icons.delete, color: Colors.red),
                                  onPressed: () async {
                                    await scheduleRef.child(scheduleEntry["key"].toString()).remove();
                                    setStateDialog(() {});
                                    fetchScheduleTimes();
                                  },
                                ),
                              );
                            },
                          ),
                        );
                      } else {
                        return Text("No schedule times found.");
                      }
                    },
                  ),
                  SizedBox(height: 16),
                  TextField(
                    controller: newScheduleController,
                    decoration: InputDecoration(
                      labelText: "New Schedule Time",
                      border: OutlineInputBorder(),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.of(context).pop(), child: Text("Close")),
              TextButton(
                onPressed: () async {
                  String newTime = newScheduleController.text;
                  if (newTime.isNotEmpty) {
                    await scheduleRef.push().set(newTime);
                    newScheduleController.clear();
                    setStateDialog(() {});
                    fetchScheduleTimes();
                  }
                },
                child: Text("Add"),
              ),
            ],
          );
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Filter tenant leads based on selected status and schedule time filter (if status is Scheduled).
    List<Map<dynamic, dynamic>> filteredLeads = tenantLeads.where((lead) {
      bool statusMatches = filterStatus == "All" || lead['status'] == filterStatus;
      bool scheduleMatches = true;
      if (filterStatus == "Scheduled" && scheduleFilter != null) {
        scheduleMatches = lead['scheduleTime'] == scheduleFilter;
      }
      return statusMatches && scheduleMatches;
    }).toList();

    // Sort in ascending order by createTimeStamp.
    filteredLeads.sort((a, b) {
      DateTime ctsA = DateTime.tryParse(a['createTimeStamp'] ?? "") ??
          DateTime.fromMillisecondsSinceEpoch(0);
      DateTime ctsB = DateTime.tryParse(b['createTimeStamp'] ?? "") ??
          DateTime.fromMillisecondsSinceEpoch(0);
      return ctsA.compareTo(ctsB);
    });
    filteredLeads = filteredLeads.reversed.toList();
    return Scaffold(
      appBar: AppBar(
        title: Text("Tenant Leads"),
        actions: [
          IconButton(
            onPressed: _addScheduleTime,
            icon: Icon(Icons.schedule),
            tooltip: "Add / View Schedule Times",
          ),
          IconButton(
            onPressed: () {
              showSearch(
                context: context,
                delegate: TenantLeadSearchDelegate(tenantLeads: tenantLeads),
              );
            },
            icon: Icon(Icons.search),
            tooltip: "Search Tenant Leads",
          ),
        ],
      ),
      body: Column(
        children: [
          // Status Filter Dropdown.
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: DropdownButtonFormField<String>(
              value: filterStatus,
              decoration: InputDecoration(
                labelText: "Filter by Status",
                border: OutlineInputBorder(),
              ),
              items: [
                "All",
                "Pending",
                "Scheduled",
                "Onboard",
                "Tenant Accepted",
                "Landlord Rejected",
                "Tenant Rejected"
              ]
                  .map((status) => DropdownMenuItem(
                value: status,
                child: Text(status),
              ))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  filterStatus = value!;
                  if (filterStatus != "Scheduled") {
                    scheduleFilter = null;
                  }
                });
              },
            ),
          ),
          // If status is Scheduled, show schedule time chips.
          if (filterStatus == "Scheduled" && scheduleTimes.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: scheduleTimes.map((time) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: ChoiceChip(
                        label: Text(time),
                        selected: scheduleFilter == time,
                        onSelected: (bool selected) {
                          setState(() {
                            scheduleFilter = selected ? time : null;
                          });
                        },
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),

          Divider(),
          Text("Total Leads : ${filteredLeads.length}" , style: TextStyle(color: Colors.black, fontSize: 16),),
          // Display Tenant Lead Cards.
          Expanded(
            child: ListView.builder(
              itemCount: filteredLeads.length,
              itemBuilder: (context, index) {
                final lead = filteredLeads[index];
                return Card(
                  margin: EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                  elevation: 4,
                  child: InkWell(
                    onTap: () => _showTenantLeadForm(tenantLead: lead),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            lead['name'] ?? "",
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                          SizedBox(height: 4),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text("Phone: ${formatPhone(lead['phone'] ?? "")}", style: TextStyle(fontSize: 14)),
                              Text("Salary: ${lead['salary'] ?? ""}", style: TextStyle(fontSize: 14, color: Colors.black)),
                            ],
                          ),
                          SizedBox(height: 4),
                          Text("Status: ${lead['status'] ?? ""}", style: TextStyle(fontSize: 14)),
                          if (lead['status'] == "Scheduled" && lead['scheduleTime'] != null)
                            Text("Schedule Time: ${lead['scheduleTime']}", style: TextStyle(fontSize: 14)),
                          SizedBox(height: 8),
                          // Description in a compact, decorated container.
                          Container(
                            width: double.infinity,
                            padding: EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey),
                              borderRadius: BorderRadius.circular(4),
                              color: Colors.grey[200],
                            ),
                            child: Text(
                              lead['description'] ?? "",
                              style: TextStyle(fontSize: 12),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showTenantLeadForm(),
        child: Icon(Icons.add),
        tooltip: "Add New Tenant Lead",
      ),
    );
  }
}

/// Custom SearchDelegate to search tenant leads by name, phone, or description.
/// The phone search works with formatted and unformatted strings.
class TenantLeadSearchDelegate extends SearchDelegate {
  final List<Map<dynamic, dynamic>> tenantLeads;
  TenantLeadSearchDelegate({required this.tenantLeads});

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      if (query.isNotEmpty)
        IconButton(
          icon: Icon(Icons.clear),
          onPressed: () {
            query = "";
            showSuggestions(context);
          },
        ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.arrow_back),
      onPressed: () => close(context, null),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    final queryLower = query.toLowerCase();
    final queryNormalized = normalizePhone(query);
    final results = tenantLeads.where((lead) {
      final name = (lead['name'] ?? "").toLowerCase();
      final phone = lead['phone'] ?? "";
      final phoneNormalized = normalizePhone(phone);
      final description = (lead['description'] ?? "").toLowerCase();
      bool phoneMatches = queryNormalized.isNotEmpty
          ? phoneNormalized.contains(queryNormalized)
          : phone.toLowerCase().contains(queryLower);
      return name.contains(queryLower) ||
          phoneMatches ||
          description.contains(queryLower);
    }).toList();

    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (context, index) {
        final lead = results[index];
        return Card(
          margin: EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
          elevation: 4,
          child: ListTile(
            title: Text(lead['name'] ?? ""),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Phone: ${formatPhone(lead['phone'] ?? "")}"),
                Text("Salary: ${lead['salary'] ?? ""}"),
                Text("Status: ${lead['status'] ?? ""}"),
              ],
            ),
            onTap: () {
              close(context, null);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => TenantLeadForm(tenantLead: lead),
                ),
              );
            },
          ),
        );
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final queryLower = query.toLowerCase();
    final queryNormalized = normalizePhone(query);
    final results = tenantLeads.where((lead) {
      final name = (lead['name'] ?? "").toLowerCase();
      final phone = lead['phone'] ?? "";
      final phoneNormalized = normalizePhone(phone);
      final description = (lead['description'] ?? "").toLowerCase();
      bool phoneMatches = queryNormalized.isNotEmpty
          ? phoneNormalized.contains(queryNormalized)
          : phone.toLowerCase().contains(queryLower);
      return name.contains(queryLower) ||
          phoneMatches ||
          description.contains(queryLower);
    }).toList();

    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (context, index) {
        final lead = results[index];
        return ListTile(
          title: Text(lead['name'] ?? ""),
          subtitle: Text("Phone: ${formatPhone(lead['phone'] ?? "")}"),
          onTap: () {
            query = "";
            close(context, null);
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => TenantLeadForm(tenantLead: lead),
              ),
            );
          },
        );
      },
    );
  }
}

/// Tenant Lead Form WITHOUT the Action dropdown.
/// If Status is "Scheduled", schedule time chips are shown. Includes an Upload ID to Google Drive button.
/// Also, createTimeStamp and updateTimeStamp are stored.
class TenantLeadForm extends StatefulWidget {
  final Map? tenantLead;
  const TenantLeadForm({Key? key, this.tenantLead}) : super(key: key);
  @override
  _TenantLeadFormState createState() => _TenantLeadFormState();
}
class _TenantLeadFormState extends State<TenantLeadForm> {
  final _formKey = GlobalKey<FormState>();
  final DatabaseReference leadsRef = MR_DBService().getDBRef("tenant_leads");
  final DatabaseReference scheduleRef = MR_DBService().getDBRef("schedule_times");
  final GoogleDriveManager driveManager = GoogleDriveManager();

  TextEditingController tenantNameController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController salaryController = TextEditingController();
  TextEditingController noteController = TextEditingController();
  bool hasSection8 = false;
  DateTime? availabilityDate;
  String status = "Pending";
  // Removed action field.
  String? selectedScheduleTime;
  List<String> scheduleTimes = [];

  // Uploaded photo URL.
  String? _uploadedPhotoUrl;

  @override
  void initState() {
    super.initState();
    if (widget.tenantLead != null) {
      tenantNameController.text = widget.tenantLead!['name'] ?? "";
      phoneController.text = widget.tenantLead!['phone'] ?? "";
      salaryController.text = widget.tenantLead!['salary']?.toString() ?? "";
      noteController.text = widget.tenantLead!['description'] ?? "";
      hasSection8 = widget.tenantLead!['hasSection8'] ?? false;
      status = widget.tenantLead!['status'] ?? "Pending";
      if (widget.tenantLead!['availabilityDate'] != null) {
        availabilityDate = DateTime.tryParse(widget.tenantLead!['availabilityDate']);
      }
      selectedScheduleTime = widget.tenantLead!['scheduleTime'];
      _uploadedPhotoUrl = widget.tenantLead!['photoUrl'];
    }
    fetchScheduleTimes();
  }

  Future<void> fetchScheduleTimes() async {
    final snapshot = await scheduleRef.get();
    List<String> times = [];
    if (snapshot.exists) {
      final data = snapshot.value as Map<dynamic, dynamic>;
      data.forEach((key, value) {
        times.add(value.toString());
      });
    }
    setState(() {
      scheduleTimes = times;
      if (status == "Scheduled" && selectedScheduleTime == null && scheduleTimes.isNotEmpty) {
        selectedScheduleTime = scheduleTimes[0];
      }
    });
  }

  Future<List<PlatformFile>> pickFiles() async {
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      withData: true, // Ensures bytes are available on web
    );
    return result?.files ?? [];

  }



  /// Allow user to pick an image and upload it to Google Drive.
  Future<void> _uploadPicture() async {
    try {
    await driveManager.signIn();
    var tenantLead = await driveManager.findOrCreateFolderInSharedFolder("1wimM_M3dY1Ooz-KjMXD1hbdj0yq1ncp2", "Tenant Leads");
    var lastFourPhone = phoneController.text.length > 3 ?phoneController.text.substring(phoneController.text.length - 4) :"1111";
    var aTenant = await driveManager.findOrCreateFolderInSharedFolder(tenantLead,tenantNameController.text + "_"+lastFourPhone);

    File file = File("");
    if (kIsWeb) {
      List<PlatformFile> files = await pickFiles();

        PlatformFile aFile = (files != null && files.length >0) ? files.first : PlatformFile(name: "no file", size: 0);
        _uploadedPhotoUrl = await driveManager.uploadFileFromWeb(aTenant,aFile);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Files  Uploaded')),
      );

    }
    else {
      final ImagePicker _picker = ImagePicker();
      XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image == null) return; // Canceled.
      file = File(image.path);
      await driveManager.uploadFileFolder(aTenant,file);
    }






    } catch (e) {
      print("Error uploading image: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.tenantLead == null ? "New Tenant Lead" : "Edit Tenant Lead"),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                TextFormField(
                  controller: tenantNameController,
                  decoration: InputDecoration(
                    labelText: "Name",
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) => value == null || value.isEmpty ? "Please enter name" : null,
                ),
                SizedBox(height: 16),
                TextFormField(
                  controller: phoneController,
                  decoration: InputDecoration(
                    labelText: "Phone Number",
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.phone,
                  validator: (value) => value == null || value.isEmpty ? "Please enter phone number" : null,
                ),
                SizedBox(height: 16),
                TextFormField(
                  controller: salaryController,
                  decoration: InputDecoration(
                    labelText: "Salary",
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) => value == null || value.isEmpty ? "Please enter salary" : null,
                ),
                SizedBox(height: 16),
                SwitchListTile(
                  title: Text("Has Section 8"),
                  value: hasSection8,
                  onChanged: (value) {
                    setState(() {
                      hasSection8 = value;
                    });
                  },
                ),
                SizedBox(height: 16),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    "Availability Date: ${availabilityDate != null ? availabilityDate!.toLocal().toString().split(' ')[0] : 'Select Date'}",
                  ),
                  trailing: Icon(Icons.calendar_today),
                  onTap: () async {
                    final DateTime? picked = await showDatePicker(
                      context: context,
                      initialDate: availabilityDate ?? DateTime.now(),
                      firstDate: DateTime(2020),
                      lastDate: DateTime(2100),
                    );
                    if (picked != null) {
                      setState(() {
                        availabilityDate = picked;
                      });
                    }
                  },
                ),
                SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: status,
                  decoration: InputDecoration(
                    labelText: "Status",
                    border: OutlineInputBorder(),
                  ),
                  items: [
                    "Pending",
                    "Scheduled",
                    "Onboard",
                    "Tenant Accepted",
                    "Landlord Rejected",
                    "Tenant Rejected"
                  ]
                      .map((status) => DropdownMenuItem(
                    value: status,
                    child: Text(status),
                  ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      status = value!;
                      if (status == "Scheduled") {
                        fetchScheduleTimes();
                      }
                    });
                  },
                ),
                SizedBox(height: 16),
                // If Status is "Scheduled", show schedule time chips.
                if (status == "Scheduled" && scheduleTimes.isNotEmpty)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Select Schedule Time:",
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 8),
                      Wrap(
                        spacing: 8.0,
                        children: scheduleTimes.map((time) {
                          return ChoiceChip(
                            label: Text(time),
                            selected: selectedScheduleTime == time,
                            onSelected: (bool selected) {
                              setState(() {
                                selectedScheduleTime = selected ? time : null;
                              });
                            },
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                if (status == "Scheduled") SizedBox(height: 16),
                TextFormField(
                  controller: noteController,
                  decoration: InputDecoration(
                    labelText: "Description",
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
                SizedBox(height: 16),
                // Upload ID to Google Drive button.
                ElevatedButton.icon(
                  onPressed: _uploadPicture,
                  icon: Icon(Icons.upload_file),
                  label: Text("Upload ID to Google Drive"),
                ),
                if (_uploadedPhotoUrl != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Column(
                      children: [
                        Text("ID Uploaded:"),
                        SizedBox(height: 8),
                        Text(
                          _uploadedPhotoUrl!,
                          style: TextStyle(color: Colors.blue),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      Map<String, dynamic> tenantData = {
                        "name": tenantNameController.text,
                        "phone": phoneController.text,
                        "salary": salaryController.text,
                        "hasSection8": hasSection8,
                        "availabilityDate": availabilityDate != null ? availabilityDate!.toIso8601String() : null,
                        "status": status,
                        "scheduleTime": status == "Scheduled" ? selectedScheduleTime : null,
                        "description": noteController.text,
                        "photoUrl": _uploadedPhotoUrl,
                      };
                      if (widget.tenantLead == null) {
                        tenantData["createTimeStamp"] = DateTime.now().toIso8601String();
                        tenantData["updateTimeStamp"] = DateTime.now().toIso8601String();
                        await leadsRef.push().set(tenantData);
                      } else {
                        tenantData["createTimeStamp"] = widget.tenantLead!['createTimeStamp'] ?? DateTime.now().toIso8601String();
                        tenantData["updateTimeStamp"] = DateTime.now().toIso8601String();
                        await leadsRef.child(widget.tenantLead!['key']).update(tenantData);
                      }
                      Navigator.of(context).pop();
                    }
                  },
                  child: Text(widget.tenantLead == null ? "Save" : "Update"),
                ),
                SizedBox(height: 16),
                if (widget.tenantLead != null)
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(foregroundColor: Colors.red),
                    onPressed: () async {
                      await leadsRef.child(widget.tenantLead!['key']).remove();
                      Navigator.of(context).pop();
                    },
                    child: Text("Delete"),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
