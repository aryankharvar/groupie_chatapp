import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:groupie_chatapp/services/auth_service.dart';
import 'package:groupie_chatapp/services/database_service.dart';
import 'package:groupie_chatapp/utils/AppPref.dart';
import 'package:groupie_chatapp/utils/widgets/SelectImageBottomSheet.dart';
import 'package:image_picker/image_picker.dart';

import '../utils/constants.dart';
import '../utils/widgets/common_widgets.dart';
import 'auth/login_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {

  File? _image;
  bool isLoading=false;
  bool showButton=false;


  @override
  Widget build(BuildContext context) {

    String userProfileImageLink=AppPref.getUserProfileImage()??"";

    pickImage() async {
      SelectImageBottomSheet().showSelectImageBottomSheet(context,!showButton&&userProfileImageLink.isNotEmpty,(){
        showAlertDialog(context,"Delete Profile Image","Are you sure you want to delete profile image?",
                () async {
                  DataBaseService().deleteUserProfileImage(userProfileImageLink).then((value){
                    if(value==true){
                      _image=null;
                      showSnackbar(context, Colors.green, "Profile Image Deleted Successfully");
                    }
                    else{
                      showSnackbar(context, Colors.red, value);
                    }
                    Navigator.pop(context);
                    Navigator.pop(context);
            });
        });
      }).then((value){
        if(value!=null) {
          _image=value;
          showButton=true;
        }
        setState((){
        });
      });

    }


    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Profile",
          style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 0,
        actions: [IconButton(onPressed: () {
          showAlertDialog(context,"Logout","Are you sure you want to logout?",
                  () async {
              AuthService authService=AuthService();
                await authService.signOut();
                Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(
                        builder: (context) => LoginPage()),
                        (route) => false);
              });
        }, icon: Icon(Icons.logout))],

      ),
      body: Container(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 50),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Stack(
              children: [
                _image==null&&userProfileImageLink.isEmpty
                    ?GestureDetector(
                  onTap: () async {
                    pickImage();
                  },
                  child: CircleAvatar(
                    radius: 90,
                    backgroundColor: Colors.grey[400],
                    child: Icon(
                      Icons.person,
                      size: 150,
                      color: Colors.white,
                    ),
                  ),
                )
                    :_image!=null
                    ?CircleAvatar(
                  radius: 90,
                  backgroundColor:Colors.grey[400],
                  foregroundImage:FileImage(_image!),
                )
                :ClipOval(
                  child: CachedNetworkImage(
                    placeholder:(context, url) => Image.asset(Constants.getAssetImagePath(imageName: "loading.gif",)),
                    imageUrl: userProfileImageLink,
                    fit: BoxFit.cover,
                    height: 180,
                    width: 180,
                  ),
                ),
                Positioned(
                  right: 20,
                  bottom: 0.0,
                  child: GestureDetector(
                    onTap: () async {
                      pickImage();

                    },
                    child: Container(
                      height: 40,
                      width: 40,
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor,
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: const Center(
                          child: Icon(
                            Icons.camera_alt,
                            color: Colors.white,
                          )),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: 50,
            ),
            TextFormField(
                initialValue: AppPref.getUserName(),
                readOnly: true,
                decoration: commonTextInputDecoration.copyWith(
                  labelText: "Full Name",
                  prefixIcon: Icon(Icons.person,color: Constants.primaryColour,),
                )
            ),
            SizedBox(height: 20,),
            TextFormField(
               initialValue: AppPref.getUserEmail(),
                readOnly: true,
                decoration: commonTextInputDecoration.copyWith(
                  labelText: "Email",
                  prefixIcon: Icon(Icons.email,color: Constants.primaryColour,),
                )
            ),
            // Row(
            //   children: [
            //     const Text("Full Name :", style: TextStyle(fontSize: 17)),
            //     SizedBox(
            //       width: 15,
            //     ),
            //     Text(AppPref.getUserName()!,
            //         style: const TextStyle(fontSize: 17)),
            //   ],
            // ),
            // const Divider(
            //   thickness: 1,
            // ),
            // Row(
            //   children: [
            //     const Text("Email : ", style: TextStyle(fontSize: 17)),
            //     Text(AppPref.getUserEmail()!,
            //         style: const TextStyle(fontSize: 17)),
            //   ],
            // ),
            const SizedBox(
              height: 50,
            ),
            showButton
                ?SizedBox(
              width: double.infinity,
              child: isLoading?Center(child: CircularProgressIndicator()):ElevatedButton(
                  onPressed: () async {
                    setState(()=> isLoading=true);
                    var temp=await DataBaseService().uploadUserProfileImage(_image!);
                    setState(()=> isLoading=false);
                    if(temp==true){
                      showSnackbar(context, Colors.green, "Profile Image Saved Successfully");
                      setState(()=> showButton=false);
                    }
                    else{
                      showSnackbar(context, Colors.red, temp);
                    }

                  },
                  style: ElevatedButton.styleFrom(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30)),
                  ),
                  child:Text("Save",style: TextStyle(
                    fontSize: 16,
                  ),)
              ),
            )
                :SizedBox(),
          ],
        ),
      ),
    );
  }
}
