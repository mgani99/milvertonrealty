
import 'package:flutter/material.dart';
import 'package:milvertonrealty/auth/controller/auth_provider.dart';
import 'package:milvertonrealty/common/domain/user.dart';
import 'package:milvertonrealty/propertysetup/controller/propertyUnitController.dart';
import 'package:milvertonrealty/user/view/new_user.dart';
import 'package:milvertonrealty/utils/constants.dart';
import 'package:provider/provider.dart';

class DashBoardPage extends StatefulWidget {
  const DashBoardPage({super.key});

  @override
  State<DashBoardPage> createState() => _DashBoardPageState();
}

class _DashBoardPageState extends State<DashBoardPage>
    with TickerProviderStateMixin {

  bool _isSearching = false;
  @override
  void initState() {

    super.initState();

    Provider.of<AuthenticationRepository>(context, listen: false).fetchUser();

  }
  /*
  appBar: AppBar(
        title: Text(
          'Milverton Realty',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.grey,
        actions: [
          IconButton(
            icon: Icon(Icons.search, color: Colors.white),
            onPressed: () {
              // Add search functionality here
            },
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              // Add menu functionality here
            },
            itemBuilder: (BuildContext context) {
              return {'Option 1', 'Option 2', 'Option 3'}
                  .map((String choice) {
                return PopupMenuItem<String>(
                  value: choice,
                  child: Text(choice),
                );
              }).toList();
            },
          ),
        ],
      ),
      body: Center(
        child: Text('Welcome to Milverton Realty!'),
   */

  @override
  Widget build(BuildContext context) {

    final controller =     Provider.of<AuthenticationRepository>(context, listen: true);
    //final propertyUnitController = Provider.of<PropertySetupController>(context, listen: false);
    ReUser usr = controller.reUser!;
    return Scaffold(
      //ackgroundColor: ColorConstants.primaryWhiteColor,
      appBar: AppBar(
        title: Text(
          'Milverton Realty',
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.grey,
        actions: [
          AnimatedContainer(
            duration: Duration(milliseconds: 300),
            width: _isSearching ? 200.0 : 0.0,
            child: _isSearching
                ? TextField(
              autofocus: true,
              style: TextStyle(color: Colors.black),
              decoration: InputDecoration(
                hintText: 'Search...',
                hintStyle: TextStyle(color: Colors.black),
                border: InputBorder.none,
              ),
            )
                : null,
          ),
          IconButton(
            icon: Icon(
              _isSearching ? Icons.close : Icons.search,
              color: Colors.white,
            ),
            onPressed: () {
              setState(() {
                _isSearching = !_isSearching;
              });
            },
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              // Add menu functionality here
            },
            itemBuilder: (BuildContext context) {
              return {'Option 1', 'Option 2', 'Option 3'}
                  .map((String choice) {
                return PopupMenuItem<String>(
                  value: choice,
                  child: Text(choice),
                );
              }).toList();
            },
          ),
        ],
        automaticallyImplyLeading: true,
        //backgroundColor: ColorConstants.primaryWhiteColor,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(
                height: 10,
              ),
              Padding(
                padding: EdgeInsets.symmetric(
                    horizontal: MediaQuery.sizeOf(context).width * 11 / 100),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    (usr.name.isEmpty) ? TextButton(
                        onPressed: (){ Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>  const NewUserPage()));},
                        child: Text("Click here to Setup User Profile", style: TextStyle(color: Colors.red))) : Text("Welcome ${usr.name}",
                      style: TextStyleConstants.homeMainTitle1,
                    ),
                   //Request Access to Apartment or Create Portfolio
                    //Text(propertyUnitController.unitData.length.toString() as String),
                    //(usr.userType == "Owner") ?

                  ],
                ),
              ),
              const SizedBox(
                height: 20,
              ),

            ],

          ),

        ),
      ),
    );
  }

  @override
  void dispose() {

    super.dispose();
  }
}
