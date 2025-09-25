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
  final Map<String, dynamic> propertyData;

  //PropertyDetails({super.key, required this.propertyData});
  const UnitSetupScreen({super.key, required this.propertyData});
  @override
  State<UnitSetupScreen> createState() => _UnitSetupScreenState();
}

class _UnitSetupScreenState extends State<UnitSetupScreen> {
  bool isEditing = false;
  bool isLeaseDtlsEditing = false;
  bool isTenantEditing = false;
  late PropertySetupController controller;
  final _formKey = GlobalKey<FormState>();


  @override
  void didChangeDependencies () {
    super.didChangeDependencies();
    controller =     Provider.of<PropertySetupController>(context, listen: false);
    controller.bedroomController.text = widget.propertyData['bedrooms'].toString();
    controller.bathroomController.text = widget.propertyData['bathrooms'].toString();
    controller.sqrFeetController.text = widget.propertyData['livingSpace'].toString();
    controller.tenantNameController.text = widget.propertyData['name'].toString();
    controller.phoneNumberController.text = widget.propertyData['phoneNumber']??"";
    controller.workPhoneNumberController.text = widget.propertyData['workPhoneNumber']??"";
    controller.emailController.text = widget.propertyData['email']??"";
    ;

    controller.refrigeratorIsChecked = widget.propertyData['hasRefrigerator'];
    controller.microwaveIsChecked = widget.propertyData['hasMicrowave'];
    controller.dishWasherIsChecked = widget.propertyData['hasDishwasher'];
    controller.stoveIsChecked = widget.propertyData['hasStove'];

    controller.rentController.text = widget.propertyData['rent'].toString();
    controller.securityDepositController.text = widget.propertyData['securityDeposit'].toString();

    controller.isVacant = widget.propertyData['isVacant'];



  }


  final Map<String, List<File>> uploadedImages = {
    "Bedroom": [],
    "Bathroom": [],
    "Kitchen": [],
  };

  bool isInventoryEditing = false;

  bool isVacant = false;

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
    controller =     Provider.of<PropertySetupController>(context, listen: false);

    return DefaultTabController(
      length: 6,
      child: Scaffold(
        resizeToAvoidBottomInset: false,
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

        body: SafeArea(
          child: Column(
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
                              "Unit Details - ${widget.propertyData['unitName']}",
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
                                      "Bedrooms:",
                                      style: TextStyle(fontSize: 16, height: 1.5, color: Colors.grey[700]),
                                    ),
                                  ],

                                ),
                                isEditing ?  SizedBox(
                                  width: 90,
                                  height: 40,
                                  child: IncrementDecrementTextBox(
                                    initialValue: int.parse(controller.bedroomController.text),
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
                                    initialValue: 0,
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
                                    initialValue: int.parse(controller.sqrFeetController.text),
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
                      top: 4,
                      right: 4,
                      child: IconButton(
                        icon: Icon(isEditing? Icons.save : Icons.settings, color: isEditing? Colors.blue : Colors.grey),
                        onPressed: () {
                          // Add configuration functionality here
                          setState(() {
                            if (isEditing) {
                              controller.saveUnitDetails(widget.propertyData);
                            }
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
                  Tab(icon: Icon(Icons.note), text: "Note"),
                ],
              ),
              // Expanded section for tab views
              Expanded(
                child: TabBarView(
                  children: [
                    // Lease Details Tab
                    Padding(
                      padding: EdgeInsets.all(4),
                      child: Stack(
                        children: [
                          Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            elevation: 4,
                            child: Padding(
                              padding: EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        "Lease Details",
                                        style: TextStyle(
                                          fontSize: 18,
                                          color: Colors.black,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      // SizedBox(width: 5,),
                                      // SizedBox(width: 70,height: 30,
                                      //   child: ToggleButtonWidget(isVacant:controller.isVacant
                                      //
                                      //   ),
                                      // ),
                                    ],
                                  ),
                                  SizedBox(height: 15),
                                     SizedBox(
                                       height: 50,width: double.infinity,
                                       child: CheckboxListTile(
                                        title: Text("Vacant", style:  TextStyle(fontSize: 16, color: Colors.grey[700])),
                                         contentPadding: EdgeInsets.symmetric(horizontal: 0),
                                        value: controller.isVacant,
                                        onChanged: (bool? newValue) {
                                          setState(() {
                                            if (isLeaseDtlsEditing) controller.isVacant = newValue ?? false; // Update the value when clicked.
                                          });
                                        },

                                                                       ),
                                   ),
                                  SizedBox(height: 10,),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text("Tenant Name",
                                          style: TextStyle(fontSize: 16)),
                                      (isLeaseDtlsEditing && !controller.isVacant)
                                          ? SizedBox(
                                        width: 150,height: 50,
                                        child: TextField(
                                          textAlign: TextAlign.right,
                                          controller: controller.tenantNameController,
                                          decoration: InputDecoration(
                                            filled: true,
                                            fillColor: Colors.grey[20],
                                            border: OutlineInputBorder(),
                                          ),
                                        ),
                                      )
                                          :
                                      Text("${widget.propertyData['tenantName']}",
                                        style: TextStyle(fontSize: 16, height: 1.5, color: Colors.black)),
                                    ],
                                  ),
                                  Divider(
                                    thickness: 0.5,
                                  ),
                                  SizedBox(height: 12),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text("Rent",
                                          style: TextStyle(fontSize: 16)),
                                      (isLeaseDtlsEditing && !controller.isVacant)
                                          ? SizedBox(
                                            width: 150,height: 40,
                                            child: TextField(
                                              textAlign: TextAlign.right,
                                              controller: controller.rentController,
                                                                                  decoration: InputDecoration(
                                            filled: true,
                                            fillColor: Colors.grey[20],
                                            border: OutlineInputBorder(),
                                                                                  ),
                                                                                ),
                                          )
                                          :Text("${widget.propertyData['rent']}",
                                          style: TextStyle(fontSize: 16, height: 1.5, color: Colors.black)),
                                    ],
                                  ),
                                  Divider(
                                    thickness: 0.5,
                                  ),
                                  SizedBox(height: 12),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text("Security Deposit",
                                          style: TextStyle(fontSize: 16)),
                                      (isLeaseDtlsEditing && !controller.isVacant)
                                          ? SizedBox(
                                        width: 150,height: 40,
                                        child: TextField(
                                          textAlign: TextAlign.right,
                                          controller: controller.securityDepositController,
                                          decoration: InputDecoration(
                                            filled: true,
                                            fillColor: Colors.grey[20],
                                            border: OutlineInputBorder(),
                                          ),
                                        ),
                                      )
                                          :Text("${widget.propertyData['securityDeposit']}",
                                          style: TextStyle(fontSize: 16, height: 1.5, color: Colors.black)),
                                    ],
                                  ),

                                  Divider(
                                    thickness: 0.5,
                                  ),
                                  SizedBox(height: 12),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text("Lease Start",
                                          style: TextStyle(fontSize: 16)),
                                      isLeaseDtlsEditing
                                          ? SizedBox(
                                        width: 150,height: 40,
                                        child: TextField(
                                          textAlign: TextAlign.right,

                                          controller: controller.leaseStartDateController,
                                          decoration: InputDecoration(
                                            hintText: "MM/dd/YYYY",
                                            filled: true,
                                            fillColor: Colors.grey[20],
                                            border: OutlineInputBorder(),
                                          ),
                                        ),
                                      )
                                          :Text("${widget.propertyData['startDate']}",
                                          style: TextStyle(fontSize: 16, height: 1.5, color: Colors.black)),
                                    ],
                                  ),

                                  Divider(
                                    thickness: 0.5,
                                  ),
                                  SizedBox(height: 12),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text("Lease End",
                                          style: TextStyle(fontSize: 16)),
                                      isLeaseDtlsEditing
                                          ? SizedBox(
                                        width: 150,height: 40,
                                        child: TextField(
                                          textAlign: TextAlign.right,
                                          controller: controller.leaseEndDateController,
                                          decoration: InputDecoration(
                                            filled: true,
                                            hintText: "MM-dd-YYYY",
                                            fillColor: Colors.grey[20],
                                            border: OutlineInputBorder(),
                                          ),
                                        ),
                                      )
                                          :Text("${widget.propertyData['endDate']}",
                                          style: TextStyle(fontSize: 16, height: 1.5, color: Colors.black)),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                          // Configuration Icon
                          Positioned(
                            top: 4,
                            right: 10,
                            child: IconButton(
                              icon: Icon(isLeaseDtlsEditing? Icons.save : Icons.settings, color: isLeaseDtlsEditing? Colors.blue : Colors.grey),
                              onPressed: () {
                                // Add configuration functionality here
                                setState(() {
                                  if (isLeaseDtlsEditing) {
                                    controller.saveLeaseDetails(widget.propertyData);
                                    //_showPopupForm(context);
                                  }
                                  isLeaseDtlsEditing = !isLeaseDtlsEditing;


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
                    // Inventory Tab
                    Padding(
                      padding: EdgeInsets.all(8),
                      child: Card(

                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          elevation: 4,
                        child: Stack(
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(height: 8,width: 8,),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    "Inventory ",
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black
                                    ),
                                  ),
                                ),
                                SizedBox(height: 30,),
                                CheckboxListTile(
                                  title: Text("Refrigerator"),
                                  value: controller.refrigeratorIsChecked,
                                  onChanged: (bool? newValue) {
                                    setState(() {
                                      if (isInventoryEditing) controller.refrigeratorIsChecked = newValue ?? false; // Update the value when clicked.
                                    });
                                  },

                                ),
                                CheckboxListTile(
                                  title: Text("Stove"),
                                  value: controller.stoveIsChecked,
                                  onChanged: (bool? newValue) {
                                    setState(() {
                                      if (isInventoryEditing) controller.stoveIsChecked = newValue ?? false; // Update the value when clicked.
                                    });
                                  },

                                ),
                                CheckboxListTile(
                                  title: Text("Microwave"),
                                  value: controller.microwaveIsChecked,
                                  onChanged: (bool? newValue) {
                                    setState(() {
                                      if (isInventoryEditing) controller.microwaveIsChecked = newValue ?? false; // Update the value when clicked.
                                    });
                                  },
                                ),
                                CheckboxListTile(
                                  title: Text("Dish Washer"),
                                  value: controller.dishWasherIsChecked,
                                    onChanged: (bool? newValue) {
                                      setState(() {
                                        if (isInventoryEditing) controller.dishWasherIsChecked = newValue ?? false; // Update the value when clicked.
                                      });
                                    },
                                ),
                              ],
                            ),
                            Positioned(
                              top: 2,
                              right: 2,
                              child: IconButton(
                                icon: Icon(isInventoryEditing? Icons.save : Icons.settings, color: isInventoryEditing? Colors.blue : Colors.grey),
                                onPressed: () {
                                  // Add configuration functionality here
                                  setState(() {
                                    if (isInventoryEditing) {
                                      controller.saveInventory(widget.propertyData);
                                    }
                                    isInventoryEditing = !isInventoryEditing;


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
                    /*Card(child: SizedBox(width: 120,height: 50,
                      child: ElevatedButton(onPressed: (){Navigator.pushNamed(context, unitPictureScreenRoute);},
                          child: Text("Upload Pictures")),
                    )),*/

                    Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: SizedBox(
                          width: 120,
                          height: 150,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              ElevatedButton(
                                onPressed: () {
                                  Navigator.pushNamed(context, unitPictureScreenRoute,
                                      arguments: widget.propertyData);
                                  // Add your button action here
                                  print('Upload Pictures');
                                },
                                child: Text('Upload Pictures'),
                              ),
                            ],
                          ),
                        ),
                      )),
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
                    Stack(
                      children:[

                      Padding(
                        padding: EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: 46,),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text("Tenant Name",
                                    style: TextStyle(fontSize: 16)),
                                (isTenantEditing)
                                    ? SizedBox(
                                  width: 170,height: 50,
                                  child: TextField(
                                    textAlign: TextAlign.right,
                                    controller: controller.tenantNameController,
                                    decoration: InputDecoration(
                                      filled: true,
                                      fillColor: Colors.grey[20],
                                      border: OutlineInputBorder(),
                                    ),
                                  ),
                                )
                                    :
                                Text("${widget.propertyData['tenantName']}",
                                    style: TextStyle(fontSize: 16, height: 1.5, color: Colors.black)),
                              ],
                            ),
                            Divider(
                              thickness: 0.5,
                            ),
                            SizedBox(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text("Phone(mobile)",
                                    style: TextStyle(fontSize: 16)),
                                (isTenantEditing)
                                    ? SizedBox(
                                  width: 170,height: 48,
                                  child: TextField(
                                    textAlign: TextAlign.right,
                                    controller: controller.phoneNumberController,
                                    decoration: InputDecoration(
                                      filled: true,
                                      fillColor: Colors.grey[20],
                                      border: OutlineInputBorder(),
                                    ),
                                  ),
                                )
                                    :
                                Text("${widget.propertyData['phoneNumber']}",
                                    style: TextStyle(fontSize: 16, height: 1.5, color: Colors.black)),
                              ],
                            ),
                            Divider(
                              thickness: 0.5,
                            ),
                            SizedBox(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text("Phone(Work)",
                                    style: TextStyle(fontSize: 16)),
                                (isTenantEditing)
                                    ? SizedBox(
                                  width: 170,height: 48,
                                  child: TextField(
                                    textAlign: TextAlign.right,
                                    controller: controller.workPhoneNumberController,
                                    decoration: InputDecoration(
                                      filled: true,
                                      fillColor: Colors.grey[20],
                                      border: OutlineInputBorder(),
                                    ),
                                  ),
                                )
                                    :
                                Text("${widget.propertyData['workPhoneNumber']}",
                                    style: TextStyle(fontSize: 16, height: 1.5, color: Colors.black)),
                              ],
                            ),
                            Divider(
                              thickness: 0.5,
                            ),
                            SizedBox(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text("E-Mail",
                                    style: TextStyle(fontSize: 16)),
                                (isTenantEditing)
                                    ? SizedBox(
                                  width: 170,height: 50,
                                  child: TextField(
                                    textAlign: TextAlign.right,
                                    controller: controller.emailController,
                                    decoration: InputDecoration(
                                      filled: true,
                                      fillColor: Colors.grey[20],
                                      border: OutlineInputBorder(),
                                    ),
                                  ),
                                )
                                    :
                                Text("${widget.propertyData['email']}",
                                    style: TextStyle(fontSize: 16, height: 1.5, color: Colors.black)),
                              ],
                            ),
                            Divider(
                              thickness: 0.5,
                            ),
                            Padding(
                                padding: const EdgeInsets.all(4.0),
                                child: Container(
                                  height: 110, // Extend text box height for multi-line input
                                  child: TextField(
                                    controller: controller.tenantNotesController,
                                    maxLines: null, // Allows multiple lines
                                    expands: true, // Makes the TextField expand within the container
                                    keyboardType: TextInputType.multiline,
                                    textAlignVertical: TextAlignVertical.top,
                                    decoration: InputDecoration(
                                      border: OutlineInputBorder(),
                                      hintText: "Tenant note here.",
                                    ),
                                  ),
                                )
                            )

                          ],
                        ),
                      ),
                        Positioned(
                          top: 2,
                          right: 2,
                          child: IconButton(
                            icon: Icon(isTenantEditing? Icons.save : Icons.settings, color: isTenantEditing? Colors.blue : Colors.grey),
                            onPressed: () {
                              // Add configuration functionality here
                              setState(() {
                                if (isTenantEditing) {
                                  controller.saveTenant(widget.propertyData,context);
                                }
                                isTenantEditing = !isTenantEditing;


                              });
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                    content: Text("Configuration settings clicked!")),
                              );
                            },
                          ),
                        ),
                        Positioned(
                          top: 2,
                          right: 32,
                          child: IconButton(
                            icon: Icon(Icons.contact_page_sharp),
                            onPressed: () {
                              // Add configuration functionality here
                              setState(() {
                                controller.addTenantIntoPhone(controller.tenantNameController.text,
                                    controller.phoneNumberController.text,
                                    controller.workPhoneNumberController.text,
                                    controller.emailController.text,
                                  widget.propertyData['unitName']
                                );


                              });
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                    content: Text("Configuration settings clicked!")),
                              );
                            },
                          ),
                        )
                     ]
                    ),
                    Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: SizedBox(
                            width: 120,
                            height: 150,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                            Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Container(
                              width: 460,
                              height: 350, // Extend text box height for multi-line input
                              child: TextField(
                                //controller: _controller,
                                maxLines: null, // Allows multiple lines
                                expands: true, // Makes the TextField expand within the container
                                keyboardType: TextInputType.multiline,
                                textAlignVertical: TextAlignVertical.top,
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(),
                                  hintText: "Type Unit note here...",
                                ),
                              ),
                            )
                            )
                              ],
                            ),
                          ),
                        )),
                  ],
                ),
              ),
            ],
          ),
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
  void _showPopupForm(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0),
          ),
          title: Text('Rental Details', textAlign: TextAlign.center),
          content: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Rent',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    onSaved: (value) {
                      controller.rentController.text = double.tryParse(value ?? '').toString();
                    },
                  ),
                  SizedBox(height: 15),
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Security Deposit',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    onSaved: (value) {
                      controller.securityDepositController.text = double.tryParse(value ?? '').toString();
                    },
                  ),
                  SizedBox(height: 15),
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Start Date',
                      border: OutlineInputBorder(),
                      hintText: 'YYYY-MM-DD',
                    ),
                    keyboardType: TextInputType.datetime,
                    onSaved: (value) {
                      //startDate = DateTime.tryParse(value ?? '');
                    },
                  ),
                  SizedBox(height: 15),
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: 'End Date',
                      border: OutlineInputBorder(),
                      hintText: 'YYYY-MM-DD',
                    ),
                    keyboardType: TextInputType.datetime,
                    onSaved: (value) {
                      //endDate = DateTime.tryParse(value ?? '');
                    },
                  ),
                ],
              ),
            ),
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                _formKey.currentState?.save();
                Navigator.of(context).pop();
                // Process the saved data as needed
              },
              child: Text('Submit'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

}

