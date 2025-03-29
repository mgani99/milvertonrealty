import 'package:flutter/material.dart';
import 'package:milvertonrealty/auth/controller/auth_provider.dart';
import 'package:milvertonrealty/auth/view/login_screen2.dart';
import 'package:milvertonrealty/common/domain/user.dart';
import 'package:milvertonrealty/home/view/dashboard_page.dart';
import 'package:milvertonrealty/payment/view/payment_screen.dart';
import 'package:milvertonrealty/propertysetup/view/property_view.dart';
import 'package:milvertonrealty/propertysetup/view/propertysetup_screen.dart';
import 'package:milvertonrealty/propertysetup/view/unitsetup_screen.dart';
import 'package:milvertonrealty/repair/view/repair_screen.dart';
import 'package:milvertonrealty/user/view/new_user.dart';
import 'package:milvertonrealty/user/view/profile_page.dart';
import 'package:provider/provider.dart';


class NavBarController with ChangeNotifier {

  int selectedIndex = 0;

  List<Widget> ownerPages = [
    const DashBoardPage(),
    const LoginScreen2(),
    const NewUserPage(),
     PropertySetup(),
     PaymentTrackerHomePage(),
    const ProfilePage()
  ];

  void onNavTap(index) {
    selectedIndex = index;
    notifyListeners();
  }

  List<Widget> getPages(ReUser reUser) {
    if (reUser.name == Null || reUser.name.isEmpty) {
      return [const DashBoardPage(),
      const ProfilePage()];
    }
    else {
      if ("Owner" == reUser.userType) {
       return [ const DashBoardPage(),
         UnitSetupScreen(),
         RepairIssueScreen(),
          PropertyView(),
         PaymentTrackerHomePage(),
        const ProfilePage()];
      }
      else if ("Tenant" == reUser.userType || "Contractor" == reUser.userType ) {
        return [const DashBoardPage(),
         RepairIssueScreen(),
        const ProfilePage()];
      }

      else return [
          const DashBoardPage(),
          const ProfilePage()
        ];
    }
  }




}


