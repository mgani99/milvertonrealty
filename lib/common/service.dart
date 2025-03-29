

import 'package:firebase_database/firebase_database.dart';


class MR_DBService{
  static String app_root= "MilvertonApp/";
  static final MR_DBService _instance = MR_DBService._internal();
  final database = FirebaseDatabase.instance.ref();
  MR_DBService._internal();
  factory MR_DBService() {
    FirebaseDatabase.instance.setPersistenceEnabled(true);
    return _instance;
  }




  DatabaseReference getDBRef(String location) {
    return database.child( MR_DBService.app_root + location);
  }
}
