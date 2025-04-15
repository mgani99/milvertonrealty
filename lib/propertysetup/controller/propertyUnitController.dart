
import 'dart:async';
import 'dart:convert';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import 'package:milvertonrealty/common/domain/common.dart';
import 'package:milvertonrealty/common/service.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:milvertonrealty/propertysetup/model/property_and_unit.dart';
import 'package:permission_handler/permission_handler.dart';


class PropertySetupController extends ChangeNotifier {


  bool isLoading = true;
  bool stoveIsChecked = false;
  bool refrigeratorIsChecked =false;
  bool dishWasherIsChecked=false;
  bool microwaveIsChecked = false;
  DateFormat dateFormat = DateFormat("MM/dd/yyyy");
  bool isVacant = false;
  //property setup
  TextEditingController propNameController = TextEditingController();
  TextEditingController propAddressController = TextEditingController();

//unit setup
  TextEditingController bedroomController = TextEditingController();
  TextEditingController bathroomController = TextEditingController();
  TextEditingController sqrFeetController = TextEditingController();

  TextEditingController rentController = TextEditingController();
  TextEditingController securityDepositController = TextEditingController();
  TextEditingController leaseStartDateController = TextEditingController();
  TextEditingController leaseEndDateController = TextEditingController();
  TextEditingController tenantNameController = TextEditingController();

  TextEditingController phoneNumberController = TextEditingController();
  TextEditingController workPhoneNumberController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController tenantNotesController = TextEditingController();


  List<Tenant> _tenants = [];
  List<Tenant> get tenants => _tenants;

  List<Unit> _units = [];
  List<Unit> get units => _units;

  List<LeaseDetails> _leaseDetails= [];
  List<LeaseDetails> get leaseDetails => _leaseDetails;

  PropertyUnitModel model = PropertyUnitModel();
  List<Map<String, dynamic>> unitData = [];
  Map<int, Map<String, dynamic>> unitMap = {};
  Map<int, Map<String, dynamic>> leaseDtlsMap = {};
  Map<int, Map<String, dynamic>> tenantMap = {};

  late DatabaseReference _unitRef;
  StreamSubscription<DatabaseEvent>? _unitSubscription;

  late DatabaseReference _leaseDetailsRef;
  StreamSubscription<DatabaseEvent>? _leaseDetailsSubscription;

  late DatabaseReference _tenantRef;
  StreamSubscription<DatabaseEvent>? _tenantSubscription;




  PropertySetupController() {
    //print('property setup init');
    /*_leaseDetailsRef = MR_DBService().getDBRef(LeaseDetails.rootDBLocation);
    _unitRef = MR_DBService().getDBRef(Unit.rootDBLocation);
    _tenantRef = MR_DBService().getDBRef(Tenant.rootDBLocation);
    _listenToUnit(_unitSubscription, _unitRef);
    _listenToLD(_leaseDetailsSubscription, _leaseDetailsRef);
    _listenToTenants(_tenantSubscription, _tenantRef)*/
  }

  void _listenToUnit(StreamSubscription<DatabaseEvent>? subscription, DatabaseReference obj){

     subscription = obj.onValue.listen((event) {
      final snapshot = event.snapshot;
      if (snapshot.value != null) {
        final rawData = snapshot.value as Map<Object?, Object?>;
         unitMap = rawData.map((key, value) {
          // Convert the key to string.
          final int stringKey = int.parse(key.toString());
          // Convert the nested value to a Map<String, dynamic>
          final Map<String, dynamic> nestedMap = Map<String, dynamic>.from(value as Map);
          //print('leng of unitmpa ${nestedMap.length}');
          return MapEntry(stringKey, nestedMap);
        });
        unitData = combineUnitDetails();
        //print(unitData);

        notifyListeners();
      }

    });
  }

  void _listenToLD(StreamSubscription<DatabaseEvent>? subscription, DatabaseReference obj){

    subscription = obj.onValue.listen((event) {
      final snapshot = event.snapshot;
      if (snapshot.value != null) {
        final rawData = snapshot.value as Map<Object?, Object?>;
        unitMap = rawData.map((key, value) {
          // Convert the key to string.
          final int stringKey = int.parse(key.toString());
          // Convert the nested value to a Map<String, dynamic>
          final Map<String, dynamic> nestedMap = Map<String, dynamic>.from(value as Map);
          //print('leng of unitmpa ${nestedMap.length}');
          return MapEntry(stringKey, nestedMap);
        });
        unitData = unitMap.length > 0 ?combineUnitDetails():[];
       // print(unitData);

        notifyListeners();
      }

    });
  }
  void _listenToTenants(StreamSubscription<DatabaseEvent>? subscription, DatabaseReference obj){

    subscription = obj.onValue.listen((event) {
      final snapshot = event.snapshot;
      if (snapshot.value != null) {
        final rawData = snapshot.value as Map<Object?, Object?>;
        unitMap = rawData.map((key, value) {
          // Convert the key to string.
          final int stringKey = int.parse(key.toString());
          // Convert the nested value to a Map<String, dynamic>
          final Map<String, dynamic> nestedMap = Map<String, dynamic>.from(value as Map);
          return MapEntry(stringKey, nestedMap);
        });
        unitData = unitMap.length > 0 ? combineUnitDetails() : [];
        notifyListeners();
      }

    });
  }
  List<Map<String, dynamic>> combineUnitDetails() {

    List<Map<String, dynamic>> retVal = [];

    //print('***** leng of unitMap ${unitMap.length}');
    unitMap.forEach((key, value) {
      final unitJson = value;
      value['unitId'] = value['id'];
      value['unitName'] = value['name'];
      Map<String, dynamic> inventory = Map<String,dynamic>.from(value['inventory']?? {} as Map);
      value['hasRefrigerator'] = inventory['refrigerator'] ?? false;
      value['hasMicrowave'] = inventory['microwave'] ?? false;
      value['hasDishwasher'] = inventory['dishwasher'] ?? false;
      value['hasStove'] = inventory['stove'] ?? false;

      Map<String, dynamic> combinedJson = {...unitJson};

      if (leaseDtlsMap.containsKey(value['currentLeaseId'])) {

        final ld = leaseDtlsMap[value['currentLeaseId']] ?? {};

        print('found lease ${ld}');
        ld['leaseId'] = value['currentLeaseId'];
        combinedJson = {...combinedJson, ...ld};
        List<int> ids = List<int>.from(jsonDecode(ld['tenantIds'].toString() ?? "[0]"));
        print("Tenant id ${ids[0]}");
        if (tenantMap.containsKey(ids[0])) {
          final tenant = tenantMap[ids[0]];

          if (tenant != null) {
            print("tenant name ${tenant['name']}");
            tenant['tenantId'] = tenant['id'];
            tenant['tenantName'] = tenant['name'];
            combinedJson = {...combinedJson, ...tenant};
          }
        }
      }

      retVal.add(combinedJson);
    });
    retVal.sort((a, b) {
      int length =
      a['unitName']?.compareTo(b['unitName']);

      String letterA = a['unitName'].substring(0, 1);
      String letterB = b['unitName'].substring(0, 1);

      // Extract numeric part
      int numberA = int.parse(a['unitName'].substring(1));
      int numberB = int.parse(b['unitName'].substring(1));

      // Sort by letter first, then number
      int letterComparison = letterA.compareTo(letterB);
      if (letterComparison == 0) {
        return numberA.compareTo(numberB);
      }
      return letterComparison;


    });

    return retVal;
  }





  @override
  void dispose() {
    propNameController.dispose();
    propAddressController.dispose();
    bedroomController.dispose();
    bathroomController.dispose();
    sqrFeetController.dispose();
    rentController.dispose();
    tenantNotesController.dispose();
    securityDepositController.dispose();
    leaseEndDateController.dispose();
    leaseStartDateController.dispose();
    tenantNameController.dispose();
    phoneNumberController.dispose();
    workPhoneNumberController.dispose();
    emailController.dispose();
    _tenantSubscription?.cancel();
    _leaseDetailsSubscription?.cancel();
    _unitSubscription?.cancel();
    super.dispose();
  }

  void saveProperty(List<Map<String, dynamic>> _unitsData, BuildContext context) {

    // 'unitNumber': '',
    // 'tenantName': '',
    // 'rent': '',
    // 'isVacant': false,
    // 'isMonthToMonth' : false,
    // 'isYearly' : true


    List<int> unitIds = [];

    _unitsData.forEach((element) {
      String unitNumber = element['unitNumber'];
      var tenantName = element['tenantName'];
      bool isVacant = element['isVacant'] ?? false;
      double rent = element['rent'] ?? 0.0;
      String leaseStartDate = element['leaseStartDate'] ?? dateFormat.format(DateTime.now());
      String leaseEndDate = element['leaseEndDate'] ??dateFormat.format(DateTime.now());
      //bool isVacant = element['isVacant'] ?? false;
      bool isMonthToMonth = element['isMonthToMonth'] ?? false;
      bool isYearly = element['isYearly'] ?? !isMonthToMonth;



      int tenantId =0;
      if(isVacant) {
        leaseStartDate = dateFormat.format(DateTime(2025, 4, 14));//closing date
        leaseEndDate = dateFormat.format(DateTime(2030, 4,1));
        rent = 0.0;

      }
      else {
        tenantId = tenantName
            .toString()
            .hashCode + unitNumber
            .toString()
            .hashCode + DateTime
            .now()
            .hashCode;
        Tenant tenant = Tenant(tenantId, element['tenantName'], "", "", "");
        model.addObject(tenant);
      }

      LeaseDetails ld = LeaseDetails(unitNumber.hashCode + rent.hashCode + DateTime.now().hashCode, leaseStartDate,
          leaseEndDate, [tenantId], rent, 0.0);
       // leaseId= ld.id;
        ld.isYearly = isYearly;
        ld.isVacant = isVacant;
        model.addObject(ld);

      Unit aUnit = Unit(unitNumber.hashCode, "Apartment", [], ld.id, unitNumber);

      model.addObject(aUnit);
      unitIds.add(aUnit.id);


    });
    Property prop = Property(propNameController.text.trim().hashCode,name: propNameController.text.trim(),
        address: propAddressController.text.trim(), unitIds: unitIds, propertyType: "Apartment");
    model.addObject(prop);
  }

  Future<bool> requestContactPermissions() async {
    final status = await Permission.contacts.request();
    return status.isGranted;
  }
  Future<void> addTenantIntoPhone(String name, String phone, String workPhone, String email, String unitName) async {
    if (await requestContactPermissions()) {
      // Now safe to add or access contacts.
      // Your code to add contact goes here.
      try {
        Name n = Name(first: "Milverton Tenant ${unitName}- ${name}" );
        final newContact = Contact(
          name : n,
          phones: [Phone(phone, label: PhoneLabel.mobile  ), Phone(workPhone, label: PhoneLabel.work)],
          emails: [Email(email)],
        );

        // Insert the contact into the contact store
        await newContact.insert();
        // Add tenant to phone contacts.
      } catch (e) {
        print("Error adding tenant: $e");
      }
    } else {
      // Handle the case where permission is denied.
      print('Contacts permission not granted');
    }

  }
  Future<void> getProperty()  async{
    this.isLoading = true;
    unitData = await model.getAllUnitsInJson();
    this.isLoading   = false;
    notifyListeners();

  }

   void subscribeToPoropertyDataUpdate() {
     _tenantSubscription = MR_DBService()
        .getDBRef(Tenant.rootDBLocation)
        .onValue
        .listen((event) {
       final dataSnapshot = event.snapshot;
       if (dataSnapshot.value != null) {
         final Map<dynamic, dynamic> tenantsMap =
         dataSnapshot.value as Map<dynamic, dynamic>;
         _tenants = tenantsMap.entries
             .map((entry) =>
             Tenant.fromMap(entry.value as Map<String, dynamic>))
             .toList();
       } else {
         _tenants = [];
       }
       print("rctvd  ${event}");
       notifyListeners();
     });
  }


  void saveUnitDetails(Map<String, dynamic> data) {
    data['bathrooms'] = int.parse(bathroomController.text);
    data['bedrooms'] = int.parse(bedroomController.text);
    data['livingSpace'] = int.parse(sqrFeetController.text);

    model.update(Unit.rootDBLocation+data['unitId'].toString(), 'bathrooms', data['bathrooms']);
    model.update(Unit.rootDBLocation+data['unitId'].toString(), 'bedrooms', data['bedrooms']);
    model.update(Unit.rootDBLocation+data['unitId'].toString(), 'livingSpace', data['livingSpace']);
    print(data);
  }

  void saveLeaseDetails(Map<String, dynamic> data) {


    data['isVacant'] = isVacant;
    if (!isVacant) {
      int currentTenantId = data['tenantId'] ?? 0;
      if (currentTenantId == 0) {
        currentTenantId = tenantNameController.text.hashCode + DateTime.now().toString().hashCode;
        data['tenantIds'] = [currentTenantId];
        model.update(LeaseDetails.rootDBLocation+data['leaseId'].toString(), 'tenantIds', [currentTenantId]);

      }
      data['tenantId'] = currentTenantId;
      data['tenantName'] = tenantNameController.text.trim();
      model.update(Tenant.rootDBLocation + data['tenantId'].toString(), 'id', currentTenantId);
      model.update(Tenant.rootDBLocation + data['tenantId'].toString(), 'name', tenantNameController.text.trim());

    }
    data['rent']= isVacant? 0.0: double.parse(rentController.text);
    data['securityDeposit'] = isVacant? 0.0 : double.parse(securityDepositController.text);
    data['startDate'] = leaseStartDateController.text;
    data['endDate'] = leaseEndDateController.text;
    model.update(LeaseDetails.rootDBLocation+data['leaseId'].toString(), 'isVacant', data['isVacant']);
    if (!isVacant) {
      model.update(
          LeaseDetails.rootDBLocation + data['leaseId'].toString(), 'rent',
  data['rent']);
      model.update(LeaseDetails.rootDBLocation + data['leaseId'].toString(),
          'securityDeposit', data['securityDeposit']);
    }
    model.update(LeaseDetails.rootDBLocation+data['leaseId'].toString(), 'startDate', data['startDate']);
    model.update(LeaseDetails.rootDBLocation+data['leaseId'].toString(), 'endDate', data['endDate']);
    print(data);


  }

  void saveInventory(Map<String, dynamic> propertyData) {
    propertyData['hasRefrigerator'] = refrigeratorIsChecked;
    propertyData['hasStove'] = stoveIsChecked;
    propertyData['hasMicrowave'] = microwaveIsChecked;
    propertyData['hasDishwasher'] = dishWasherIsChecked;

    model.update(Unit.rootDBLocation+propertyData['unitId'].toString()+"/inventory/","microwave", microwaveIsChecked);
    model.update(Unit.rootDBLocation+ propertyData['unitId'].toString()+"/inventory/", "refrigerator", refrigeratorIsChecked);
    model.update(Unit.rootDBLocation+ propertyData['unitId'].toString()+ "/inventory/" , "dishwasher", dishWasherIsChecked);
    model.update(Unit.rootDBLocation+ propertyData['unitId'].toString()+ "/inventory/", "stove", stoveIsChecked);

  }

  void saveTenant(Map<String, dynamic> data) {

    data['phoneNumber'] = phoneNumberController.text;
    data['workPhoneNumber'] = workPhoneNumberController.text;
    data['email'] = emailController.text;
    data['tenantNote'] = tenantNotesController.text;

    model.update(Tenant.rootDBLocation+data['tenantId'].toString(), 'phoneNumber', data['phoneNumber']);
    model.update(Tenant.rootDBLocation+data['tenantId'].toString(), 'workPhoneNumber', data['workPhoneNumber']);
    model.update(Tenant.rootDBLocation+data['tenantId'].toString(), 'email', data['email']);
    model.update(Tenant.rootDBLocation+data['tenantId'].toString(), 'tenantNotes', data['tenantNote']);
    print(data);

  }



}