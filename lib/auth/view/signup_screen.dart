import 'package:flutter/material.dart';
import 'package:milvertonrealty/auth/components/signin_form.dart';
import 'package:milvertonrealty/auth/controller/register_controller.dart';
import 'package:milvertonrealty/utils/constants.dart';
import 'package:provider/provider.dart';

class SignupScreen extends StatelessWidget {
  const SignupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    //final controller = Provider.of<SignInController>(context);
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Container(
        height: double.infinity,
        width: double.infinity,
        decoration: BoxDecoration(

          gradient: LinearGradient(
            colors: [
              ColorConstants.primaryColor,
              ColorConstants.secondaryWhiteColor2,
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: Column(
            children: [


              SizedBox(
                height: 120,width: double.infinity,
                child: Image.asset(
                  ImageConstants.appLogo,
                  fit: BoxFit.cover,
                ),
              ),

              SafeArea(
                child: Container(
                  height: MediaQuery.sizeOf(context).height * 75 / 100,
                  width: MediaQuery.sizeOf(context).width * 90 / 100,
                  decoration: BoxDecoration(
                    color: ColorConstants.secondaryWhiteColor2,
                    borderRadius: BorderRadius.circular(30),

                  ),

                  padding: const EdgeInsets.only(left: 20, right: 20, bottom: 15),
                  child: SingleChildScrollView(
                    child: Column(
                      children: [

                         // Image.asset(
                         //   ImageConstants.appLogo,
                         //  fit: BoxFit.cover,
                         //  ),
                        // SizedBox(
                        //     height: 120,
                        //     width: 420,
                        //     child: Image.asset(ImageConstants.appLogo)),
                        const SizedBox(
                          height: 10,
                        ),
                        Text(
                          "Sign up",
                          style: TextStyle(
                              color: ColorConstants.primaryColor,
                              fontSize: 25,
                              fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        SignupForm(controller: Provider.of<SignInController>(context)),
                        const SizedBox(
                          height: 20,
                        ),
                        // Row(
                        //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        //   children: [
                        //     Container(
                        //       height: 1,
                        //       color: ColorConstants.roomsBlackColor,
                        //       width: MediaQuery.sizeOf(context).width * 35 / 100,
                        //     ),
                        //     Text(
                        //       "or",
                        //       style: TextStyle(color: ColorConstants.roomsBlackColor),
                        //     ),
                        //     Container(
                        //       height: 1,
                        //       width: MediaQuery.sizeOf(context).width * 35 / 100,
                        //       color: ColorConstants.roomsBlackColor,
                        //     )
                        //   ],
                        // ),
                        // const SizedBox(
                        //   height: 10,
                        // ),
                        // InkWell(
                        //   onTap: () =>
                        //       Provider.of<SignInController>(context, listen: false)
                        //           .signInWithGoogle(context),
                        //   child: Container(
                        //     height: 47,
                        //     padding: const EdgeInsets.symmetric(vertical: 14),
                        //     color: ColorConstants.secondaryWhiteColor,
                        //     child: Row(
                        //       mainAxisAlignment: MainAxisAlignment.center,
                        //       children: [
                        //         Image.asset(ImageConstants.googleLogo),
                        //         const SizedBox(
                        //           width: 10,
                        //         ),
                        //         Text(
                        //           "Sign in with Google",
                        //           style: TextStyleConstants.dashboardDate,
                        //         )
                        //       ],
                        //     ),
                        //   ),
                        // ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
