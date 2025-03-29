
import 'package:http/http.dart';
import 'package:milvertonrealty/common/domain/common.dart';
import 'package:milvertonrealty/common/model/common_model.dart';
import 'package:milvertonrealty/common/service.dart';

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

  Future<List<Map<String, dynamic>>> getAllUnitsInJson() async{
    List<Map<String, dynamic>> retVal = [];
    try {
    final snapshot = await MR_DBService().getDBRef(Unit.rootDBLocation).get();
    final map = snapshot.value as Map<dynamic, dynamic>;
    map.forEach((key, value) async {
      final unitJson = value;

      final ldId = unitJson['currentLeaseId'];
      Map<String, dynamic>? ldJson = {};
      Map<String, dynamic>? tenantJson = {};
      if (ldId != 0) {
        ldJson = await getDomainById(ldId, LeaseDetails.rootDBLocation);
        var tenantId = ldJson!['tenantIds'];

        if (tenantId != null && tenantId[0] != 0) {
          tenantJson = await getDomainById(
              tenantId[0], Tenant.rootDBLocation);
        }
      }
      print(tenantJson);
      Map<String, dynamic> combinedJson = {
        ...unitJson,
        ...ldJson!,
        ...tenantJson!
      };
      print(combinedJson);
      retVal.add(combinedJson);

    });
    }
    catch(error) {print(error);};
    notifyListeners();
    return retVal;

  }
}