// ignore_for_file: avoid_print, use_build_context_synchronously


import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:milvertonrealty/auth/model/auth_model.dart';
import 'package:milvertonrealty/common/domain/user.dart';
import 'package:milvertonrealty/common/model/common_model.dart';


class AuthenticationRepository with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  late UserCredential userCredential;
  late UserCredential userCredentialGoogle;
  final AuthModel authModel = AuthModel();
  ReUser? reUser = ReUser.getNullObj();


//------------------------------------------------------------------------------sign in with Email and Password
  Future<String?> signUpWithEmailAndPassword(
      {required String email,
      required String password,
      required String userType,
      required String name}) async {
    try {
      //If this user is registered in the User, proceed.
      ReUser usr = await authModel.getReUserByEmailAndRole(email, userType);
      print(ReUser.getId(usr.emailAddress, userType));
      if (usr == ReUser.getNullObj()) return "User NOT Registered. Call Support";
      //Check if this users has other profile, make the other profile default to false.

      List<ReUser> otherProfiles =await authModel.getReUserByEmail(email);
      if (otherProfiles.length > 1){
        otherProfiles.forEach((aUsr) {
          if (aUsr.userType != usr.userType) {
            aUsr.defaultUserType = false;
            authModel.addObject(aUsr);
          }
        });
        return null;

      }

      userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      await userCredential.user!.sendEmailVerification();
      final now = DateTime.now().millisecondsSinceEpoch;
      //_auth.sendSignInLinkToEmail(email: email, actionCodeSettings: actionCodeSettings)
     // ReUser usr = ReUser(ReUser.getId(email, userType), name: name, emailAddress: email,
      //    userType: userType, createdAt: now, lastLogin: now, status: 'Active');
      usr.fireBaseId = userCredential.user!.uid;
      usr.lastLogin = now;
      usr.createdAt = now;
      authModel.addObject(usr);
      return null; // Return null for successful sign-up
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        return 'The password provided is too weak.';
      } else if (e.code == 'email-already-in-use') {
        return 'The account already exists for that email.';
      }
      return e.message; // Return error message for other exceptions
    } catch (e) {
      return 'Error: ${e.toString()}'; // Return generic error message for other exceptions
    }
  }

   fetchUser() async{
    if (_auth.currentUser != null) {
      reUser = await authModel.fetchUsersByFirebaseId(_auth.currentUser!.uid);
    }
    notifyListeners();
  }
//------------------------------------------------------------------------------signin with google
  Future<String?> signInWithGoogle(BuildContext context) async {
    try {
      final GoogleSignInAccount? userAccount = await GoogleSignIn().signIn();
      print(userAccount);
      final GoogleSignInAuthentication? googleAuth =
      await userAccount?.authentication;
      print(googleAuth);

      final credential = GoogleAuthProvider.credential(
          accessToken: googleAuth?.accessToken, idToken: googleAuth?.idToken);
      print(credential);
      userCredentialGoogle = await _auth.signInWithCredential(credential);
      print(userCredential);
      notifyListeners();

      // ignore: unnecessary_null_comparison
      if (userCredentialGoogle != null) {
        final userId = userCredentialGoogle.user!.uid;
      }


      // final bool isFirstTime = await newUserData['AccountSetupcompleted'];
/*

        if (!isFirstTime) {
          Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                builder: (context) => const AccountSetupScreen(),
              ),
              (route) => false);
        } else {
          Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                builder: (context) => const HomeScreen(),
              ),
              (route) => false);

*/

        // Return null for successful sign-up



    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        return 'The password provided is too weak.';
      } else if (e.code == 'email-already-in-use') {
        // Return 'The account already exists for that email.'
      }
      return e.message; // Return error message for other exceptions
    } catch (e) {
      print('Error: ${e.toString()}');
      return 'Error: ${e.toString()}'; // Return generic error message for other exceptions
    }
  }

  //----------------------------------------------------------------------------reset password

  Future<void> resetPassword({required String email}) async {
    try {
      //await _auth.sendSignInLinkToEmail(email: email, actionCodeSettings: actionCodeSettings)
      await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      print('Error: ${e.toString()}');
    }
  }
  //----------------------------------------------------------------------------Delete Account

  Future<void> deleteAccount() async {
    try {

      final curentUser = _auth.currentUser;
     // await user.deleteOwnerRecords(curentUser!.uid);
      await _auth.currentUser!.delete();
      await GoogleSignIn().signOut();
      await FirebaseAuth.instance.signOut();
    } catch (e) {
      print('Error: ${e.toString()}');
    }
  }

  Future<void> signOut() async {
    await GoogleSignIn().signOut();
    await FirebaseAuth.instance.signOut();

  }
}
