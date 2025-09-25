// lib/providers/user_provider.dart
import 'package:flutter/foundation.dart';
import 'package:milvertonrealty/common/domain/user.dart';
import 'package:milvertonrealty/auth/model/auth_model.dart';


class UserProvider extends ChangeNotifier {
  final AuthModel _repo = AuthModel();
  List<ReUser> users = [];
  bool isLoading = true;

  UserProvider() {
    _repo.getUsersStream().listen((list) {
      users = list;
      isLoading = false;
      notifyListeners();
    });
  }

  Future<int> createUser(String name, String email, String role, String status) async{
    return _repo.createUser(name, email, role, status);

    //Based on user type add a business users object i.e Tenant, Contractor

  }

  Future<void> updateUser(ReUser user) => _repo.updateUser(user);

  Future<void> deleteUser(String id) => _repo.deleteUser(id);
}
