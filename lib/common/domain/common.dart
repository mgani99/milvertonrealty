

import 'dart:convert';

import 'package:milvertonrealty/common/domain/base_domain.dart';
import 'package:milvertonrealty/common/model/common_model.dart';

class Unit extends BaseDomain  {
  int id =0;
  final String name;
  final String unitType; //main, apartment, garage, parking
  final List<int> leaseHistory;
  final int currentLeaseId;
  int bedrooms = 0;
  double bathrooms= 0;
  int livingSpace= 0;
//main house isclass Unitclass Unit always 0, apartment by default 1, garage 2, parking 3, all other 4;
  String address="";
  //double rent = 0.0;
  int propId=0;
  int tenantId=0;
  String pictureURL = "";

  static var rootDBLocation = "Units/";




  Unit( super.id, this.unitType, this.leaseHistory, this.currentLeaseId, this.name){
    if (id ==0 || id==1) id = name.hashCode + unitType.hashCode + currentLeaseId.hashCode;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();

    data['id'] = this.id;
    data['name'] = this.name;
    data['unitType'] = this.unitType;
    data['currentLeaseId'] = this.currentLeaseId;
    data['bedrooms'] = this.bedrooms;
    data['bathrooms'] = this.bathrooms;
    data['livingSpace'] = this.livingSpace;
    data['address'] = this.address;
    //data['rent'] = this.rent;
    data['propId'] = this.propId;
    data['tenantId'] = this.tenantId;
    data['leaseHistory'] = jsonEncode(this.leaseHistory);
    data['pictureURL'] = this.pictureURL;
    return data;
  }


  @override
  bool operator ==(Object other) => other is Unit && other.id == id;
  @override
  String toString() {
    String retVal = "{id: $id, name:'$name',unittype:'$unitType'}";
    // TODO: implement toString
    return retVal;
  }

  static Unit nullUnit() {
    return Unit(0,"", [], 0, "");
  }

  @override
  int get hashCode => id;
  static fromMap(Map<dynamic,dynamic> map) {

    var retVal = Unit(map['id'] ?? 0,
        (map['type']) ?? "", [], (map['currentLeaseId'] ?? 0),
        map['name'] ?? "");
    //retVal.id = int.parse(map['id'] ?? "0");
    retVal.bathrooms = (map.containsKey('bathrooms'))
        ? double.parse(map['bathrooms'] ?? "0.0")
        : 0;
    retVal.bedrooms = int.parse(map['bedrooms'] ?? "0");
    retVal.livingSpace = int.parse(map['livingSpace'] ?? "0");


    retVal.address = map['address'] ?? "";
    //  retVal.rent =  map['rent'] ?? 0.0;
    retVal.propId = map['propId'] ?? 0;
    retVal.tenantId = map['tenantId'] ?? 0;
    retVal.pictureURL = map['pictureURL'] ?? "";




    return retVal;
  }


  @override
  String getObjDBLocation() {
    // TODO: implement getObjDBLocation
    return Unit.rootDBLocation + id.toString();
  }

}

class LeaseDetails extends BaseDomain{
  static String rootDBLocation = "LeaseDetails/";
  bool isVacant = false;
  final String startDate;
  final String endDate;
  final List<int> tenantIds;
  final double rent;
  bool isYearly = false;
  double securityDeposit = 0.0;


  LeaseDetails(super.id, this.startDate, this.endDate, this.tenantIds, this.rent, this.securityDeposit) {
    if (id == 0 || id == 1)id = startDate.hashCode + endDate.hashCode+rent.hashCode + (tenantIds.isNotEmpty?[0].hashCode:0);
  }

  @override
  bool operator ==(Object other) => other is LeaseDetails && other.id == id;

  static LeaseDetails fromMap(Map<dynamic,dynamic> map) {
    LeaseDetails retVal = LeaseDetails(0, map['startDate']??"", map['endDate']??"", List<int>.from(json.decode(map['tenantId'])??[] ),
        double.parse(map['rent']??"0.0"), double.parse(map['securityDeposit']??"0.0"));
    retVal.id = int.parse(map['id']??"0");
    retVal.isVacant = bool.parse(map['isVacant']) ?? false;
    retVal.isYearly = bool.parse(map['isYearly']) ?? false;
    return retVal;

  }
  @override
  int get hashCode => id;
  static LeaseDetails nullLeaseDetails() {return LeaseDetails(0, "", "", [], 0.0,0.0);}

  @override
  String getObjDBLocation() {
    // TODO: implement getObjDBLocation
    return LeaseDetails.rootDBLocation + id.toString();
  }

  @override
  Map<String, dynamic> toJson() {
      final Map<String, dynamic> data = new Map<String, dynamic>();
      data['id'] = this.id;
      data['startDate'] = this.startDate;
      data['endDate'] = this.endDate;
      data['tenantIds'] = this.tenantIds;
      data['rent'] = this.rent;
      data['isVacant'] = this.isVacant;
      data['isYearly'] = this.isYearly;
      data['securityDeposit'] = this.securityDeposit;

      return data;
  }

}


class Tenant extends BaseDomain {
  static String rootDBLocation = "Tenants/";

  //late int id =0;
  final String name;
  final String bankAccountId;
  final String phoneNumber;
  final String email;
  Map<String, int> tokens = {}; //tokenize the tenant name for searching

  Tenant(super.id, this.name, this.bankAccountId, this.phoneNumber,
      this.email) {
    if (id == 0 || id == 1) id = (name + phoneNumber + email).hashCode;
  }

  @override
  bool operator ==(Object other) => other is Tenant && other.id == id;

  @override
  int get hashCode => id;

  static Tenant nullTenant() {
    var retVal = Tenant(0, "", "", "", "");
    return retVal;
  }

  static Tenant fromMap(Map<dynamic, dynamic> map) {
    Tenant retVal = Tenant.nullTenant();
    retVal = Tenant(
        map['id'], map['name'], map['bankAccountId'], map['phoneNumber'],
        map['email']);
    retVal.id = int.parse(map['id'] ?? "0");

    retVal.tokens[retVal.name.toUpperCase()] = 1;

    List<String> subString = [];
    (retVal.tokens.keys.toList()).forEach((element) {
      for (int i = 2; i <= element.length; i++) {
        subString.add(element.substring(0, i));
      }
    });
    retVal.tokens.addAll({for (var item in subString) '$item': 1});
    //print(retVal);
    return retVal;
  }

  @override
  String getObjDBLocation() {
    // TODO: implement getObjDBLocation
    return Tenant.rootDBLocation + this.id.toString();
  }

  @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['bankAccountId'] = this.bankAccountId;
    data['email'] = this.email;
    data['phoneNumber'] = this.phoneNumber;

    return data;
  }


}





class Property extends BaseDomain {

  final String name;
  final List<int> unitIds;
  final String address;
  final String propertyType;
  String pictureURL ="";

  static var rootDBLocation = "Property/";

  Property(super.id,{required this.name, required this.address, required this.unitIds,required this.propertyType}) {
    if (id ==0 || id == 1)id = name.hashCode + propertyType.hashCode;
  }

  @override
  int get hashCode => id;

  @override
  bool operator ==(Object other) => other is Property && other.id == id;

  @override
  String toString() {
    String retVal = "{id: $id, name:'$name',address:'$address'}";
    // TODO: implement toString
    return retVal;
  }


  factory Property.fromMap(Map<dynamic,dynamic> map) {

    var retVal = Property(map['id'] ?? 0,name: map['name'] ?? '',
        address: map['address'] ?? '',
        unitIds: List<int>.from(json.decode(map['rentalUnits']) ??[0]) ,
        propertyType: map['propertyType'] ?? '');
    //retVal.id = map['id']?? 0;
    retVal.pictureURL = map.containsKey('pictureURL') ? map['pictureURL'] ?? '' : '';
    return retVal;

  }

  @override
  String getObjDBLocation() {
    // TODO: implement getObjDBLocation
    return Property.rootDBLocation + this.id.toString();
  }

  @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['unitIds'] = this.unitIds;
    data['address'] = this.address;
    data['propertyType'] = this.propertyType;
    data['pictureURL'] = this.pictureURL;

    return data;
  }
}
