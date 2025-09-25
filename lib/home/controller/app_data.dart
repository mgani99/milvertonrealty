import 'package:flutter/foundation.dart';

class AppData extends ChangeNotifier {
  // Example “frequently used” fields
  String? authToken;
  String? currentUserName;
  String? currentUserId;
  Map<String, dynamic> settings = {};

  // When you update something, call notifyListeners()
  void updateToken(String token) {
    authToken = token;
    notifyListeners();
  }
}
