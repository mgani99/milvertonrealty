
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:milvertonrealty/auth/controller/auth_provider.dart';
import 'package:milvertonrealty/common/domain/user.dart';
import 'package:milvertonrealty/home/controller/app_data.dart';
import 'package:milvertonrealty/propertysetup/controller/propertyUnitController.dart';
import 'package:milvertonrealty/user/view/new_user.dart';
import 'package:milvertonrealty/utils/constants.dart';
import 'package:provider/provider.dart';
import 'package:milvertonrealty/issue_importer.dart';

import '../../common/service.dart';
import '../../repair/model/repair_model.dart';
import '../../utils/google_spreadsheet_service.dart';

class DashBoardPage extends StatefulWidget {
  const DashBoardPage({super.key});

  @override
  State<DashBoardPage> createState() => _DashBoardPageState();
}

class _DashBoardPageState extends State<DashBoardPage>
    with TickerProviderStateMixin {

  bool _isSearching = false;


  final DatabaseReference _ref = MR_DBService().getDBRef("water_usage");
  Map<String, dynamic> _usageData = {};
  @override
  void initState() {
    //final appData =     Provider.of<AppData>(context, listen: true);
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


  DateTime parseDate(String dateStr) {
    final parts = dateStr.split("-");
    final month = int.parse(parts[0]);
    final day = int.parse(parts[1]);
    final year = int.parse(parts[2]);
    return DateTime(year, month, day);
  }

  String formatDate(DateTime date) {
    return "${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}-${date.year}";
  }
  @override
  Widget build(BuildContext context) {
    double totalUsage = 0.0;
    double avgUsg = 0.0;
    int count = 0;
    double latestUsage= 0.0;
    DateTime? latestDate;
    String latestDateStr = "";
    if (_usageData != null && _usageData.length > 0) {

      for (var entry in _usageData.entries) {
        final dateStr =entry.key;
        final usageStr = entry.value["usage"];
        if (usageStr != null) {
          try {
            final usageValue = double.parse(usageStr.split(" ")[0]);
            totalUsage += usageValue;
            count ++;

            final currentDate = parseDate(dateStr);
            if (latestDate == null || currentDate.isAfter(latestDate)) {
              latestDate = currentDate;
              latestUsage = usageValue;
              latestDateStr = dateStr;
            }


          }
          catch(e) {
            print(e);
          }
        }
      }
      if (totalUsage > 0) {
        setState(() {
          avgUsg = totalUsage/count;
          latestUsage;
          latestDateStr;
        });

      }
    }
    final appData =     Provider.of<AppData>(context, listen: true);


    return Scaffold(
      //ackgroundColor: ColorConstants.primaryWhiteColor,
      appBar: AppBar(
        title: Text(
          'Milverton Realty',
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.grey,
        actions: [
          AnimatedContainer(
            duration: Duration(milliseconds: 300),
            width: _isSearching ? 200.0 : 0.0,
            child: _isSearching
                ? TextField(
              autofocus: true,
              style: TextStyle(color: Colors.black),
              decoration: InputDecoration(
                hintText: 'Search...',
                hintStyle: TextStyle(color: Colors.black),
                border: InputBorder.none,
              ),
            )
                : null,
          ),
          IconButton(
            icon: Icon(
              _isSearching ? Icons.close : Icons.search,
              color: Colors.white,
            ),
            onPressed: () {
              setState(() {
                _isSearching = !_isSearching;
              });
            },
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              // Add menu functionality here
            },
            itemBuilder: (BuildContext context) {
              return {'Option 1', 'Option 2', 'Option 3'}
                  .map((String choice) {
                return PopupMenuItem<String>(
                  value: choice,
                  child: Text(choice),
                );
              }).toList();
            },
          ),
        ],
        automaticallyImplyLeading: true,
        //backgroundColor: ColorConstants.primaryWhiteColor,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(
                height: 10,
              ),
              Padding(
                padding: EdgeInsets.symmetric(
                    horizontal: MediaQuery.sizeOf(context).width * 11 / 100),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    (appData.currentUserName!.isEmpty) ? TextButton(
                        onPressed: (){ Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>  const NewUserPage()));},
                        child: Text("Click here to Setup User Profile", style: TextStyle(color: Colors.red))) :
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Welcome ${appData.currentUserName}",
                            style: TextStyleConstants.homeMainTitle1,
                          ),
                          (appData.settings['role'].toString().toLowerCase() == 'tenant') ? Text("Unit Number ${appData.settings['unitName']}") : Container(),
                         (appData.settings['role'].toString().toLowerCase() == 'owner') ? Text("\nWater Usage: \n ${latestDateStr} -  ${latestUsage} Gal \n  ${count} Day Avg -  ${avgUsg.toStringAsFixed(0)} Gal/day", style:
                            TextStyle(fontSize: 20, color: Colors.redAccent ),) : Container(),

                        ],

                      ),

                    ),

                   //Request Access to Apartment or Create Portfolio
                    //Text(propertyUnitController.unitData.length.toString() as String),
                    //(usr.userType == "Owner") ?

                  ],
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              // ElevatedButton(
              //   onPressed: _loadAndPrintRows,
              //   child: const Text('Fetch & Print Google Sheet Rows'),
              // ),
            ],

          ),

        ),
      ),
    );
  }

  @override
  void dispose() {

    super.dispose();
  }




  final _sheetsService = GoogleSheetsService();
  bool _loading = false;

  Future<void> _loadAndPrintRows() async {
    setState(() => _loading = true);

    try {
      // 1) (Optional) Find the spreadsheet by its filename

      final spreadsheetId = "1NXFvmvYRh7Mw00gbNiA1TF2X21d7cVieeqX3Nj8fWzw";

      // 2) Read everything from Sheet1 (columns A–Z)
      final rows =
      await _sheetsService.readSheetValues(spreadsheetId, 'Work Orders 2025!A1:K115');
      if (rows == null || rows.isEmpty) {
        print('No data in sheet');
      } else {
        // 3) Print each row
        for (final row in rows) {
          print(row.map((c) => c ?? '').join(' | '));
        }
        importCSV(rows, MR_DBService().getDBRef(Issue.categoryRoot));


      }
    } catch (e, st) {
      print('Error fetching sheet: $e\n$st');
    } finally {
      setState(() => _loading = false);
    }
  }

}
