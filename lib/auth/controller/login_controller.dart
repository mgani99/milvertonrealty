// ignore_for_file: use_build_context_synchronously

import 'package:firebase_auth/firebase_auth.dart';

import 'package:flutter/material.dart';
import 'package:milvertonrealty/auth/controller/auth_provider.dart';
import 'package:milvertonrealty/common/domain/user.dart';
import 'package:milvertonrealty/home/controller/app_data.dart';
import 'package:milvertonrealty/home/view/home_screen.dart';
import 'package:milvertonrealty/init_screens/full_screen_loader.dart';
import 'package:milvertonrealty/route/route_constants.dart';
import 'package:milvertonrealty/user/view/new_user.dart';
import 'package:milvertonrealty/utils/network_utility.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../common/domain/common.dart';
import '../../home/controller/bottomnavbar_controller.dart';
import '../../propertysetup/controller/propertyUnitController.dart';

class LoginController with ChangeNotifier {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool hidePassword = true;
  bool rememberCredentials = false;
  GlobalKey<FormState> loginFormKey = GlobalKey<FormState>();

  final ConnectionChecker connection = ConnectionChecker();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final loadingController = FullScreenLoader();
  bool isLoading = false;



  //----------------------------------------------------------------------------remember credentials
  remember() {
    rememberCredentials = !rememberCredentials;
    notifyListeners();
  }

  //----------------------------------------------------------------------------fetch stored credential credential
  fetchStordCredentials() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    emailController.text = prefs.getString('email') ?? "";
    passwordController.text = prefs.getString('password') ?? "";
    notifyListeners();
  }

  //----------------------------------------------------------------------------Login

  Future<void> login(BuildContext context) async {
    try {
      // start loading screen
      final authProvider =
      Provider.of<AuthenticationRepository>(context, listen: false);
      FullScreenLoader.openLoadinDialog(context);
      print("started");

      if (rememberCredentials) {
        final SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setString('email', emailController.text.trim());
        prefs.setString('password', passwordController.text.trim());
      }

      final credential = await _auth.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      if (credential.user != null && credential.user!.emailVerified) {
        ReUser reUser = await authProvider.authModel.fetchUsersByFirebaseId(credential.user!.uid);

        FullScreenLoader.stopLoadin(context);
        if (reUser ==  ReUser.getNullObj()) {
          FullScreenLoader.stopLoadin(context);
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text('User Authenticated but Not setup. Call Support')));
        }
        else {
          //update last login time and status from Inactive to Active

          //reUser!.fcmKey = fcmToken!;
          reUser.lastLogin = DateTime.now().millisecondsSinceEpoch;
          reUser.status= 'Active';
          authProvider.authModel.addObject(reUser);
          //get business object and set up AppData
          final appData = Provider.of<AppData>(context, listen: false);
          if (reUser.userType.toLowerCase() == 'tenant') {
            appData.settings['unitName'] = '';
            final propController  = Provider.of<PropertySetupController>(context, listen: false);
            Tenant tenant  =await propController.model.getTenantByUserId(reUser.id);
            if (tenant != Tenant.nullTenant()) {
              appData.settings['unitName'] = tenant.unitName;
            }
          }


          appData.currentUserName = reUser.name;
          appData.currentUserId = reUser.id.toString();
          appData.authToken = reUser.fireBaseId;
          appData.settings['role'] = reUser.userType;
          Provider.of<NavBarController>(context, listen: false).onNavTap(0);

          Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                builder: (context) => HomeScreen(),
              ),
                  (route) => false);
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Login Successful!')),
        );
      } else if (!credential.user!.emailVerified) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Please verify your email first!')),

        );
        FullScreenLoader.stopLoadin(context);
      }
      //Navigate to home page

    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No user found for that email.')));
      } else if (e.code == 'wrong-password') {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Wrong password provided for that user.')));
      } else {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('OOps ${e.code.toString()}')));
      }
      FullScreenLoader.stopLoadin(context);
    }
  }

//------------------------------------------------------------------------------hide password
  togglePassword() {
    hidePassword = !hidePassword;
    notifyListeners();
  }

//------------------------------------------------------------------------------email validation

  emailValidation(String value) {
    if (value.isEmpty) {
      return "Email is required.";
    } else if (!RegExp(r"^[a-zA-Z0-9+_.-]+@[a-zA-Z0-9.-]+$").hasMatch(value)) {
      return "Enter a valid email address.";
    } else {
      return null;
    }
  }
//------------------------------------------------------------------------------Password validation

  passwordValidation(value) {
    if (value == null || value.isEmpty) {
      return "Password is required.";
    } else if (value.length < 6) {
      return "Password must be atleast 6 character long";
    } else {
      return null;
    }
  }
}
