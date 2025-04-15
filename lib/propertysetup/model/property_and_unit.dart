

import 'dart:async';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:http/http.dart';
import 'package:milvertonrealty/common/domain/common.dart';
import 'package:milvertonrealty/common/model/common_model.dart';
import 'package:milvertonrealty/common/service.dart';
import 'package:provider/provider.dart';

class PropertyUnitModel extends BaseModel {
  static Future<List<Unit>> getUnits() async {
    final List<Unit> retVal = [];
    final snapshot = await MR_DBService().getDBRef(Unit.rootDBLocation).get();
    final map = snapshot.value as Map<dynamic, dynamic>;
    map.forEach((key, value) {
      final unit = Unit.fromMap(value);
      retVal.add(unit);
    });
    return retVal;
  }

  static Future<List<Tenant>> getTenants() async {
    final List<Tenant> retVal = [];
    final snapshot = await MR_DBService().getDBRef(Tenant.rootDBLocation).get();

    final map = snapshot.value as Map<dynamic, dynamic>;
    map.forEach((key, value) {
      final tenant = Tenant.fromMap(value);
      retVal.add(tenant);
    });
    return retVal;
  }

  static Future<List<LeaseDetails>> getLeaseDetails() async {
    final List<LeaseDetails> retVal = [];
    final snapshot = await MR_DBService().getDBRef(LeaseDetails.rootDBLocation).get();
    final map = snapshot.value as Map<dynamic, dynamic>;
    map.forEach((key, value) {
      final leaseDetails = LeaseDetails.fromMap(value);
      retVal.add(leaseDetails);
    });
    return retVal;
  }

  List<Map<String, dynamic>> combineUnitDetails(Map<String, dynamic> units,
      Map<String, dynamic> leaseDtls,
      Map<String, dynamic> tenants,) {

    List<Map<String, dynamic>> retVal = [];
   /* dynamic units_dyn = await futureUnits;
    Map<String, dynamic> units = units_dyn;

    Map<String, dynamic> leaseDtls = (await futureLD) as Map<String, dynamic>;
    Map<String, dynamic> tenants = (await futureTenants) as Map<String, dynamic>;*/

    units.forEach((key, value) {
      final unitJson = value;
      value['unitId'] = value['id'];
      value['unitName'] = value['name'];
      Map<String, dynamic> inventory = Map<String,dynamic>.from(value['inventory']?? {} as Map);
      value['hasRefrigerator'] = inventory['refrigerator'] ?? false;
      value['hasMicrowave'] = inventory['microwave'] ?? false;
      value['hasDishwasher'] = inventory['dishwasher'] ?? false;
      value['hasStove'] = inventory['stove'] ?? false;

      Map<String, dynamic> combinedJson = {...unitJson};

      if (leaseDtls.containsKey(value['currentLeaseId'].toString())) {
        final ld = leaseDtls[value['currentLeaseId'].toString()];
        ld['leaseId'] = value['currentLeaseId'];
        combinedJson = {...combinedJson, ...ld};
        List<int> ids = List<int>.from(jsonDecode(ld['tenantIds'].toString() ?? "[0]"));
        print("Tenant id ${ids[0]}");
        if (tenants.containsKey(ids[0].toString())) {
          final tenant = tenants[ids[0].toString()];

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
       a['unitName'].compareTo(b['unitName']);

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

  Future<Map<String, dynamic>> getMergedPropertyDataForUnit(Map<String, dynamic> unitData) async{
    Map<String, dynamic> retVal = {...unitData};
  //  final unitJson = retVal.values.first;

    retVal['unitId'] = retVal['id'];
    retVal['unitName'] = retVal['name'];
    Map<String, dynamic> inventory = Map<String,dynamic>.from(retVal['inventory']?? {} as Map);
    retVal['hasRefrigerator'] = inventory['refrigerator'] ?? false;
    retVal['hasMicrowave'] = inventory['microwave'] ?? false;
    retVal['hasDishwasher'] = inventory['dishwasher'] ?? false;
    retVal['hasStove'] = inventory['stove'] ?? false;

  //  Map<String, dynamic> combinedJson = {...unitJson};
    Map<String, dynamic>? leaseDtl = await getDomainById(retVal['currentLeaseId'], LeaseDetails.rootDBLocation);
    if (leaseDtl!= null && leaseDtl.isNotEmpty) {
      final ld = leaseDtl[retVal['currentLeaseId'].toString()];
      ld['leaseId'] = retVal['currentLeaseId'];
      retVal = {...retVal, ...ld};
      List<int> ids = List<int>.from(jsonDecode(ld['tenantIds'].toString() ?? "[0]"));
      final tenant = await getDomainById(ids[0],Tenant.rootDBLocation);
      if (tenant != null ) {
        print("tenant name ${tenant['name']}");
        tenant['tenantId'] = tenant['id'];
        tenant['tenantName'] = tenant['name'];
        retVal = {...retVal, ...tenant};
      }
    }
    return retVal;

  }


  Future<List<Map<String, dynamic>>> getAllUnitsInJson2() async {
    List<Map<String, dynamic>> retVal = [];
    try {
      Map<String, dynamic> allUnits = Map<String, dynamic>.from(
          (await MR_DBService().getDBRef(Unit.rootDBLocation).get())
              .value as Map);
      allUnits.forEach((key, value) async {
        Map<String, dynamic> mergedData = await getMergedPropertyDataForUnit(value);
        retVal.add(mergedData);
      });
    }
    catch(error) {
      print(error);
    };
    return retVal;

  }



  Future<List<Map<String, dynamic>>> getAllUnitsInJson() async{
    List<Map<String, dynamic>> retVal = [];
    List results = await Future.wait([

      Future.value(Map<String,dynamic>.from((await MR_DBService().getDBRef(Unit.rootDBLocation).get()).value as Map)) ,
      Future.value(Map<String, dynamic>.from((await MR_DBService().getDBRef(LeaseDetails.rootDBLocation).get()).value as Map)),


      Future.value(Map<String,dynamic>.from((await MR_DBService().getDBRef(Tenant.rootDBLocation).get()).value as Map)),


    ]).then((data) =>(combineUnitDetails(data[0],data[1], data[2])));


    //catch(error) {print(error);};

    retVal = results.cast<Map<String,dynamic>>();

    return retVal;

  }







  Future<List<Unit>> getAllUnits() async{
    return PropertyUnitModel.getUnits();
  }


}