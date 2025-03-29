import 'package:custom_radio_grouped_button/custom_radio_grouped_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:milvertonrealty/auth/components/customwidget.dart';
import 'package:milvertonrealty/auth/controller/register_controller.dart';
import 'package:milvertonrealty/common/component/custom_toggle.dart';
import 'package:milvertonrealty/utils/constants.dart';
import 'package:provider/provider.dart';


class SignupForm extends StatelessWidget {
  SignupForm({
    super.key,
    required this.controller,

  });

  final SignInController controller;

  @override
  Widget build(BuildContext context) {
    return Form(

      key: controller.signupFormKey,
      child: Column(
        children: [

          TextFormField(
            onSaved: (emal) {
              // Email
            },
            validator: (p0) => controller.nameValidation(p0),
            textInputAction: TextInputAction.next,
            keyboardType: TextInputType.name,
            controller: controller.nameController,
          
            decoration: InputDecoration(
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide:
                BorderSide(width: 2, color: ColorConstants.primaryColor),
              ),
              hintText: "Name",
              prefixIcon: Padding(

                padding:
                const EdgeInsets.symmetric(vertical: defaultPadding * 0.75),
                child: SvgPicture.asset(
                  "assets/icons/Profile.svg",
                  height: 24,
                  width: 24,
                  colorFilter: ColorFilter.mode(
                      Theme.of(context)
                          .textTheme
                          .bodyLarge!
                          .color!
                          .withOpacity(0.3),
                      BlendMode.srcIn),
                ),
              ),
            ),
          ),
          const SizedBox(height: defaultPadding),

          TextFormField(
            onSaved: (emal) {
              // Email
            },
            validator: (p0)=> controller.emailValidation(p0),
            textInputAction: TextInputAction.next,
            keyboardType: TextInputType.emailAddress,
            controller: controller.emailController,

            decoration: InputDecoration(
              hintText: "Email address",
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide:
                BorderSide(width: 2, color: ColorConstants.primaryColor),
              ),
              prefixIcon: Padding(
                padding:
                const EdgeInsets.symmetric(vertical: defaultPadding * 0.75),
                child: SvgPicture.asset(
                  "assets/icons/Message.svg",
                  height: 24,
                  width: 24,
                  colorFilter: ColorFilter.mode(
                      Theme.of(context)
                          .textTheme
                          .bodyLarge!
                          .color!
                          .withOpacity(0.3),
                      BlendMode.srcIn),
                ),
              ),
            ),
          ),
          const SizedBox(height: defaultPadding),

          TextFormField(
            onSaved: (pwd) {
              // Email
            },
            validator: (p0)=> controller.passwordValidation(p0),
            textInputAction: TextInputAction.next,
            keyboardType: TextInputType.visiblePassword,
            controller: controller.passwordController,
            obscureText: controller.hidePassword,
            decoration: InputDecoration(
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide:
                BorderSide(width: 2, color: ColorConstants.primaryColor),
              ),
              hintText: "password",
              suffixIcon: IconButton(
              onPressed: () {
             Provider.of<SignInController>(context, listen: false)
                 .togglePassword();
           },
           icon: Icon(
             Icons.remove_red_eye_outlined,
             color: ColorConstants.primaryColor.withOpacity(0.5),
           )),
              
              prefixIcon: Padding(
                padding:
                const EdgeInsets.symmetric(vertical: defaultPadding * 0.75),

                child: SvgPicture.asset(
                  "assets/icons/Lock.svg",
                  height: 24,
                  width: 24,
                  colorFilter: ColorFilter.mode(
                      Theme.of(context)
                          .textTheme
                          .bodyLarge!
                          .color!
                          .withOpacity(0.3),
                      BlendMode.srcIn),
                ),
              ),
            ),
          ),
          const SizedBox(height: defaultPadding),
///
          ///
          ///
          TextFormField(
            onSaved: (pwd) {
              // Email
            },
            validator: (p0)=> controller.confirmPasswordValidaton(p0),
            textInputAction: TextInputAction.next,
            keyboardType: TextInputType.visiblePassword,
            controller: controller.confirmPasswordController,
            obscureText: controller.hidePassword,
            decoration: InputDecoration(
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide:
                BorderSide(width: 2, color: ColorConstants.primaryColor),
              ),
              hintText: "password",
              suffixIcon: IconButton(
                  onPressed: () {
                    Provider.of<SignInController>(context, listen: false)
                        .togglePassword();
                  },
                  icon: Icon(
                    Icons.remove_red_eye_outlined,
                    color: ColorConstants.primaryColor.withOpacity(0.5),
                  )),

              prefixIcon: Padding(
                padding:
                const EdgeInsets.symmetric(vertical: defaultPadding * 0.75),

                child: SvgPicture.asset(
                  "assets/icons/Lock.svg",
                  height: 24,
                  width: 24,
                  colorFilter: ColorFilter.mode(
                      Theme.of(context)
                          .textTheme
                          .bodyLarge!
                          .color!
                          .withOpacity(0.3),
                      BlendMode.srcIn),
                ),
              ),
            ),
          ),
          ///
          const SizedBox(height: defaultPadding+5),     //SizedBox(width: 130,height: 200,
          Center(
            child: CustomToggleButtons(
              options: ['Tenant', 'Owner', 'Contractor'],
              onOptionSelected: (selected) {
                print('Selected option: $selected');
                controller.userType = selected;
              },
            ),
          ),
          ////
          const SizedBox(
            height: 40,
          ),
          Center(
            child: LoginButton(
              buttonName: "Sign up",
              onTap: () {
                if (controller.signupFormKey.currentState!.validate()) {
                  Provider.of<SignInController>(context, listen: false)
                      .signin(context);
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}


