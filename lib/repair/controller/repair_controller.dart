
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:milvertonrealty/common/domain/Repair.dart';
import 'package:milvertonrealty/common/domain/user.dart';
import 'package:milvertonrealty/repair/model/repair_model.dart';
import 'package:milvertonrealty/repair/view/summary_chart.dart';

import '../../auth/controller/auth_provider.dart';
import '../../common/service.dart';

import 'package:flutter/material.dart';

import '../../home/controller/app_data.dart';

class RepairController extends ChangeNotifier {
   // tenant's unit
  final IssueRepository repo;

  IssueFilters filters = const IssueFilters();
  RepairController({
    required this.repo,

  }) {

  }



  // Tab definitions by role
  List<Tab> getTabs(String role)  {
    switch (role) {
      case 'tenant':
        return const [Tab(text: 'My issues'), Tab(text: 'Completed')];
      case 'contractor':
        return const [Tab(text: 'Assigned'), Tab(text: 'Available')];
      default:
        return const [Tab(text: 'All issues'),Tab(text: 'My Issues'),
          Tab(text: 'New Issue'),Tab(text: 'Summary')];
    }
  }

  // Stream for each tab index
  Stream<List<Issue>> streamFor(int index, AppData appData) {
    switch (appData.settings['role'].toString().toLowerCase()) {
      case 'tenant':
        return index == 0
            ? repo.tenantIssues(appData.settings['unitName'].toString())//@todo fixme
            : repo.tenantCompleted(appData.settings['unitName'].toString());//@todo fixme
      case 'contractor':
        return index == 0
            ? repo.contractorAssigned(appData.currentUserId.toString())
            : repo.contractorAvailable();
      default:
        //return
          //index == 0 ? repo.ownerAll() : repo.ownerAll();
          if (index == 0) {
            return repo.ownerAll();
          }
          else if (index == 1) {
            return repo.ownerAssigned(appData.currentUserId.toString());
          }
          else if (index ==2 ) {
            return repo.newUnassignedIssue();
          }
          else {
           // SummaryTab(stream: ,);
            return  repo.ownerAll();
          }
    }
  }


  // Optional trailing button per role+tab
  Widget? trailingFor(int index, Issue issue, ReUser reUser) {
    if (reUser.userType.toLowerCase() == 'contractor' && index == 0) {
      return ElevatedButton(
        onPressed: () => repo.updateStatus(
          issue.id,
          issue.status == 'In Progress' ? 'Completed' : 'In Progress',
        ),
        child: Text(
          issue.status == 'In Progress' ? 'Done' : 'Start',
        ),
      );
    }
    if (reUser.userType.toLowerCase() == 'contractor' && index == 1) {
      return OutlinedButton(
        onPressed: () => repo.assignToContractor(issue.id, reUser.id.toString(), 'Me'),
        child: const Text('Accept'),
      );
    }
    return null;
  }

  // Update filter state
  void updateFilters(IssueFilters f) {
    print('filter change');
    filters = f;


    notifyListeners();
  }

  void resetFilter(String role, int index) {
    if (role=='owner' && index == 1)
    filters = IssueFilters();
  }
}


