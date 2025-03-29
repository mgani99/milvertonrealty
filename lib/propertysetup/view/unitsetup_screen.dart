import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:milvertonrealty/propertysetup/controller/propertyUnitController.dart';
import 'package:milvertonrealty/route/route_constants.dart';
import 'package:milvertonrealty/user/components/text_box.dart';
import 'package:provider/provider.dart';


class UnitSetupScreen extends StatefulWidget {
  @override
  State<UnitSetupScreen> createState() => _UnitSetupScreenState();
}

class _UnitSetupScreenState extends State<UnitSetupScreen> {
  bool isEditing = false;



  final Map<String, List<File>> uploadedImages = {
    "Bedroom": [],
    "Bathroom": [],
    "Kitchen": [],
  };

  Future<void> pickImages(String category) async {
    final picker = ImagePicker();
    final List<XFile>? pickedFiles = await picker.pickMultiImage();

    if (pickedFiles != null) {
      setState(() {
        uploadedImages[category]!.addAll(pickedFiles.map((file) => File(file.path)));
      });
    }
  }



  @override
  Widget build(BuildContext context) {
    final controller =     Provider.of<PropertySetupController>(context, listen: true);
    return DefaultTabController(
      length: 5,
      child: Scaffold(
        // Decorated AppBar
        appBar: AppBar(
          backgroundColor: Colors.grey,
          title: Text(
            "Apartment Unit Details",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
          //centerTitle: true,
          elevation: 4,
        ),
        body: Column(
          children: [
            // Top section with unit details and configuration icon
            Padding(
              padding: const EdgeInsets.fromLTRB(4,12,12,12),
              child: Stack(
                children: [
                  // Unit Details Card
                  Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    elevation: 4,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Unit Details - A1",
                            style: TextStyle(
                              fontSize: 18, color: Colors.black,
                              //fontWeight: FontWeight.bold,
                            ),
                          ),

                          SizedBox(height: 14),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.bed, color: Colors.grey),
                                  SizedBox(width: 8),
                                  Text(
                                    "Bedrooms: ",
                                    style: TextStyle(fontSize: 16, height: 1.5, color: Colors.grey[700]),
                                  ),
                                ],

                              ),
                              isEditing ?  SizedBox(
                                width: 90,
                                height: 40,
                                child: IncrementDecrementTextBox(
                                  initialValue: 1,
                                  onChanged: (value) {
                                   // _updateUnitCount(value);
                                    controller.bedroomController.text = value.toString();
                                    print("Current value: $value");
                                  },
                                )
                              )

                                  :Text(
                                controller.bedroomController.text,
                                style: TextStyle(fontSize: 16, height: 1.5, color: Colors.black),
                              ),


                            ],
                          ),
                          Divider(thickness: .75,),
                          SizedBox(height: 14),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Icon(Icons.bathtub, color: Colors.grey),
                                  SizedBox(width: 8),
                                  Text(
                                    "Bathrooms: ",
                                    style: TextStyle(fontSize: 16, height: 1.5, color: Colors.grey[700]),
                                  ),

                                ],
                              ),


                              isEditing ?  SizedBox(
                                width: 90,
                                height: 40,
                                child: IncrementDecrementTextBox(
                                  initialValue: 1,
                                  onChanged: (value) {
                                    controller.bathroomController.text = value.toString();
                                    print("Current value: $value");
                                  },
                                ),
                              )


                                  :Text(
                                controller.bathroomController.text,
                                style: TextStyle(fontSize: 16, height: 1.5, color: Colors.black),
                              ),

                            ],
                          ),
                          Divider(thickness: .75,),
                          SizedBox(height: 14),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Icon(Icons.square_foot, color: Colors.grey),
                                  SizedBox(width: 8),
                                  Text(
                                    "Living Space: ",
                                    style: TextStyle(fontSize: 16, height: 1.5, color: Colors.grey[700]),
                                  ),
                                ],
                              ),
                              isEditing ?  SizedBox(
                                height: 40,
                                width: 90,
                                child: IncrementDecrementTextBox(
                                  initialValue: 500,
                                  onChanged: (value) {
                                    //_updateUnitCount(value);
                                    controller.sqrFeetController.text = value.toString();
                                    print("Current value: $value");
                                  },
                                )
                              )

                                  :Text(
                                "${controller.sqrFeetController.text} sqr ft" ,
                                style: TextStyle(fontSize: 16, height: 1.5, color: Colors.black),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Configuration Icon
                  Positioned(
                    top: 8,
                    right: 8,
                    child: IconButton(
                      icon: Icon(isEditing? Icons.save : Icons.settings, color: isEditing? Colors.blue : Colors.grey),
                      onPressed: () {
                        // Add configuration functionality here
                        setState(() {
                          isEditing = !isEditing;

                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content: Text("Configuration settings clicked!")),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            // Tab bar below the unit details
            TabBar(
              isScrollable: true,
              tabs: [
                Tab(icon: Icon(Icons.description), text: "Lease Details"),
                Tab(icon: Icon(Icons.inventory), text: "Inventory"),
                Tab(icon: Icon(Icons.photo), text: "Picture"),
                Tab(icon: Icon(Icons.payment), text: "Payments"),
                Tab(icon: Icon(Icons.person), text: "Tenant"),
              ],
            ),
            // Expanded section for tab views
            Expanded(
              child: TabBarView(
                children: [
                  // Lease Details Tab
                  Padding(
                    padding: EdgeInsets.all(4),
                    child: Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      elevation: 4,
                      child: Padding(
                        padding: EdgeInsets.all(4),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Lease Details",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text("Tenant Name",
                                    style: TextStyle(fontSize: 16)),
                                Text(" John Doe",
                                    style: TextStyle(fontSize: 16)),
                              ],
                            ),
                            Divider(
                              thickness: 0.5,
                            ),
                            Text("Rent: \$1200/month",
                                style: TextStyle(fontSize: 16)),
                            Text(
                              "Security Deposit: \$2400",
                              style: TextStyle(fontSize: 16),
                            ),
                            Text(
                              "Lease Start Date: 01/01/2025",
                              style: TextStyle(fontSize: 16),
                            ),
                            Text("Lease End Date: 12/31/2025",
                                style: TextStyle(fontSize: 16)),
                          ],
                        ),
                      ),
                    ),
                  ),
                  // Inventory Tab
                  Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      children: [
                        CheckboxListTile(
                          title: Text("Refrigerator"),
                          value: true,
                          onChanged: (value) {},
                        ),
                        CheckboxListTile(
                          title: Text("Stove"),
                          value: false,
                          onChanged: (value) {},
                        ),
                        CheckboxListTile(
                          title: Text("Microwave"),
                          value: true,
                          onChanged: (value) {},
                        ),
                        CheckboxListTile(
                          title: Text("Dish Washer"),
                          value: false,
                          onChanged: (value) {},
                        ),
                      ],
                    ),
                  ),
                  // Picture Tab
                  // GridView.builder(
                  //   gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  //     crossAxisCount: 1,
                  //     childAspectRatio: 3, // Larger rows
                  //   ),
                  //   itemCount: uploadedImages.length,
                  //   itemBuilder: (context, index) {
                  //     String category = uploadedImages.keys.elementAt(index);
                  //     return Card(
                  //       margin: EdgeInsets.all(10),
                  //       child: Stack(
                  //         children: [
                  //           Column(
                  //             crossAxisAlignment: CrossAxisAlignment.start,
                  //             children: [
                  //               Padding(
                  //                 padding: const EdgeInsets.all(8.0),
                  //                 child: Text(
                  //                   category,
                  //                   style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  //                 ),
                  //               ),
                  //               Container(
                  //                 height: 75,
                  //                 child: ListView.builder(
                  //                   scrollDirection: Axis.horizontal,
                  //                   itemCount: uploadedImages[category]!.length,
                  //                   itemBuilder: (context, imageIndex) {
                  //                     return Padding(
                  //                       padding: const EdgeInsets.all(8.0),
                  //                       child: Image.file(
                  //                         uploadedImages[category]![imageIndex],
                  //                         fit: BoxFit.cover,
                  //                         width: 100,
                  //                         height: 100,
                  //                       ),
                  //                     );
                  //                   },
                  //                 ),
                  //               ),
                  //             ],
                  //           ),
                  //           Positioned(
                  //             top: 2,
                  //             right: 40,
                  //             child: IconButton(
                  //               icon: Icon(Icons.upload_file),
                  //               tooltip: "Upload Images",
                  //               onPressed: () => pickImages(category),
                  //             ),
                  //           ),
                  //           Positioned(
                  //             top: 2,
                  //             right: 2,
                  //             child: IconButton(
                  //               icon: Icon(Icons.save),
                  //               tooltip: "Save Images",
                  //               onPressed: uploadToGoogleDrive,
                  //             ),
                  //           ),
                  //         ],
                  //       ),
                  //     );
                  //   },
                  // ),
                  Card(child: ElevatedButton(onPressed: (){Navigator.pushNamed(context, unitPictureScreenRoute);},
                      child: Text("Upload Pictures"))),

                  // Payments Tab
                  ListView(
                    children: [
                      Card(
                        child: ListTile(
                          title: Text("Payment 1"),
                          subtitle: Text("\$1200 - 01/01/2025"),
                        ),
                      ),
                      Card(
                        child: ListTile(
                          title: Text("Payment 2"),
                          subtitle: Text("\$1200 - 01/02/2025"),
                        ),
                      ),
                    ],
                  ),
                  // Tenant Tab
                  Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Name: John Doe", style: TextStyle(fontSize: 16)),
                        Text("Number of Occupants: 3",
                            style: TextStyle(fontSize: 16)),
                        Text("Phone Number: (123) 456-7890",
                            style: TextStyle(fontSize: 16)),
                        Text("Email Address: john.doe@example.com",
                            style: TextStyle(fontSize: 16)),
                        Text("Bank Account: 123456789",
                            style: TextStyle(fontSize: 16)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  Widget _buildInputField(String label, TextEditingController controller, double screenWidth,
      String? Function(String?) validator,
      {List<TextInputFormatter>? formatters}) {
    return Container(
      width: screenWidth * 0.8, // 80% of the screen width
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey, width: 2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: TextFormField(
          controller: controller,
          decoration: InputDecoration(
            border: InputBorder.none,
            labelText: label,
          ),
          validator: validator,
          inputFormatters: formatters,
        ),
      ),
    );
  }

}


void main() => runApp(MaterialApp(home: UnitSetupScreen()));
