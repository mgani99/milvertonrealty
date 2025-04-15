import 'dart:ui';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:milvertonrealty/auth/controller/auth_provider.dart';
import 'package:milvertonrealty/auth/controller/login_controller.dart';
import 'package:milvertonrealty/auth/controller/register_controller.dart';
import 'package:milvertonrealty/common/component/custom_toggle.dart';
import 'package:milvertonrealty/firebase_options.dart';
import 'package:milvertonrealty/home/controller/bottomnavbar_controller.dart';
import 'package:milvertonrealty/home/controller/dashboard_controller.dart';
import 'package:milvertonrealty/payment/controller/payment_controller.dart';
import 'package:milvertonrealty/propertysetup/controller/propertyUnitController.dart';
import 'package:milvertonrealty/repair/controller/repair_controller.dart';
import 'package:milvertonrealty/route/route_constants.dart';
import 'package:milvertonrealty/theme/app_theme.dart';
import 'package:milvertonrealty/route/router.dart' as router;
import 'package:milvertonrealty/user/controller/newuser_controller.dart';
import 'package:provider/provider.dart';



class MyCustomScrollBehavior extends MaterialScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => {
    PointerDeviceKind.touch,
    PointerDeviceKind.mouse,
  };
}


void main()  async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  /*runApp(MaterialApp(
    scrollBehavior: MyCustomScrollBehavior(), // Assign your custom scroll behavior
    home: MyApp(),
  ));*/
  runApp(
      //scrollBehavior: MyCustomScrollBehavior(),
      MyApp());
}
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print("Received background message: ${message.notification?.title}");
}
// Thanks for using our template. You are using the free version of the template.
// 🔗 Full template: https://theflutterway.gumroad.com/l/fluttershop

class MyApp extends StatelessWidget {

  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(providers: [
      ChangeNotifierProvider(create:  (context) => LoginController(),),
      ChangeNotifierProvider(create: (context) => SignInController(),),
      ChangeNotifierProvider(create: (context) => AuthenticationRepository(),),
      ChangeNotifierProvider(create: (context) => NavBarController(),),
      ChangeNotifierProvider(create: (context) => DashboardController(),),
      ChangeNotifierProvider(create: (context) => NewUserController(),),
      ChangeNotifierProvider(create: (context) => RepairController(),),
      ChangeNotifierProvider(create: (context) => PropertySetupController()),
      ChangeNotifierProvider(create: (context) { return PaymentProvider();}),


    ],

      child: MaterialApp(
        scrollBehavior: MyCustomScrollBehavior(),

        debugShowCheckedModeBanner: false,
      title: 'Milverton Realty -  App',
      theme: AppTheme.lightTheme(context),
      // Dark theme is inclided in the Full template
      themeMode: ThemeMode.light,
      onGenerateRoute: router.generateRoute,
      initialRoute: logInScreenRoute,
    ));
  }
}
