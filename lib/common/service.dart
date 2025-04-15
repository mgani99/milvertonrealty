

import 'dart:async';
import 'dart:io';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:milvertonrealty/common/domain/common.dart';


class MR_DBService extends ChangeNotifier{
  static String app_root= "MilvertonApp/";
  static final MR_DBService _instance = MR_DBService._internal();
  final database = FirebaseDatabase.instance.ref();
  MR_DBService._internal();
  final FirebaseService streamService = FirebaseService();
  factory MR_DBService() {
    if (!kIsWeb) {
      FirebaseDatabase.instance.setPersistenceEnabled(true);
    }



    return _instance;
  }


  void getPropertyStream(String ref, callBack) {
    streamService.listenToDatabase(app_root+ref, callBack);

    //{ print('value changed $event');});

  }


  void startListening(String ref) {
    streamService.listenToDatabase('path1', (event) {
      print('Data from path1: ${event.snapshot.value}');
    });
  }

    @override
  void dispose() {
    streamService.dispose();
    super.dispose();
  }


  DatabaseReference getDBRef(String location) {
    return database.child( MR_DBService.app_root + location);
  }
}

class FirebaseService {
  final DatabaseReference database = FirebaseDatabase.instance.ref();
  final List<StreamSubscription> _subscriptions = [];

  // Adding a StreamSubscription
  void listenToDatabase(String path, Function(DatabaseEvent) onData) {
    StreamSubscription subscription = database.child(path).onValue.listen(onData);
    _subscriptions.add(subscription); // Add subscription to the list
  }

  // Cancel all subscriptions
  void cancelAllSubscriptions() {
    for (var subscription in _subscriptions) {
      subscription.cancel();
    }
    _subscriptions.clear(); // Clear the list after canceling
  }

  // Example of usage
  void startListening() {
    listenToDatabase('path1', (event) {
      print('Data from path1: ${event.snapshot.value}');
    });

    listenToDatabase('path2', (event) {
      print('Data from path2: ${event.snapshot.value}');
    });
  }

  // Dispose method to clean up
  void dispose() {
    cancelAllSubscriptions();
  }
}
