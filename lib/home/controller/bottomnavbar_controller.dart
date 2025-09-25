import 'package:flutter/material.dart';
import 'package:milvertonrealty/auth/controller/auth_provider.dart';
import 'package:milvertonrealty/auth/view/login_screen2.dart';
import 'package:milvertonrealty/common/domain/user.dart';
import 'package:milvertonrealty/home/view/dashboard_page.dart';
import 'package:milvertonrealty/payment/payment_tracker.dart';
import 'package:milvertonrealty/payment/view/payment_screen.dart';
import 'package:milvertonrealty/payment/view/payment_tracker_screen.dart';
import 'package:milvertonrealty/propertysetup/view/property_view.dart';
import 'package:milvertonrealty/propertysetup/view/propertysetup_screen.dart';
//import 'package:milvertonrealty/propertysetup/view/tenant_lead.dart';
import 'package:milvertonrealty/propertysetup/view/unitsetup_screen.dart';
import 'package:milvertonrealty/repair/model/repair_model.dart';
import 'package:milvertonrealty/repair/view/repair_screen.dart';
import 'package:milvertonrealty/repair/view/repair_screen_owner.dart';
import 'package:milvertonrealty/user/view/new_user.dart';
import 'package:milvertonrealty/user/view/profile_page.dart';
import 'package:provider/provider.dart';

import '../../expenses/view/expense_home.dart';

import '../../propertysetup/view/tenant_lead2.dart';
import '../../repair/view/issue_role_dashboard.dart';
import 'app_data.dart';


class NavBarController with ChangeNotifier {
  int selectedIndex = 0;

  List<Widget> ownerPages = [
    const DashBoardPage(),
    const LoginScreen2(),
    const NewUserPage(),
     PropertySetup(),
    PaymentScreen(),
    const ProfilePage()
  ];

  void onNavTap(index) {
    selectedIndex = index;
    notifyListeners();
  }

  List<Widget> getPages(AppData appData) {
    if (appData.currentUserName == Null || appData.currentUserName!.isEmpty) {
      return [const DashBoardPage(),
      const ProfilePage()];
    }
    else {
      if ("owner" == appData.settings['role'].toString().toLowerCase()) {
       return [ const DashBoardPage(),
         TenantLeadHomePage(),
         RoleDashboard(),
         ExpenseSummaryPage(),
          PropertyView(),
         PaymentListPage(),
        const ProfilePage()];
      }

      else if ("tenant" == appData.settings['role'].toString().toLowerCase() ||
          "contractor" == appData.settings['role'].toString().toLowerCase() ) {
        return [const DashBoardPage(),
          RoleDashboard(),
        const ProfilePage()];
      }

      else return [
          const DashBoardPage(),
          const ProfilePage()
        ];
    }
  }




}


