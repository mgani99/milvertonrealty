
import 'dart:convert';

import 'package:intl/intl.dart';
import 'package:milvertonrealty/common/domain/base_domain.dart';


class Repair extends BaseDomain implements Comparable<Repair> {

  static String rootDBLocation = "Repairs/";
  int id= 0;
  String title = "";
  String description="";
  String unit = "";
  DateTime dateOfIssue = DateTime.now();
  double laborCost=0.0;
  double materialCost = 0.0;
  String status = "";
  int contractorId = 0;
  String paidStatus = ""; //tenant name
  String comment = "";
  List<String> imageUrls=[""];

  Repair(super.id,{

    required this.title,
    required this.description,
    required this.unit,
    required this.dateOfIssue,
    required this.status}) {
    if (id == 0 || id == 1) {
      id = title.hashCode + unit.hashCode + dateOfIssue.hashCode ;
    }

  }
  @override
  bool operator ==(Object other) => other is Repair && other.id == id ;

  @override
  int compareTo(Repair other) {

    return (dateOfIssue == other.dateOfIssue) ?  this.id.compareTo(other.id) :
            dateOfIssue.compareTo(other.dateOfIssue);



  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    String dt = DateFormat("MM/dd/yy hh:mm:ss").format(dateOfIssue);
    data['id'] = this.id;
    data['title'] = this.title;
    data['description'] = this.description;
    data['unit'] = this.unit;
    data['dateOfIssue'] = dt;
    data['status'] = this.status;
    data['laborCost'] = this.laborCost.toString();
    data['materialCost'] = this.materialCost.toString();
    data['contractorId'] = this.contractorId;
    data['paidStatus'] = this.paidStatus;
    data['comment'] = this.comment;
    data['imageUrls'] = jsonEncode(this.imageUrls);
    return data;
  }

  static Repair nullRepair() {
    var retVal =  Repair(0,status: "Open",title:"",
      description : "",
      unit : "",
      dateOfIssue: DateTime.now(),);
    return retVal;
  }

  factory Repair.fromMap(Map<dynamic,dynamic> map) {

    Repair retVal = Repair(0,title: map['title'] ?? "", description : map['description'] ?? "",
        unit: map['unit']?? 0, dateOfIssue: DateFormat("MM/dd/yy hh:mm:ss").parse(map['dateOfIssue'] ?? DateTime.now()),
        status: map['status']??"");
    retVal.id = map['id']??0;
    retVal.laborCost = double.parse(map['laborCost'])?? 0.0;
    retVal.materialCost = double.parse(map['materialCost'])??0.0;
    retVal.contractorId = map['contractorId']??0;
    retVal.paidStatus = map['paidStatus']??"";
    retVal.comment = map['comment']??"";

    retVal.imageUrls = List<String>.from(json.decode(map['imageUrls']??[]));

    return retVal;

  }


  @override
  String getObjDBLocation() {
    // TODO: implement getObjDBLocation
    return Repair.rootDBLocation + this.id.toString();
  }
}





