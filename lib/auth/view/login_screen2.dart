import 'package:flutter/material.dart';
import 'package:milvertonrealty/auth/components/customwidget.dart';
import 'package:milvertonrealty/auth/components/login_form.dart';
import 'package:milvertonrealty/auth/controller/login_controller.dart';
import 'package:milvertonrealty/route/route_constants.dart';
import 'package:milvertonrealty/utils/constants.dart';


import 'package:provider/provider.dart';


class LoginScreen2 extends StatefulWidget {
  const LoginScreen2({super.key});

  @override
  State<LoginScreen2> createState() => _LoginScreen2State();
}

class _LoginScreen2State extends State<LoginScreen2> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    Provider.of<LoginController>(context, listen: false)
        .fetchStordCredentials();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(left: 20, right: 20, top: 20),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  "Welcome \n Back!",
                  style: TextStyle(
                      fontSize: 35,
                      color: ColorConstants.primaryBlackColor,
                      fontWeight: FontWeight.w900),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(
                  height: 20,
                ),
                LogInForm(formKey: _formKey,),
                const SizedBox(
                  height: 15,
                ),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Don't have an account? ", style: TextStyle(color: Colors.black87),),
                    // TextButton(
                    //
                    //     onPressed: () {
                    //       Navigator.pushNamed(context, signUpScreenRoute);
                    //       // Navigator.push(
                    //       //   context,
                    //       //   MaterialPageRoute(
                    //       //     builder: (context) => const SignupScreen (),
                    //       //   ),
                    //       // );
                    //     },
                    //     child: const Text("Signup Now"))
                    SizedBox(width: 150,
                      child: LoginButton(
                        buttonName: "Sign Up Now",
                        onTap: () {
                          Navigator.pushNamed(context, signUpScreenRoute);
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 20,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      height: 1,
                      color: greyColor,
                      width: MediaQuery.sizeOf(context).width * 35 / 100,
                    ),
                    Text(
                      "or",
                      style: TextStyle(color: Colors.black),
                    ),
                    Container(
                      height: 1,
                      width: MediaQuery.sizeOf(context).width * 35 / 100,
                      color: greyColor,
                    )
                  ],
                ),
                const SizedBox(
                  height: 20,
                ),
                InkWell(
                  onTap: () {
                    Provider.of<LoginController>(context, listen: false).login(context);
                  },
                  child: Container(
                    height: 47,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    color: successColor,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset("assets/images/google log.png"),
                        const SizedBox(
                          width: 10,
                        ),
                        Text(
                          "Sign in with Google",
                          style: TextStyle(
                              fontSize: 15,
                              color: Colors.black,
                              fontWeight: FontWeight.w500),
                        )
                      ],
                    ),
                  ),
                ),
                const SizedBox(
                  height: 40,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  // @override
  // void dispose() {
  //   _controller1.dispose();
  //   _controller2.dispose();
  //   super.dispose();
  // }
}
