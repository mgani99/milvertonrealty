
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
  int createdAt;
  int lastLogin;
  String status;
  bool defaultUserType = true;
  static String userRootDB = "Users/";

  ReUser(super.id, {required this.name, required this.emailAddress, required this.userType,   required this.createdAt,
    required this.lastLogin,
    required this.status, });


  static ReUser fromMap(Map map) {
    try {
      final now = DateTime
          .now()
          .millisecondsSinceEpoch;
      final name = map['name'] ?? " ";

      final emailAddress = map['emailAddress'] ?? " ";

      final userType = map['userType'] ?? "Tenant";
      final id = map['id'] ?? ReUser.getId(emailAddress, userType);
      final createdAt = map.containsKey('createdAt')
          ? (map['createdAt'] ?? now)
          : now;
      final lastLogin = map.containsKey('createdAt')
          ? (map['createdAt'] ?? now)
          : now;
      final status = map.containsKey("status")
          ? (map ['status'] ?? 'Active')
          : 'Active';
      ReUser usr = ReUser(id, name: name,
          emailAddress: emailAddress,
          userType: userType!,
          createdAt: createdAt,
          lastLogin: lastLogin,
          status: status);
      usr.fireBaseId = map['fireBaseId'] ?? "";
      usr.fcmKey = map['fcmKey'] ?? "";
      usr.defaultUserType = map['defaultUserType'] ?? true;
      return usr;
    }
    catch (e) {
      print('Error during migration: $e');
      print('Error parsing ${map['name']}');
      print(e.toString());
      return ReUser.getNullObj();
    }

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
    data['defaultUserType'] = this.defaultUserType;
    data['status'] = this.status;
    data['createdAt'] = this.createdAt;
    data['lastLogin'] = this.lastLogin;
    return data;

  }


  static ReUser getNullObj() {
    // TODO: implement getNullObj
    return ReUser(0, name: "", emailAddress: "", userType: "", createdAt: 0, lastLogin: 0, status:"");
  }

  @override
  String getObjDBLocation() {
    // TODO: implement getObjDBLocation
    return ReUser.userRootDB + this.id.toString();
  }

  static int getId(String email, String userType) {
    return Object.hash(email,userType);// (id.toString()+userType).hashCode;
  }

}

