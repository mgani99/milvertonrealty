import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:milvertonrealty/auth/controller/auth_provider.dart';
import 'package:milvertonrealty/auth/view/signup_successfull_page.dart';
import 'package:milvertonrealty/init_screens/full_screen_loader.dart';
import 'package:milvertonrealty/utils/network_utility.dart';
import 'package:provider/provider.dart';

class SignInController with ChangeNotifier {
  GlobalKey<FormState> signupFormKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  bool hidePassword = true;
  final ConnectionChecker connection = ConnectionChecker();
  final loadingController = FullScreenLoader();
  String userType = "Tenant";

//------------------------------------------------------------------------------Register
  signin(context) async {
    try {
      FullScreenLoader.openLoadinDialog(context);
      //chec internet connection
      final isConnected = await connection.isConnected();
      final authProvider =
          Provider.of<AuthenticationRepository>(context, listen: false);

      if (!isConnected) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text("Network error")));
      }

      String? errorMessage = await authProvider.signUpWithEmailAndPassword(
          email: emailController.text.trim(),
          password: passwordController.text.trim(),
          userType: userType,
          name: nameController.text.trim()
      );

      if (errorMessage == null) {
        if (authProvider.userCredential.user?.uid != null) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const SignUpSuccessfullScreen(),
            ),
          );
        }
      } else {
        FullScreenLoader.stopLoadin(context);
        // Show error message to the user
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(errorMessage),
        ));
      }
      nameController.clear();
      emailController.clear();
      passwordController.clear();
      confirmPasswordController.clear();
    } on PlatformException catch (e) {
      if (e.code == 'weak-password') {
        return ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('The password provided is too weak.')));
      } else if (e.code == 'email-already-in-use') {
        return ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('The account already exists for that email.')));
      }
     // else if (e.code == 'FirebaseAuthMultiFactorException')
    } catch (e) {
      return ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("error $e")));
    } finally {}
  }

//------------------------------------------------------------------------------google signin

  signInWithGoogle(context) async {
    try {
      //start loading animation
      FullScreenLoader.openLoadinDialog(context);

      //checking internet connection
      final isConnected = await connection.isConnected();

      final authProvider =
          Provider.of<AuthenticationRepository>(context, listen: false);

      if (!isConnected) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text("Network error")));
      }

      //invoking signup function
      String? errorMessage = await authProvider.signInWithGoogle(context);
      // FullScreenLoader.stopLoadin(context);
      if (errorMessage != null) {
        // Show error message to the user
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(errorMessage),
        ));
      }
    } on PlatformException catch (e) {
      if (e.code == 'weak-password') {
        return ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('The password provided is too weak.')));
      } else if (e.code == 'email-already-in-use') {
        return ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('The account already exists for that email.')));
      }
    } catch (e) {
      print('error :$e');
    }
  }

// -----------------------------------------------------------------------------hide password
  togglePassword() {
    hidePassword = !hidePassword;
    notifyListeners();
  }

//------------------------------------------------------------------------------name form valitator

  nameValidation(value) {
    if (value == null || value.isEmpty) {
      return "Name is required.";
    } else {
      return null;
    }
  }
//------------------------------------------------------------------------------email validation

  emailValidation(value) {
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

  confirmPasswordValidaton(value) {
    if (passwordController.text != value) {
      return "Password not correct";
    }
    return null;
  }

  void setUserType(String values) {
    this.userType = values;
  }

  @override
  void dispose() {
    // TODO: implement dispose
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();

    super.dispose();
  }
}
