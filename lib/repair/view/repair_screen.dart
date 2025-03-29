import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:milvertonrealty/common/domain/Repair.dart';
import 'package:milvertonrealty/repair/controller/repair_controller.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: RepairIssueScreen(),
    );
  }
}

class RepairIssueScreen extends StatefulWidget {
  @override
  _MultiStepFormState createState() => _MultiStepFormState();
}

class _MultiStepFormState extends State<RepairIssueScreen> {
  PageController _pageController = PageController();
  List<String> selectedRooms = [];
  /*Map<String, List<String>> roomToSubcategories = {
    "Bathroom": ["Toilet Leak", "Broken Shower"],
    "Bedroom": ["Broken Fan", "Electric Switch"],
    "Kitchen": ["Broken Sink", "Broken Fridge"],
    "Hallway": ["Light Switch", "Main Door"],
  };*/
  Map<String, List<String>> roomToSubcategories = {};
  Map<String, List<String>> selectedSubcategories = {};
  Map<String, List<String>> subcategoryImages ={};
  int currentStep = 0;
  bool isLoading = true;
  void nextStep() {
    if (currentStep < 2) {
      setState(() {
        currentStep++;
      });
      _pageController.nextPage(
        duration: Duration(milliseconds: 100),
        curve: Curves.easeIn,
      );
    }
  }

  void previousStep() {
    if (currentStep > 0) {
      setState(() {
        currentStep--;
      });
      _pageController.previousPage(
        duration: Duration(milliseconds: 300),
        curve: Curves.easeIn,
      );
    }
  }

  @override
  void initState() {
    super.initState();
    fetchCategory();

  }
  Future<void> fetchCategory()async{
    try{
      Map<String, List<String>> cats  = await Provider.of<RepairController>(context, listen: false).getRepairCategory();
      setState(() {
        roomToSubcategories = cats;
        isLoading = false;
      });
    }
    catch(error) {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: Text('Milverton - Repair Request'),
      ),
      body: isLoading ? CircularProgressIndicator() : PageView(

        controller: _pageController,
        physics: NeverScrollableScrollPhysics(), // Disable manual swipe
        children: [
          // Step 1: Multi-Select Items
          StepOne(
            selectedRooms: selectedRooms,
            rooms : roomToSubcategories.keys.toList(),
            onNext: nextStep,
          ),
          // Step 2: Subcategories with ChoiceChips
          StepTwo(
            selectedRooms: selectedRooms,
            roomToSubcategories: roomToSubcategories,
            selectedSubcategories: selectedSubcategories,
            subcategoryImages: subcategoryImages,
            onNext: nextStep,
            onBack: previousStep,
          ),
          // Step 3: Final Review
          StepThree(
            selectedRooms: selectedRooms,
            selectedSubcategories: selectedSubcategories,
            subcategoryImages : subcategoryImages,
            onBack: previousStep,
          ),
        ],
      ),
    );
  }
}

class StepOne extends StatelessWidget {
  final List<String> selectedRooms;
  final VoidCallback onNext;
  List<String> rooms;

  StepOne({required this.selectedRooms, required this.rooms, required this.onNext});

  @override
  Widget build(BuildContext context) {


    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Select Rooms Need Repair",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          Wrap(
            spacing: 8.0,
            children: rooms.map((room) {
              return ChoiceChip(
                label: Text(room),
                selected: selectedRooms.contains(room),
                selectedColor: Colors.blue.shade300,
                onSelected: (bool selected) {
                  if (selected) {
                    selectedRooms.add(room);
                  } else {
                    selectedRooms.remove(room);
                  }
                  (context as Element).markNeedsBuild(); // Refresh UI
                },
              );
            }).toList(),
          ),
          Spacer(),
          ElevatedButton(
            onPressed: onNext,
            child: Text("Next"),
            style: ElevatedButton.styleFrom(
              minimumSize: Size(80, 20), // Set button dimensions
              backgroundColor: Colors.grey, // Background color for the Back button
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.0), // Rounded corners
              ),
            ),
          ),
        ],
      ),
    );
  }
}


class StepTwo extends StatefulWidget {
  final List<String> selectedRooms;
  final Map<String, List<String>> roomToSubcategories;
  final Map<String, List<String>> selectedSubcategories;
  final Map<String, List<String>> subcategoryImages; // Tracks uploaded images
  final VoidCallback onNext;
  final VoidCallback onBack;

  StepTwo({
    required this.selectedRooms,
    required this.roomToSubcategories,
    required this.selectedSubcategories,
    required this.subcategoryImages,
    required this.onNext,
    required this.onBack,
  });

  @override
  State<StepTwo> createState() => _StepTwoState();
}

class _StepTwoState extends State<StepTwo> {
  List<File> _images = [];

  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage(String subcategory) async {
    try {
      // Allow user to pick multiple images
      final List<XFile>? pickedFiles = await _picker.pickMultiImage();
      if (pickedFiles != null) {
        setState(() {
          _images.addAll(pickedFiles.map((file) => File(file.path)));
          widget.subcategoryImages[subcategory] = pickedFiles.map((toElement) => toElement.path).toList();
        });
      }
    } catch (e) {
      print("Error picking images: $e");
    }
  }

  void promptForPictureUpload(BuildContext context, String room, String subcategory) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Upload Pictures for $subcategory in $room",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {_pickImage(subcategory); },
                  // Placeholder logic for image upload
                  // You would integrate an actual image picker here
                 // widget.subcategoryImages[subcategory] = ['image_placeholder.png'];
                  //Navigator.pop(context); // Close the bottom sheet
                  /*ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Picture uploaded for $subcategory")),
                  );
                  (context as Element).markNeedsBuild(); // Refresh UI
                },*/
                child: Text("Upload Picture"),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Select Issues",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          Expanded(
            child: ListView(
              children: widget.selectedRooms.map((room) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      room,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Wrap(
                      spacing: 8.0,
                      children: (widget.roomToSubcategories[room] ?? [])
                          .map(
                            (subcategory) => ChoiceChip(
                          label: Text(subcategory),
                          selected: widget.selectedSubcategories[room]?.contains(subcategory) ?? false,
                          selectedColor: Colors.blue.shade300,
                          onSelected: (bool selected) {
                            if (selected) {
                              widget.selectedSubcategories[room] = (widget.selectedSubcategories[room] ?? [])
                                ..add(subcategory);

                              // Prompt user for picture upload
                              promptForPictureUpload(context, room, subcategory);
                            } else {
                              widget.selectedSubcategories[room]?.remove(subcategory);
                              widget.subcategoryImages.remove(subcategory); // Remove uploaded images
                            }
                            (context as Element).markNeedsBuild(); // Refresh UI
                          },
                        ),
                      )
                          .toList(),
                    ),
                    SizedBox(height: 16),
                  ],
                );
              }).toList(),
            ),
          ),
          Expanded(
            child: _images.isEmpty
                ? Center(child: Text("No images uploaded"))
                : ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _images.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Image.file(
                    _images[index],
                    width: 150,
                    fit: BoxFit.cover,
                  ),
                );
              },
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ElevatedButton(
                onPressed: widget.onBack,
                child: Text("Back"),
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(80, 20), // Set button dimensions
                  backgroundColor: Colors.grey, // Background color for the Back button
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0), // Rounded corners
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: widget.onNext,
                child: Text("Next"),
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(80, 20), // Set button dimensions
                  backgroundColor: Colors.blue, // Background color for the Next button
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0), // Rounded corners
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}


class StepThree extends StatelessWidget {
  final List<String> selectedRooms;
  final Map<String, List<String>?> selectedSubcategories;
  final Map<String, List<String>> subcategoryImages;
  final VoidCallback onBack;

  StepThree({
    required this.selectedRooms,
    required this.selectedSubcategories,
    required this.subcategoryImages,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Review and Finalize",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Expanded(
                child: ListView(
                  children: [
                    Text("Selected Rooms:"),
                    ...selectedRooms.map((room) {
                      return ListTile(
                        title: Text("${room}-Issues: ${selectedSubcategories[room] ??
                            "None"}"  ),
                        subtitle:
                        SizedBox(
                        height: 200, // Limit the width for horizontal scrolling
                        child: ListView.builder(
                        scrollDirection: Axis.horizontal, // Horizontal scroll direction
                        itemCount: subcategoryImages.values.toList().expand((innerList) => innerList).toList().length,
                        itemBuilder: (context, index) {
                          List<String> flattenedList = subcategoryImages.values.toList().expand((innerList) => innerList).toList();
                          print(flattenedList);
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4.0),
                            child: Image.file(File(
                              flattenedList[index]),
                              width: 80, // Adjust image width
                              height: 200, // Adjust image height
                              fit: BoxFit.cover,
                            )   ,
                          );
                        },
                        ),),);


                    }).toList(),
                  ],
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton(
                    onPressed: onBack,
                    child: Text("Back"),
                    style: ElevatedButton.styleFrom(
                      minimumSize: Size(80, 20),
                      // Set button dimensions
                      backgroundColor: Colors.grey,
                      // Background color for the Back button
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                            12.0), // Rounded corners
                      ),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      // Final submission action
                      Provider.of<RepairController>(context, listen: false).saveRepair(selectedRooms, selectedSubcategories);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Form Submitted!")),
                      );
                    },
                    child: Text("Submit"),
                    style: ElevatedButton.styleFrom(
                      minimumSize: Size(120, 50),
                      // Set button dimensions
                      backgroundColor: Colors.blue,
                      // Background color for the Next button
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                            20.0), // Rounded corners
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );

  }
}
