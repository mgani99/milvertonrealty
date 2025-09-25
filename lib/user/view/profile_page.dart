

import 'package:flutter/material.dart';
import 'package:milvertonrealty/auth/controller/auth_provider.dart';
import 'package:milvertonrealty/common/domain/user.dart';
import 'package:milvertonrealty/route/route_constants.dart';
import 'package:milvertonrealty/user/components/text_box.dart';
import 'package:provider/provider.dart';

import '../../components/role_dropdown_button.dart';
import '../../home/controller/bottomnavbar_controller.dart';



class ProfilePage extends StatefulWidget {

  const ProfilePage({super.key});

  @override
  State<StatefulWidget> createState() => _ProfilePageState();

}

class _ProfilePageState extends State<ProfilePage>{

  late final Future<List<ReUser>> _futureReUserList;
  late AuthenticationRepository ctrl;
  @override
  void initState() {
    super.initState();
     ctrl = Provider.of<AuthenticationRepository>(context, listen: false);
     ctrl.fetchUser();
    _futureReUserList = ctrl.authModel.fetchAllUsersByFirebaseId(ctrl.reUser!.fireBaseId);
  }
  void _onUserChanged(ReUser newUser) async{

      final list = await _futureReUserList;
      list.forEach((element) {
        if (element.userType != newUser.userType) {
          element.defaultUserType = false;
        }
        else {
          element.defaultUserType = true;
        }
        ctrl.authModel.updateUser(element);

      });
      ctrl.signOut();
      //Provider.of<NavBarController>(context, listen: false).onNavTap(0);
      Navigator.pushNamed(context, logInScreenRoute);


      // TODO: persist new defaultUserType in your backend or local storage

  }
  @override
  Widget build(BuildContext context) {
    final userController =     Provider.of<AuthenticationRepository>(context, listen: true);

    return Scaffold(
       backgroundColor: Colors.grey[300],
       appBar: AppBar(
         title: Text("Profile Page", style: TextStyle(color: Colors.blueGrey),),
         backgroundColor: Colors.grey[900],

       ),
      body: ListView(
        children: [
          const SizedBox(height: 10,),
          Center(
            child:
            ClipOval(
              child: Image.network('https://lh3.googleusercontent.com/d/12fgkcpdN0pGAMyLX6rLoF6NzODJHuhZk',
                fit: BoxFit.cover,
                width: 120,
                height: 120,),

            ),
          ),
          const SizedBox(height: 5,),
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
        FutureBuilder<List<ReUser>>(
        future: _futureReUserList,
        builder: (context, snap) {
          if (!snap.hasData) {
            return const Center(
                child: CircularProgressIndicator());
          }
          final list = snap.data!;
          return ReUserDropdownButton(
              currentUser: userController.reUser!,
              users: list,
              onUserChanged: _onUserChanged,




          );

        },
      ),


          SizedBox(height: 12,),
          userController.reUser!.userType == 'Owner' ? Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: () {

                Navigator.pushNamed(context, userDashboardRoute);
              },
              child: const Text(
                "User Management",
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                //padding: const EdgeInsets.only(left:15, bottom: 15),

                minimumSize: const Size.fromHeight(48),
              ),
            ),
          ) : Container(),
        ],
      ),


      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          child: ElevatedButton(
            onPressed: () {
              userController.signOut();
              //Provider.of<NavBarController>(context, listen: false).onNavTap(0);//to ensure re login will start form 0
              Navigator.pushNamed(context, logInScreenRoute);
            },
            child: const Text(
              "Log Out",
              style: TextStyle(fontSize: 16, color: Colors.white),
            ),
            style: ElevatedButton.styleFrom(
              minimumSize: const Size.fromHeight(48),
            ),
          ),
        ),
      ),
    ) ;
  }

}

