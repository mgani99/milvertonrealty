import 'package:flutter/material.dart';
import 'package:milvertonrealty/auth/components/login_form.dart';
import 'package:milvertonrealty/auth/controller/login_controller.dart';
import 'package:milvertonrealty/route/route_constants.dart';
import 'package:milvertonrealty/utils/constants.dart';
import 'package:provider/provider.dart';


class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();

}

class _LoginScreenState extends State<LoginScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    Provider.of<LoginController>(context, listen: false)
        .fetchStordCredentials();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    final controller = Provider.of<LoginController>(context);
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            Image.asset(
              "assets/images/login_light.png",
              fit: BoxFit.cover,
            ),
            Padding(
              padding: const EdgeInsets.all(defaultPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Welcome back!",
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: defaultPadding / 2),
                  const Text(
                    "Log in with your data that you entered during your registration.",
                  ),
                  const SizedBox(height: defaultPadding),
                  LogInForm(formKey: _formKey),
                  Align(
                    child: TextButton(
                      child: const Text("Forgot password"),
                      onPressed: () {
                        Navigator.pushNamed(
                            context, passwordRecoveryScreenRoute);
                      },
                    ),
                  ),
                  SizedBox(
                    height: size.height > 700
                        ? size.height * 0.1
                        : defaultPadding,
                  ),
                  ElevatedButton(
                    onPressed: () {
                      if (controller.loginFormKey.currentState!.validate()) {
                        Provider.of<LoginController>(context, listen: false)
                            .login(context);
                      }
                    },
                    child: const Text("Log in"),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Don't have an account?"),
                      TextButton(
                        onPressed: () {
                          Navigator.pushNamed(context, signUpScreenRoute);
                        },
                        child: const Text("Sign up"),
                      )
                    ],
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
