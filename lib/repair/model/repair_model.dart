
import 'package:firebase_database/firebase_database.dart';
import 'package:milvertonrealty/common/domain/base_domain.dart';
import 'package:milvertonrealty/common/model/common_model.dart';
import 'package:milvertonrealty/common/service.dart';

class RepairModel extends BaseModel {

  static String categoryRoot = "RepairCategories/";
  Future<Map<String, List<String>>> getRepairCategory() async {
    try {
      // Access the "categories" node in the database
      final DataSnapshot snapshot = await MR_DBService().getDBRef(categoryRoot).get();

      // Check if data exists
      if (snapshot.exists) {
        final rawData = Map<String, dynamic>.from(snapshot.value as Map);

        // Convert to Map<String, List<String>>
        return rawData.map((key, value) =>
            MapEntry(key, List<String>.from(value as List)));
      } else {
        print("No data found!");
        return {};
      }
    } catch (e) {
      print("Error fetching data: $e");
      return {};
    }
  }

}