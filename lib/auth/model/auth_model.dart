
import 'package:firebase_auth/firebase_auth.dart';
import 'package:milvertonrealty/common/domain/user.dart';
import 'package:milvertonrealty/common/model/common_model.dart';
import 'package:milvertonrealty/common/service.dart';

class AuthModel extends BaseModel{

  Future<ReUser> getReUser(User currentUser) async {
    // This line tells [Model] that it should rebuild the widgets that
    ReUser retVal = ReUser.getNullObj();
    try {
        final snapshot = await MR_DBService().getDBRef(ReUser.userRootDB +
            currentUser.uid ).get();
        if (snapshot.exists) {
          retVal = ReUser.fromMap(snapshot.value as Map<dynamic, dynamic>);
        }
    }
    catch (e) {
      print('Error getting Users from Firebase DB $e');
    }

    return retVal;
  }

  void updateFCMKeyForUser(ReUser reUser, String fcmKey) async {
    final dbPropertyReference = MR_DBService().getDBRef(reUser.getObjDBLocation() + "/");
    try{
      await dbPropertyReference.update({"fcmKey": fcmKey });
    }
    catch(e) {
      print('you Error saving User details ot an error $e');
    }
  }


}