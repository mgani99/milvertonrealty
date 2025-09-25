
import 'package:firebase_auth/firebase_auth.dart';
import 'package:milvertonrealty/common/domain/user.dart';
import 'package:milvertonrealty/common/model/common_model.dart';
import 'package:milvertonrealty/common/service.dart';
import 'package:firebase_database/firebase_database.dart';

import '../../common/domain/base_domain.dart';


class AuthModel extends BaseModel{


  final DatabaseReference _ref = MR_DBService().getDBRef(ReUser.userRootDB);

  Stream<List<ReUser>> getUsersStream() {
    return _ref.onValue.map((event) {
      // event.snapshot.children is Iterable<DataSnapshot>
      print(event.snapshot.children.map);
      return event.snapshot.children

          .map((snap) => ReUser.fromMap(Map<String, dynamic>.from(snap.value as Map)))
          .toList();
    });
  }


  Future<int> createUser(String name, String email, String role, status) async {
    final now = DateTime.now().millisecondsSinceEpoch;

    ReUser user = ReUser(ReUser.getId(email, role),
        name: name, emailAddress: email,
        userType: role, createdAt: now, lastLogin: now, status: status);
    //find other profile if any for the same user and copy the firebase id
    List<ReUser> otherProfile = await getReUserByEmail(email);
    bool sameIdAndRoleExist = false;
    otherProfile.forEach((usr){
      if (usr.status == 'Active' && usr.fireBaseId != null) {
        user.fireBaseId = usr.fireBaseId;
      }
      if (usr.emailAddress == user.emailAddress && usr.userType == user.userType) {
        sameIdAndRoleExist = true;
      }
    });

    (sameIdAndRoleExist) ? updateUser(user) : addObject(user);
    return user.id;
  }

  Future<void> updateUser(ReUser user) async {
    final dbPropertyReference = MR_DBService().getDBRef(user.getObjDBLocation() + "/");



    await dbPropertyReference.update({
      'name': user.name,
      'emailAddress': user.emailAddress,
      'userType': user.userType,
      'status': user.status,
      'createdAt' : user.createdAt,
      'lastLogin' : user.lastLogin,
      'defaultUserType' : user.defaultUserType,
      'fireBaseId' : user.fireBaseId,
    });
  }

  Future<void> deleteUser(String id) async {
    print('Removing ${id}');
    await _ref.child(id).remove();
  }




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

  Future<ReUser> fetchUsersByFirebaseId(String targetFirebaseId) async {
    List<ReUser> matching = await fetchAllUsersByFirebaseId(targetFirebaseId);
    ReUser retVal = ReUser.getNullObj();
    if (matching != null) {
      //find the default profile and return i
      for (int i=0; i< matching.length; i++){
        if (matching[i].defaultUserType && matching[i].status != 'Deleted')  {
          return matching[i];
        }
      }
    }
    return retVal;
  }

  Future<List<ReUser>> fetchAllUsersByFirebaseId(String targetFirebaseId) async {
    // 1. Read the snapshot at 'users' node
    final dbRef = MR_DBService().getDBRef(ReUser.userRootDB);
    final snapshot = await dbRef.get();

    // 2. Handle empty or missing data
    if (snapshot.value == null) {
      return [];
    }

    // 3. Cast the snapshot value to a Map
    final allUsersMap = Map<String, dynamic>.from(snapshot.value as Map);

    // 4. Convert & filter in one pass
    final matching = allUsersMap.values
        .map((raw) => ReUser.fromMap(Map<String, dynamic>.from(raw as Map)))
        .where((user) => user.fireBaseId == targetFirebaseId)
        .toList();
    return matching;
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

  Future<ReUser> getReUserByEmailAndRole(String email, String userType) async{
    // 1. Read the snapshot at 'users' node
    final dbRef = MR_DBService().getDBRef(ReUser.userRootDB);
    final snapshot = await dbRef.get();

    // 2. Handle empty or missing data
    if (snapshot.value == null) {
      return ReUser.getNullObj();
    }

    // 3. Cast the snapshot value to a Map
    final allUsersMap = Map<String, dynamic>.from(snapshot.value as Map);

    // 4. Convert & filter in one pass
    final matching = allUsersMap.values
        .map((raw) => ReUser.fromMap(Map<String, dynamic>.from(raw as Map)))
        .where((user) => user.emailAddress == email && user.userType == userType)
        .toList();
    return matching.length > 0 ? matching[0] : ReUser.getNullObj();
  }

  Future<List<ReUser>> getReUserByEmail(String email) async{
    final dbRef = MR_DBService().getDBRef(ReUser.userRootDB);
    final snapshot = await dbRef.get();

    // 2. Handle empty or missing data
    if (snapshot.value == null) {
      return [];
    }

    // 3. Cast the snapshot value to a Map
    final allUsersMap = Map<String, dynamic>.from(snapshot.value as Map);

    // 4. Convert & filter in one pass
    final matching = allUsersMap.values
        .map((raw) => ReUser.fromMap(Map<String, dynamic>.from(raw as Map)))
        .where((user) => user.emailAddress == email)
        .toList();
    return matching;
  }


}






class UserRepository {
  final DatabaseReference _ref = MR_DBService().getDBRef(ReUser.userRootDB);

  Stream<List<ReUser>> getUsersStream() {
    return _ref.onValue.map((event) {
      // event.snapshot.children is Iterable<DataSnapshot>
      print(event.snapshot.children.map);
      return event.snapshot.children

          .map((snap) => ReUser.fromMap(Map<String, dynamic>.from(snap.value as Map)))
          .toList();
    });
  }

  Future<void> addObject(BaseDomain baseDomain) async {
    final dbPropertyReference = MR_DBService().getDBRef(baseDomain.getObjDBLocation());
    try{
      await dbPropertyReference.update(baseDomain.toJson());
    }
    catch(e) {
      print('you Error saving User details ot an error $e');
    }

  }
  Future<void> createUser(String name, String email, String role, status) async {
    final now = DateTime.now().millisecondsSinceEpoch;

    ReUser user = ReUser(ReUser.getId(email, role),
        name: name, emailAddress: email,
        userType: role, createdAt: now, lastLogin: now, status: status);
    final dbPropertyReference = MR_DBService().getDBRef(user.getObjDBLocation() + "/");
    dbPropertyReference.update(user.toJson());
  }

  Future<void> updateUser(ReUser user) async {
    final now = DateTime.now().millisecondsSinceEpoch;

    final dbPropertyReference = MR_DBService().getDBRef(user.getObjDBLocation() + "/");



    await dbPropertyReference.update({
      'name': user.name,
      'emailAddress': user.emailAddress,
      'userType': user.userType,
      'status': user.status,
      'createdAt' : user.createdAt,
      'lastLogin' : user.lastLogin
    });
  }

  Future<void> deleteUser(String id) async {
    print('Removing ${id}');
    await _ref.child(id).remove();
  }





}
