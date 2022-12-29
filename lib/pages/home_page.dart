
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:groupie_chatapp/pages/profile_page.dart';
import 'package:groupie_chatapp/pages/search_page.dart';
import 'package:groupie_chatapp/services/database_service.dart';
import 'package:groupie_chatapp/utils/AppPref.dart';
import 'package:groupie_chatapp/utils/constants.dart';
import 'package:groupie_chatapp/utils/widgets/common_widgets.dart';
import 'package:groupie_chatapp/utils/widgets/group_tile.dart';

import '../services/auth_service.dart';
import '../utils/widgets/SelectImageBottomSheet.dart';
import '../utils/widgets/customLoader.dart';
import 'auth/login_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  bool isLoading = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }



  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(title:Text("Groups",style: TextStyle(fontSize: 25,fontWeight: FontWeight.bold),),
      centerTitle: true,
      elevation: 0,
      leading: IconButton(onPressed: (){
        nextScreen(context,SearchPage());
      },
          icon: const Icon(Icons.search)
      ),
      actions: [
        IconButton(onPressed: (){
          nextScreen(context,ProfilePage());
        },
            icon: const Icon(Icons.account_circle)
        ),
      ],
      ),
     // drawer: navigationDrawer(),
      body: groupList(),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Constants.primaryColour,
        onPressed: (){
          popUpDialog(context);
        },
        elevation: 0,
        child: Icon(
          Icons.add,
          size: 30,
        ),
      ),
    );

  }

  popUpDialog(BuildContext context) {
    TextEditingController groupNameController = TextEditingController();
    final _formKey=GlobalKey<FormState>();
    File? _image;

    showDialog(
        //barrierDismissible: false,
        context: context,
        builder: (context) {
      return StatefulBuilder(builder: (context, setState) {
        pickImage() async {
          _image = await SelectImageBottomSheet().showSelectImageBottomSheet(context,false,() {});
          print(_image!.path);
          setState(()=>{});
        }
        return AlertDialog(
          title: Text("Create a group"),
          content: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _image!=null
                      ?Stack(
                        children: [
                          CircleAvatar(
                          radius: 50,
                          backgroundColor:Colors.grey.withOpacity(0.8),
                          foregroundImage:FileImage(_image!),
                          ),
                          Positioned(
                            right: 10,
                            bottom: 0.0,
                            child: GestureDetector(
                              onTap: () async {
                                _image=null;
                                setState(()=>{});
                              },
                              child: Container(
                                height: 25,
                                width: 25,
                                decoration: BoxDecoration(
                                  color: Theme.of(context).primaryColor,
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                child: const Center(
                                    child: Icon(
                                      Icons.clear,
                                      size: 15,
                                      color: Colors.white,
                                    )),
                              ),
                            ),
                          ),
                        ],
                      )
                      :GestureDetector(
                      onTap: () async {
                      pickImage();
                    },
                    child: CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.grey[400],
                      child: Icon(
                        Icons.camera_alt,
                        size: 50,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  SizedBox(height: 20,),
                  TextFormField(
                    controller: groupNameController,
                    decoration: commonTextInputDecoration.copyWith(
                      labelText: "Group name",
                      prefixIcon: Icon(Icons.group,color: Constants.primaryColour,),
                    ),
                    validator: (value){
                      return value!.isEmpty?"Enter group name":null;
                    },
                  )
                ],
              ),
            ),
          ),
          actions:isLoading?[Center(child: CircularProgressIndicator())]: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                  primary: Theme.of(context).primaryColor,
                elevation: 0
              ),
              child: const Text("CANCEL"),
            ),
            ElevatedButton(
              onPressed: () async {
                if(_formKey.currentState!.validate()){
                  setState((){
                    isLoading=true;
                  });
                  DataBaseService().createGroup(AppPref.getUserName()!, AppPref.getUserId()!, groupNameController.text,_image).whenComplete((){
                    setState((){
                      isLoading=false;
                    });
                    Navigator.of(context).pop();
                    showSnackbar(
                        context, Colors.green, "Group created successfully.");
                  });
                }
              },
              style: ElevatedButton.styleFrom(
                  primary: Theme.of(context).primaryColor,
                elevation: 0
              ),
              child: const Text("CREATE"),
            ),
          ],
        );
      });
    });
  }



  groupList(){
    return StreamBuilder(
      stream: DataBaseService().getUserGroups(),
        builder: (context,AsyncSnapshot snapshot){
      if(snapshot.hasData){
        if(snapshot.data["groups"].length!=0){
          return ListView.builder(
              itemCount:snapshot.data["groups"].length,
              shrinkWrap: true,
              itemBuilder:(context,index){
                int reverseIndex = snapshot.data["groups"].length - index - 1;
            return GroupTile(groupId: getId(snapshot.data["groups"][reverseIndex]),groupName: getName(snapshot.data["groups"][reverseIndex]), userName: snapshot.data["fullName"]);
          });
        }
        else{
          return noGroupWidget();
        }
      }
      else{
        return customLoader();
      }
    });

  }

  noGroupWidget() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 25),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          GestureDetector(
            onTap: () {
              popUpDialog(context);
            },
            child: Icon(
              Icons.add_circle,
              color: Colors.grey[700],
              size: 75,
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          const Text(
            "You've not joined any groups, tap on the add icon to create a group or also search from top search button.",
            textAlign: TextAlign.center,
          )
        ],
      ),
    );
  }
}
