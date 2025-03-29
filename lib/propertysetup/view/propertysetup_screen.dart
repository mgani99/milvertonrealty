import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:milvertonrealty/propertysetup/controller/propertyUnitController.dart';
import 'package:milvertonrealty/user/components/text_box.dart';
import 'package:milvertonrealty/utils/constants.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(ApartmentFormApp());
}

class ApartmentFormApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: PropertySetup(),
    );
  }
}

class PropertySetup extends StatefulWidget {
  //const PropertySetup({super.key});
  @override
  _PropertySetupState createState() => _PropertySetupState();
}

class _PropertySetupState extends State<PropertySetup> {


  bool lastPage = false;
  bool isSaving = false;
  final _formKey = GlobalKey<FormState>();
  int _numUnits = 1;
  PageController _pageController = PageController();
  List<Map<String, dynamic>> _unitsData = [];
  List<TextEditingController> _unitControllers = [];
  List<TextEditingController> _nameControllers = [];
  List<TextEditingController> _rentControllers = [];
  List<TextEditingController> _leaseStartControllers = [];
  List<TextEditingController> _leaseEndControllers = [];


  @override
  void initState() {
    super.initState();
    _unitsData = List.generate(_numUnits, (_) => {
      'unitNumber': '',
      'tenantName': '',
      'rent': 0.0,
      'isVacant': false,
      'isMonthToMonth' : false,
      'isYearly' : true
    });
    _unitControllers = List.generate(
      _numUnits,
          (index) => TextEditingController(),
    );
    _nameControllers = List.generate(
      _numUnits,
          (index) => TextEditingController(),
    );
    _rentControllers = List.generate(
      _numUnits,
          (index) => TextEditingController(),
    );
    _leaseStartControllers = List.generate(
      _numUnits,
          (index) => TextEditingController(),
    );
    _leaseEndControllers = List.generate(
      _numUnits,
          (index) => TextEditingController(),
    );
  }


  @override
  void dispose() {
    _pageController.dispose();
    for (var controller in _unitControllers) {
      controller.dispose();
    }
    for (var controller in _nameControllers) {
      controller.dispose();
    }

    for (var controller in _rentControllers) {
      controller.dispose();
    }

    for (var controller in _leaseStartControllers) {
      controller.dispose();
    }

    for (var controller in _leaseEndControllers) {
      controller.dispose();
    }

    super.dispose();
  }

  void _updateUnitCount(int count) {
    setState(() {
      if (_pageController.page! >= count-1) lastPage = true;
      _numUnits = count;
      List<Map<String, dynamic>> _additionalData = [];
      _additionalData = List.generate(_numUnits-_unitsData.length, (_) => {
        'unitNumber': '',
        'tenantName': '',
        'rent': 0.0,
        'isVacant': false,
        'isMonthToMonth' : false,
        'isYearly' : true

      });
      _unitsData.addAll(_additionalData);
    });
    _unitControllers = List.generate(
      _numUnits,
          (index) => TextEditingController(),
    );
    _nameControllers = List.generate(
      _numUnits,
          (index) => TextEditingController(),
    );
    _rentControllers = List.generate(
      _numUnits,
          (index) => TextEditingController(),
    );
    _leaseStartControllers = List.generate(
      _numUnits,
          (index) => TextEditingController(),
    );
    _leaseEndControllers = List.generate(
      _numUnits,
          (index) => TextEditingController(),
    );
  }


  @override
  Widget build(BuildContext context) {
      final controller =     Provider.of<PropertySetupController>(context, listen: true);
      return Scaffold(
          backgroundColor: Colors.grey[300],
          appBar: AppBar(
          title: Text("Property Setup", style: TextStyle(color: Colors.white),),
    backgroundColor: Colors.grey[900],
    ),
    body: isSaving ? CircularProgressIndicator() :

        Column(
        children: [
          Padding(
              padding: const EdgeInsets.fromLTRB(8.0, 16, 8, 1),
              child: TextFormField(
              //validator: firstNameValidator.call,
              textInputAction: TextInputAction.next,
              keyboardType: TextInputType.name,
              controller: controller.propNameController,


              decoration: InputDecoration(
                labelText: "Property Name",

                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide:
                  BorderSide(width: 2, color: ColorConstants.primaryColor),
                ),
              ),
            ),

          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(8.0, 8, 8, 1),
            child: TextFormField(
              //validator: firstNameValidator.call,
              textInputAction: TextInputAction.next,
              keyboardType: TextInputType.name,
              controller: controller.propAddressController,

              decoration: InputDecoration(
                labelText: "Property Address",
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  //borderRadius: BorderRadius.circular(8.0),
                  borderSide:
                  BorderSide(width: 2, color: ColorConstants.primaryColor),
                ),
              ),
            ),

          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Unit Count:", style: TextStyle(color: Colors.black),),
                SizedBox(width: 120,
                  child: IncrementDecrementTextBox(
                    initialValue: _numUnits,
                    onChanged: (value) {
                      _updateUnitCount(value);
                    print("Current value: $value");
                    },
                    ),
                ),
              ],
            )

          ),
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              itemCount: _numUnits,
              itemBuilder: (context, index) {
                return _buildUnitForm(index);
              },
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SizedBox(
                width: 120,height: 60,
                child: Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: ElevatedButton(
                    onPressed: () {

                      if (_pageController.page! > 0) {
                        _pageController.previousPage(
                          duration: Duration(milliseconds: 100),
                          curve: Curves.ease,
                        );
                        setState(() {
                          lastPage = false;
                        });
                      }

                    },
                    child: Text('Previous', style: TextStyle(color:Colors.black),),
                  ),
                ),
              ),
              SizedBox(
                width: 120,height: 60,
                child: Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: ElevatedButton(
                    onPressed: () {
                      if (lastPage) {
                        setState(() {
                          isSaving = true;
                        });
                        controller.saveProperty(_unitsData, context);

                        isSaving = false;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Property saved successfully')),
                        );

                      }
                      if (_pageController.page! < _numUnits - 1) {

                        _pageController.nextPage(
                          duration: Duration(milliseconds: 100),
                          curve: Curves.ease,

                        );
                      }

                      setState(() {
                        if (_pageController.page! >= _numUnits-1) {
                          lastPage = true;
                        }
                        else lastPage = false;

                      });

                    },

                    child: Text(lastPage ? 'Save' : 'Next', style: TextStyle(color:Colors.black),),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height:20),
        ],
        )
    );
  }
  Widget _buildUnitForm(int index) {
    final controller =     Provider.of<PropertySetupController>(context, listen: true);
    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: Card(
        elevation: 4.0,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
           key: PageStorageKey<String>("unit" + index.toString()),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Unit ${index + 1}',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
                  ),
                  Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: TextFormField(
                          decoration: InputDecoration(
                            labelText: 'Unit Number*',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.grey, width: 1.5),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: ColorConstants.primaryColor, width: 2.0),
                            ),
                          ),
                          controller: _unitControllers[index],
                          onChanged: (value) {
                            _unitsData[index]['unitNumber'] = value;
                          },
                        ),
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        flex: 3,
                        child: CheckboxListTile(
                          title: Text('Vacant'),
                          value: _unitsData[index]['isVacant'],
                          onChanged: (value) {
                            setState(() {
                              _unitsData[index]['isVacant'] = value!;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Tenant Name',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey, width: 1.5),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: ColorConstants.primaryColor, width: 2.0),
                      ),
                    ),
                      controller: _nameControllers[index],
                      keyboardType: TextInputType.name,
                    onChanged: (value) {
                      print('index = ${index}');
                      _unitsData[index]['tenantName'] = value;
                    },
                    enabled: !_unitsData[index]['isVacant'],
                  ),
                  SizedBox(height: 10),
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Rent*',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey, width: 1.5),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: ColorConstants.primaryColor, width: 2.0),
                      ),
                    ),
                    keyboardType: TextInputType.number,
                    controller: _rentControllers[index],
                    onChanged: (value) {
                      _unitsData[index]['rent'] = double.tryParse(value);
                    },
                    enabled: !_unitsData[index]['isVacant'],
                  ),
                  SizedBox(height: 10),
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Lease Start Date',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey, width: 1.5),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.blue, width: 2.0),
                      ),
                    ),
                    keyboardType: TextInputType.datetime,
                    controller: _leaseStartControllers[index],
                    enabled: !_unitsData[index]['isVacant'],
                   /* onChanged: (value) {
                      _unitsData[index]['LeaseStartDate'] = value;
                    },*/
                    onTap: () async {
                      DateTime? selectedDate = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2100),
                      );
                      if (selectedDate != null) {
                        setState(() {
                          _unitsData[index]['leaseStartDate'] =
                              controller.dateFormat.format(selectedDate);
                          _leaseStartControllers[index].text = controller.dateFormat.format(selectedDate);
                        });
                      }
                    },
                    //readOnly: true,
                  ),
                  SizedBox(height: 10),
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Lease End Date',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey, width: 1.5),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.blue, width: 2.0),
                      ),
                    ),
                    controller: _leaseEndControllers[index],
                    enabled: !_unitsData[index]['isVacant'],
                    onChanged: (value) {
                      _unitsData[index]['leaseEndDate'] = value;
                    },
                    onTap: () async {
                      DateTime? selectedDate = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2100),
                      );
                      if (selectedDate != null) {
                        setState(() {
                          var date = controller.dateFormat.format(selectedDate);
                          _unitsData[index]['leaseEndDate'] =
                              date;
                          _leaseEndControllers[index].text = date;
                        });
                      }
                    },
                    readOnly: true,
                  ),
                  SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: CheckboxListTile(
                          title: Text('Month-to-Month'),
                          value: _unitsData[index]['isMonthToMonth'] ?? false,
                          onChanged: (value) {
                            setState(() {
                              _unitsData[index]['isMonthToMonth'] = value;
                              _unitsData[index]['isYearly'] = !value!;
                            });
                          },
                        ),
                      ),
                      Expanded(
                        child: CheckboxListTile(
                          title: Text('Yearly'),
                          value: _unitsData[index]['isYearly'] ?? true,
                          onChanged: (value) {
                            setState(() {
                              _unitsData[index]['isYearly'] = value;
                              _unitsData[index]['isMonthToMonth'] = !value!;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }





}
