import 'package:flutter/material.dart';
import 'package:milvertonrealty/propertysetup/controller/propertyUnitController.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '3-Way Toggle Button Example',
      home: PropertyView(),
    );
  }
}

class PropertyView extends StatefulWidget {
  @override
  _PropertyViewState createState() => _PropertyViewState();
}

class _PropertyViewState extends State<PropertyView> {
  // Property details for the summary card
  final String propertyName = "Milverton Realty Apartments";
  final String propertyAddress = "14315 Milverton Rd, Cleveland";
  bool isLoading = false;
  // Sample data for unit cards
  List<Map<String, dynamic>> cardData = [
  /*  {
      "unitName": "Unit A101",
      "isVacant": false,
      "leaseStartDate": DateTime(2023, 5, 1),
      "leaseEndDate": DateTime(2024, 5, 1),
      "bedrooms": 2,
      "bathrooms": 1,
      "squareFeet": 750,
    },
    {
      "unitName": "Unit B202",
      "isVacant": true,
      "bedrooms": 3,
      "bathrooms": 2,
      "squareFeet": 1200,
    },
    {
      "unitName": "Unit C303",
      "isVacant": false,
      "leaseStartDate": DateTime(2023, 6, 15),
      "leaseEndDate": DateTime(2024, 6, 15),
      "bedrooms": 4,
      "bathrooms": 3,
      "squareFeet": 1500,
    },*/
  ];

  @override
  void initState() {

    super.initState();
    fetchProperty();

  }
  Future<void> fetchProperty()async{
    try{
      setState(() {
        isLoading = true;
      });
      var controller = Provider.of<PropertySetupController>(context, listen: false);
      controller.getProperty();
      setState(() {
        cardData = controller.unitData;
        isLoading = false;
      });
    }
    catch(error) {
      setState(() {
        print(error);
        isLoading = false;
      });
    }
  }
  //List<Map<String, dynamic>> sortedCardData = List.from(cardData)
  // ..sort((a, b) => a['unitName'].compareTo(b['unitName']));
  // Current filter state: "All" by default
  String selectedFilter = "All";

  @override
  Widget build(BuildContext context) {
    // Filter the card data based on the selected filter
    List<Map<String, dynamic>> filteredData = cardData;
    if (selectedFilter == "Vacant") {
      filteredData = cardData.where((unit) => unit['isVacant'] == true).toList();
    } else if (selectedFilter == "Occupied") {
      filteredData = cardData.where((unit) => unit['isVacant'] == false).toList();
    }

    return Scaffold(
      appBar: AppBar(
        title: Text("Property Page"),
      ),
      body: Column(
        children: [
          // Summary Card
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: isLoading ?  CircularProgressIndicator() : Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.0),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Property Name
                    Text(
                      propertyName,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.blueAccent,
                      ),
                    ),
                    SizedBox(height: 8),
                    // Property Address
                    Text(
                      propertyAddress,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(height: 16),
                    // Vacant and Occupied Units
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.apartment, color: Colors.green),
                            SizedBox(width: 8),
                            Text(
                              "Occupied Units: ${cardData.where((unit) => !unit['isVacant']).length}",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Icon(Icons.meeting_room, color: Colors.red),
                            SizedBox(width: 8),
                            Text(
                              "Vacant Units: ${cardData.where((unit) => unit['isVacant']).length}",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Toggle Button Row
          // Toggle Button Row
          Padding(
            padding: const EdgeInsets.fromLTRB(0,8,0,8),
            child: Row(
              children: [
                Expanded(
                  child: ToggleButton(
                    label: "All",
                    isSelected: selectedFilter == "All",
                    onTap: () {
                      setState(() {
                        selectedFilter = "All";
                      });
                    },
                  ),
                ),
                Expanded(
                  child: ToggleButton(
                    label: "Vacant",
                    isSelected: selectedFilter == "Vacant",
                    onTap: () {
                      setState(() {
                        selectedFilter = "Vacant";
                      });
                    },
                  ),
                ),
                Expanded(
                  child: ToggleButton(
                    label: "Occupied",
                    isSelected: selectedFilter == "Occupied",
                    onTap: () {
                      setState(() {
                        selectedFilter = "Occupied";
                      });
                    },
                  ),
                ),
              ],
            ),
          ),


          // Filtered List of Units
          Expanded(
            child: ListView.builder(
              itemCount: filteredData.length,
              itemBuilder: (context, index) {
                final cardItem = filteredData[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                  child: Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Unit Name
                          Text(
                            cardItem['name'],
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.blueAccent,
                            ),
                          ),
                          SizedBox(height: 8),
                          // Bedrooms, Bathrooms, and Square Feet
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.bed, size: 16, color: Colors.grey[700]),
                                  SizedBox(width: 4),
                                  Text(
                                    "${cardItem['bedrooms']} Beds",
                                    style: TextStyle(fontSize: 14, color: Colors.grey[900]),
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  Icon(Icons.bathtub, size: 16, color: Colors.grey[700]),
                                  SizedBox(width: 4),
                                  Text(
                                    "${cardItem['bathrooms']} Baths",
                                    style: TextStyle(fontSize: 14, color: Colors.grey[900]),
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  Icon(Icons.square_foot, size: 16, color: Colors.grey[700]),
                                  SizedBox(width: 4),
                                  Text(
                                    "${cardItem['livingSpace']} sq ft",
                                    style: TextStyle(fontSize: 14, color: Colors.grey[900]),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          SizedBox(height: 8),
                          // Lease Info or Vacancy Status
                          if (cardItem['isVacant'] == false) ...[
                            Text(
                              "Lease: Monthly",
                              style: TextStyle(fontSize: 14, color: Colors.black87),
                            ),
                          ] else ...[
                            Text(
                              "Vacant",
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.orange,
                              ),
                            ),
                          ],
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
    );
  }

  // Helper to format DateTime
  String formatDate(DateTime date) {
    return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
  }
}



class ToggleButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const ToggleButton({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 4.0),
        padding: EdgeInsets.symmetric(vertical: 8.0),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blueAccent : Colors.grey[200],
          borderRadius: BorderRadius.circular(8.0),
          border: Border.all(
            color: isSelected ? Colors.blueAccent : Colors.grey,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: isSelected ? Colors.white : Colors.black,
            ),
          ),
        ),
      ),
    );
  }
}
