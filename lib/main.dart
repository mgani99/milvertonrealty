import 'dart:ui';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:milvertonrealty/auth/controller/auth_provider.dart';
import 'package:milvertonrealty/auth/controller/login_controller.dart';
import 'package:milvertonrealty/auth/controller/register_controller.dart';
import 'package:milvertonrealty/common/component/custom_toggle.dart';
import 'package:milvertonrealty/common/service.dart';
import 'package:milvertonrealty/firebase_options.dart';
import 'package:milvertonrealty/home/controller/bottomnavbar_controller.dart';
import 'package:milvertonrealty/home/controller/dashboard_controller.dart';
import 'package:milvertonrealty/payment/controller/payment_controller.dart';
import 'package:milvertonrealty/propertysetup/controller/propertyUnitController.dart';
import 'package:milvertonrealty/repair/controller/repair_controller.dart';
import 'package:milvertonrealty/repair/model/repair_model.dart';
import 'package:milvertonrealty/route/route_constants.dart';
import 'package:milvertonrealty/theme/app_theme.dart';
import 'package:milvertonrealty/route/router.dart' as router;
import 'package:milvertonrealty/user/controller/newuser_controller.dart';
import 'package:milvertonrealty/user/controller/user_provider.dart';
import 'package:provider/provider.dart';

import 'home/controller/app_data.dart';
import 'issue_importer.dart';



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
  runApp(MyApp());
  doWork();
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
      ChangeNotifierProvider(create:  (context) => AppData(),),
      ChangeNotifierProvider(create: (context) => SignInController(),),
      ChangeNotifierProvider(create: (context) => AuthenticationRepository(),),
      ChangeNotifierProvider(create: (context) => NavBarController(),),
      ChangeNotifierProvider(create: (context) => DashboardController(),),
      ChangeNotifierProvider(create: (context) => NewUserController(),),

      ChangeNotifierProvider(create: (context) => PropertySetupController()),
      ChangeNotifierProvider(create: (context) => UserProvider()),

      ChangeNotifierProvider(create: (context) { return PaymentProvider();}),
      ChangeNotifierProvider(create: (context) { return RepairController(repo: IssueRepository());}),

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



Future<void> doWork() async {
  // Ensure Flutter’s widget framework is initialized before calling Firebase code.
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  //loadIssue();
  // References to our database paths.
  final DatabaseReference databaseRef = FirebaseDatabase.instance.ref();

}

