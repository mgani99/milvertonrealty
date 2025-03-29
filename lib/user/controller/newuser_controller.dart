import 'package:flutter/cupertino.dart';
import 'package:milvertonrealty/common/domain/user.dart';

class NewUserController with ChangeNotifier {
  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  final addressController = TextEditingController();
  String userType = "";

  bool hidePassword = true;
  bool rememberCredentials = false;
  GlobalKey<FormState> loginFormKey = GlobalKey<FormState>();

  bool isLoading = false;

  void setUserType(String values) {
    userType = values;
    print(values);
  }

  void saveUser(ReUser reUser) {

  }
}