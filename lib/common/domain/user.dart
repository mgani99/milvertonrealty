
import 'dart:convert';

import 'package:milvertonrealty/common/domain/base_domain.dart';

class ReUser extends BaseDomain {
  int id = 0; //hash for user
  String fireBaseId= "";
  final String name;
  String profilePictureURL = "";
  final String emailAddress;
  final String userType;
  String fcmKey ="";
  static String userRootDB = "Users/";
  ReUser(super.id, {required this.name, required this.emailAddress, required this.userType});


  static ReUser fromMap(Map map) {
      final name = map['name'] ?? " ";
      final id = map['id'] ?? 0;
      final emailAddress = map['emailAddress'] ?? " ";
      final userType = map['userType'] ?? "Owner";
      ReUser usr = ReUser(id, name : name, emailAddress: emailAddress, userType: userType!);
      usr.fireBaseId = map['fireBaseId'] ?? "";
      usr.fcmKey = map['fcmKey'] ?? "";
      return usr;

  }


  @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['fireBaseId'] = this.fireBaseId;
    data['name'] = this.name;
    data['emailAddress'] = this.emailAddress;
    data['userType'] = this.userType;
    data['fcmKey'] = this.fcmKey;
    return data;

  }


  static ReUser getNullObj() {
    // TODO: implement getNullObj
    return ReUser(0, name: "", emailAddress: "", userType: "");
  }

  @override
  String getObjDBLocation() {
    // TODO: implement getObjDBLocation
    return ReUser.userRootDB + this.fireBaseId;
  }


}

