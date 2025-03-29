
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:milvertonrealty/auth/controller/auth_provider.dart';
import 'package:milvertonrealty/route/route_constants.dart';
import 'package:milvertonrealty/user/components/text_box.dart';
import 'package:provider/provider.dart';


class ProfilePage extends StatefulWidget {

  const ProfilePage({super.key});

  @override
  State<StatefulWidget> createState() => _ProfilePageState();

}

class _ProfilePageState extends State<ProfilePage>{


  @override
  void initState() {
    super.initState();
    Provider.of<AuthenticationRepository>(context, listen: false).fetchUser();
  }
  @override
  Widget build(BuildContext context) {
    final userController =     Provider.of<AuthenticationRepository>(context, listen: true);
    return Scaffold(
       backgroundColor: Colors.grey[300],
       appBar: AppBar(
         title: Text("Profile Page", style: TextStyle(color: Colors.white),),
         backgroundColor: Colors.grey[900],

       ),
      body: ListView(
        children: [
          const SizedBox(height: 30,),
          Icon(
            Icons.person_add_alt_1,
            size: 72,
          ),
          const SizedBox(height: 10,),
          Text(
            userController.reUser!.emailAddress,
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey[700]),

          ),
          const SizedBox(height: 40,),
          Padding(
              padding: const EdgeInsets.only(left:25.0),
              child: Text(
                '${userController.reUser!.userType} Details',
                style: TextStyle(color:Colors.grey[700]),
              ),
          ),

          UserProfileTextBox(
            text: userController.reUser!.name,
            sectionName: 'Name (First, Last)',
            onTap:() {},

          ),
          UserProfileTextBox(
            text: userController.reUser!.name,
            sectionName: 'Last Name',
            onTap:() {},

          ),
          UserProfileTextBox(
            text: userController.reUser!.userType,
            sectionName: 'User Role',
            onTap:() {},

          ),
            TextButton(
              onPressed: () {
                Navigator.pushNamed(context, logInScreenRoute);
              },
              child: const Text("Log Out"),
            )

        ],
      ),
    ) ;
  }


}