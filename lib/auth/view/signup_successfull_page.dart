import 'package:flutter/material.dart';
import 'package:milvertonrealty/auth/view/login_screen.dart';
import 'package:milvertonrealty/auth/view/login_screen2.dart';
import 'package:milvertonrealty/home/view/home_screen.dart';
import 'package:milvertonrealty/utils/constants.dart';

class SignUpSuccessfullScreen extends StatefulWidget {
  const SignUpSuccessfullScreen({super.key});

  @override
  State<SignUpSuccessfullScreen> createState() => _SignUpSuccessfullScreenState();
}

class _SignUpSuccessfullScreenState extends State<SignUpSuccessfullScreen> {
  @override
  void initState() {
    Future.delayed(const Duration(seconds: 3)).then(
      (value) {
        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (context) => const LoginScreen2(),
            ),
            (route) => false);
      },
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorConstants.primaryWhiteColor,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 50,
                backgroundColor: ColorConstants.primaryColor,
                child: Icon(
                  Icons.done,
                  size: 60,
                  color: ColorConstants.primaryWhiteColor,
                ),
              ),
              const SizedBox(
                height: 70,
              ),
              Text(
                "Sign Up \n Successful, Please Check your Email for verification",
                style: TextStyleConstants.loginTiltle,
                textAlign: TextAlign.center,
              ),
              const SizedBox(
                height: 10,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
