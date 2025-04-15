



import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';

import 'package:milvertonrealty/common/domain/base_domain.dart';
import 'package:milvertonrealty/common/domain/user.dart';
import 'package:milvertonrealty/common/service.dart';


/// Adds [item] to cart. This is the only way to modify the cart from outside.

class BaseModel with ChangeNotifier{
  final FirebaseAuth _auth = FirebaseAuth.instance;


  Future<void> addObject(BaseDomain baseDomain) async {
    final dbPropertyReference = MR_DBService().getDBRef(baseDomain.getObjDBLocation());
    try{
      await dbPropertyReference.update(baseDomain.toJson());
    }
    catch(e) {
      print('you Error saving User details ot an error $e');
    }
    notifyListeners();
  }
  void removeDomain(BaseDomain domain, String ref) async{
    final dbRef = MR_DBService().getDBRef(ref+"//${domain.id}");
    try {
      dbRef.remove();
    }
    catch(e) {
      print('Error Removing $e ${domain.toJson()}');
    }
    notifyListeners();
  }

  Future<Map<String, dynamic>?> getDomainById(int id, String ref) async{
    final dbRef = MR_DBService().getDBRef(ref+"${id}");

    try {
      final snapshot = await dbRef.get();

      // Check if data exists
      if (snapshot.exists) {
        final rawData = Map<String, dynamic>.from(snapshot.value as Map);

        return rawData;

      }
      else return {};
    }
    catch(e) {
      print('Error Removing $e ${id} from ${ref}');
      return {};
    }

  }

  void update(String rootDBLocation, String s, data2) async{
    final dbRef = MR_DBService().getDBRef(rootDBLocation);
    // Updating an attribute (e.g., changing the user's age)
    await dbRef.update({
      s: data2,
    });
    notifyListeners();


  }

}