import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:milvertonrealty/auth/components/customwidget.dart';
import 'package:milvertonrealty/auth/controller/login_controller.dart';
import 'package:milvertonrealty/utils/constants.dart';
import 'package:provider/provider.dart';


class LogInForm extends StatelessWidget {
  const LogInForm({
    super.key,
    required this.formKey,
  });

  final GlobalKey<FormState> formKey;

  @override
  Widget build(BuildContext context) {
    final controller = Provider.of<LoginController>(context);
    return Form(
      key: controller.loginFormKey,
      child: Column(
        children: [
          TextFormField(
            onSaved: (emal) {
              // Email
            },
            validator: emaildValidator.call,
            textInputAction: TextInputAction.next,
            keyboardType: TextInputType.emailAddress,
            controller: controller.emailController,

            decoration: InputDecoration(
              hintText: "Email address",
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
            onSaved: (pass) {
              // Password
            },
            controller: controller.passwordController,
            validator: (value) =>
                Provider.of<LoginController>(context, listen: false)
                    .passwordValidation(value!),
            obscureText: true,
            decoration: InputDecoration(
              hintText: "Password",
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
          Row(
            children: [
              Checkbox(
                activeColor: Colors.black45,
                value: Provider.of<LoginController>(context)
                    .rememberCredentials,
                onChanged: (value) {
                  Provider.of<LoginController>(context, listen: false)
                      .remember();
                },
              ),
              const Text("Remember", style: TextStyle(color: Colors.black87),)
            ],
          ),

          const SizedBox(
            height: 15,
          ),
          LoginButton(
            buttonName: "Login",
            onTap: () {
              if (controller.loginFormKey.currentState!.validate()) {
                Provider.of<LoginController>(context, listen: false)
                    .login(context);
              }
            },
          ),

        ],
      ),
    );
  }
}
