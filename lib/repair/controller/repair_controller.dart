
import 'package:flutter/cupertino.dart';
import 'package:milvertonrealty/common/domain/Repair.dart';
import 'package:milvertonrealty/repair/model/repair_model.dart';

class RepairController with ChangeNotifier {
  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  final addressController = TextEditingController();
  String userType = "";

  bool hidePassword = true;
  bool rememberCredentials = false;
  GlobalKey<FormState> loginFormKey = GlobalKey<FormState>();

  bool isLoading = false;
  final RepairModel model = RepairModel();

  void setUserType(String values) {
    userType = values;
    print(values);
  }

  @override
  void dispose() {
    nameController.dispose();
    phoneController.dispose();
    addressController.dispose();
    super.dispose();
  }

  List<Repair> createRepairFromView(String room, List<String> categories) {
    List<Repair> retVal = [];
    categories.forEach((category) {
      Repair repair = Repair(0, title: room, description: category, unit: 'A9',
          dateOfIssue: DateTime.now(), status: "Pending");
      retVal.add(repair);

    });
    return retVal;
  }

  void saveRepair(List<String> rooms, Map<String, List<String>?> selectedSubcategories) {
    rooms.forEach((room) {
      List<Repair> repairsForRoom= createRepairFromView(room, selectedSubcategories[room]!);
      repairsForRoom.forEach((repair) {
        model.addObject(repair);
      });
    });

  }

  Future<Map<String, List<String>>> getRepairCategory() async{
    return model.getRepairCategory();
  }
}