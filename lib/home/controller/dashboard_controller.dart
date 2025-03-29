// ignore_for_file: avoid_print

import 'package:flutter/material.dart';

import 'package:intl/intl.dart';

class DashboardController with ChangeNotifier {
 /*// UserModel? user = OwnerModel.empty();
  List<Map<String, int>> roomsGoingtoVacant = [];
  String selectedValue = "This Week";
  int selectedDays = 7;
  List<String> sortingItems = ["This Week", "This Month", "This Year"];
  bool isFilterLoading = false;
  bool isPaymentsLoading = false;
  List<ResidentModel> allResidents = [];
  List<ResidentModel> rentPendingResidents = [];
  List<ResidentModel> paymentDueResidents = [];
  List<Map<String, dynamic>> pendingPayments = [];
  int totalPentingAmount = 0;

  final UserRepository controller = UserRepository();
  final ResidentsRepository residentsRepository = ResidentsRepository();
  final roomController = RoomsRepository();*/

//------------------------------------------------------------------------------Fetch vacating Rooms

  getVacatingRooms() async {

  }
//------------------------------------------------------------------------------Update Pending payments

  updatePendingPayments() async {

  }
//------------------------------------------------------------------------------get Vacancy Count



  //----------------------------------------------------------------------------Convert rent pending residents to map

  String date() {
    return DateFormat('dd/MM/yyyy').format(DateTime.now());
  }
}
