
import 'dart:convert';

import 'package:custom_radio_grouped_button/custom_radio_grouped_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:milvertonrealty/auth/controller/auth_provider.dart';
import 'package:milvertonrealty/common/domain/user.dart';
import 'package:milvertonrealty/user/components/custom_check_box.dart';
import 'package:milvertonrealty/user/components/text_box.dart';
import 'package:milvertonrealty/user/controller/newuser_controller.dart';
import 'package:milvertonrealty/utils/constants.dart';
import 'package:provider/provider.dart';


class NewUserPage extends StatefulWidget {

  const NewUserPage({super.key});

  @override
  State<StatefulWidget> createState() => _NewUserPage();

}

class _NewUserPage extends State<NewUserPage>{


  @override
  void initState() {
    super.initState();
    Provider.of<AuthenticationRepository>(context, listen: false).fetchUser();
  }
  @override
  Widget build(BuildContext context) {
    final userController =     Provider.of<AuthenticationRepository>(context, listen: true);
    final controller = Provider.of<NewUserController>(context);
    return Scaffold(
        backgroundColor: Colors.grey[300],
        appBar: AppBar(
          title: Text("User Setup", style: TextStyle(color: Colors.white),),
          backgroundColor: Colors.grey[900],
         ),
        body:
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                //padding: const EdgeInsets.only(left:15, bottom: 15, right: 15),
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [

                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 20,),
                      Center(
                        child: Icon(
                          Icons.person_add_alt_1,
                          size: 72,
                         ),
                      ),
                      const SizedBox(height: 5,),
                      Center(
                        child: Text(
                        userController.reUser!.emailAddress,
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey[700]),

                                      ),
                      ),
                      const SizedBox(height: 25,),



                          Text(
                            'My Details',
                            style: TextStyle(color:Colors.grey[700]),
                          ),


                        SizedBox(height: 10,),
                        TextFormField(
                          validator: firstNameValidator.call,
                          textInputAction: TextInputAction.next,
                          keyboardType: TextInputType.name,
                          controller: controller.nameController,

                          decoration: InputDecoration(
                            hintText: "Name",
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15),
                              borderSide:
                              BorderSide(width: 2, color: ColorConstants.primaryColor),
                            ),
                          ),
                        ),

                        SizedBox(height: 10,),
                        TextFormField(
                          validator: phoneValidator.call,
                          textInputAction: TextInputAction.next,
                          keyboardType: TextInputType.phone,
                          controller: controller.phoneController,

                          decoration: InputDecoration(
                            hintText: "Mobile Phone",
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15),
                              borderSide:
                              BorderSide(width: 2, color: ColorConstants.primaryColor),
                            ),
                          ),
                        ),
                        SizedBox(height: 30,),

                        CustomCheckBox(checkBoxButtonValues: (values ) { controller.setUserType(values); setState(() {

                        }); },),

                      SizedBox(height: 20,),

                    ],
                  ),


                  Padding(
                    padding: const EdgeInsets.only(bottom: 30.0),
                  child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey[400]),

                      onPressed: () {

                        //reUser = ReUser(, firstName: firstName, lastName: lastName, emailAddress: emailAddress, userType: userType)
                        ReUser updatedUser = ReUser(userController.reUser!.id,
                            emailAddress: userController.reUser!.emailAddress,
                            name: controller.nameController.text,
                            createdAt: userController.reUser!.createdAt,
                            lastLogin: userController.reUser!.lastLogin,
                            status: userController.reUser!.status,
                        userType: controller.userType,
                        );
                        updatedUser.fireBaseId = userController.reUser!.fireBaseId;

                        userController.authModel.addObject(updatedUser);
                        setState(() {

                        });
                      },

                      child: Text("Save",style: TextStyle(color: Colors.black38),)),),



                            ],
                          ),
              ),

      );

  }


}

