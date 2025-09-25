

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:milvertonrealty/auth/controller/auth_provider.dart';
import 'package:milvertonrealty/common/domain/user.dart';
import 'package:milvertonrealty/home/controller/app_data.dart';
import 'package:milvertonrealty/home/controller/bottomnavbar_controller.dart';
import 'package:milvertonrealty/route/route_constants.dart';
import 'package:milvertonrealty/utils/constants.dart';
import 'package:provider/provider.dart';

import '../../propertysetup/controller/propertyUnitController.dart';

class HomeScreen extends StatefulWidget {

  const HomeScreen({super.key});
  @override
  State<StatefulWidget> createState() => _HomeScreen();

}
class _HomeScreen extends State<HomeScreen> {
  bool usrIsSetup = false;
  String? fcmToken;
  @override
  void initState() {
    super.initState();
    final controller = Provider.of<AuthenticationRepository>(context, listen: false);

    controller.fetchUser();
    requestPermission();
    getFCMToken();
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      //print("🔹 Foreground Message: ${message.notification?.title}");
      controller.authModel.updateFCMKeyForUser(controller.reUser!, fcmToken!);


    });

  }

  void requestPermission() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;
    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print("User granted permission");

    } else {
      print("User denied permission");
    }
  }

  // Get FCM Token
  void getFCMToken() async {
    fcmToken = await FirebaseMessaging.instance.getToken();
    print("FCM Token: $fcmToken");

  }

  @override
  Widget build(BuildContext context) {
    final appData = Provider.of<AppData>(context, listen: true);
    NavBarController navBarController = Provider.of<NavBarController>(context);
    //navBarController.selectedIndex = 0;

    return Scaffold(
      backgroundColor: ColorConstants.primaryWhiteColor,
      body: Provider.of<NavBarController>(context)
          .getPages(appData)[Provider.of<NavBarController>(context).selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        elevation: 0,
        backgroundColor: ColorConstants.primaryWhiteColor,
        type: BottomNavigationBarType.fixed,
        currentIndex: navBarController.selectedIndex,
        onTap: (value) {
          Provider.of<NavBarController>(context, listen: false).onNavTap(value);
        },
        selectedLabelStyle: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: ColorConstants.primaryBlackColor),
        selectedItemColor: ColorConstants.primaryBlackColor,
        unselectedItemColor: ColorConstants.primaryBlackColor,
        unselectedLabelStyle: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w400,
            color: ColorConstants.primaryBlackColor),
        unselectedIconTheme:
        IconThemeData(size: 25, color: ColorConstants.primaryBlackColor),
        selectedIconTheme:
        IconThemeData(size: 25, color: ColorConstants.primaryBlackColor),
        items: getBottomNavBarItemsForUser(appData, navBarController),


      ),
    );
  }

  List<BottomNavigationBarItem> getBottomNavBarItemsForUser(AppData appData, NavBarController navBarController ) {
    List<BottomNavigationBarItem> retVal = [];
    retVal.add(getHome(navBarController,0));

    if (appData.currentUserName!.isNotEmpty) {
      //if User is setup, for Owner show Home, Property, Income, Expense, Repairs, Profile
      //for Contractor Home, Repair, Profile
      if ("tenant" == appData.settings['role'].toString().toLowerCase() ||
          "contractor" == appData.settings['role'].toString().toLowerCase()) {
        retVal.add(getRepair(navBarController,1));
        retVal.add(getProfile(navBarController,2));

      }
      else if ("owner" == appData.settings['role'].toString().toLowerCase()) {
        retVal.add(getTenantLeads(navBarController, 1));
        retVal.add(getRepair(navBarController,2));
        retVal.add(getExpense(navBarController,3));
        retVal.add(getProperty(navBarController,4));
        retVal.add(getPayment(navBarController,5));
        retVal.add(getProfile(navBarController,6));




      }
      //for Tenant  Repair, PaymentHistory


    }
    else {
      retVal.add(getExpense(navBarController,1));
    }
    //If usr isn't setup, just show Home and Profile





    return retVal;
  }

  BottomNavigationBarItem getHome(NavBarController navBarController,int selectIndex) {
    return BottomNavigationBarItem(
        icon: Icon(
          navBarController.selectedIndex == selectIndex
              ? FluentIcons.home_12_filled
              : FluentIcons.home_12_regular,
        ),
        label: 'Home');
  }

  BottomNavigationBarItem getProperty(NavBarController navBarController,int selectIndex) {
    return BottomNavigationBarItem(
        icon: Icon(
          navBarController.selectedIndex == selectIndex
              ? FluentIcons.building_16_filled
              : FluentIcons.building_16_regular,
        ),
        label: 'Property');
  }
  BottomNavigationBarItem getPayment(NavBarController navBarController,int selectIndex) {
    return BottomNavigationBarItem(
        icon: Icon(
          navBarController.selectedIndex == selectIndex
              ? FluentIcons.payment_16_filled
              : FluentIcons.payment_16_regular,
        ),
        label: 'Payment');
  }


  BottomNavigationBarItem getTenantLeads(NavBarController navBarController,int selectIndex) {
    return BottomNavigationBarItem(
        icon: Icon(
          navBarController.selectedIndex == selectIndex
              ? FluentIcons.door_16_filled
              : FluentIcons.conference_room_24_regular,
        ),
        label: 'Tenant \nLeads');
  }

  BottomNavigationBarItem getRepair(NavBarController navBarController,int selectIndex) {
    return BottomNavigationBarItem(
        icon: Icon(
          navBarController.selectedIndex == selectIndex
              ? Icons.handyman_outlined
              : Icons.handyman_rounded,
        ),
        label: 'Repair');
  }

  BottomNavigationBarItem getProfile(NavBarController navBarController,int selectIndex) {
      return BottomNavigationBarItem(
        icon: Icon(
          navBarController.selectedIndex == selectIndex
              ? FluentIcons.person_accounts_20_filled
              : Icons.person,
        ),
        label: 'Profile',
      );
  }
  BottomNavigationBarItem getExpense(NavBarController navBarController, int selectIndex) {
    return BottomNavigationBarItem(
        icon: Icon(
          navBarController.selectedIndex == selectIndex
              ? FluentIcons.book_contacts_20_filled
              : FluentIcons.book_contacts_20_regular,
          color: ColorConstants.primaryBlackColor,
          size: 27,
        ),
        label: 'Expense');
  }

}
