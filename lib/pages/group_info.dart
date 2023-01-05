
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:groupie_chatapp/pages/home_page.dart';
import 'package:groupie_chatapp/services/database_service.dart';
import 'package:groupie_chatapp/utils/widgets/common_widgets.dart';

import '../utils/constants.dart';
import '../utils/widgets/SelectImageBottomSheet.dart';

class groupInfo extends StatefulWidget {
  const groupInfo({Key? key, required this.groupId, required this.groupName, required this.userName}) : super(key: key);

  final String groupId;
  final String groupName;
  final String userName;

  @override
  State<groupInfo> createState() => _groupInfoState();
}

class _groupInfoState extends State<groupInfo> {

  bool imageIsLoading=false;

  @override
  Widget build(BuildContext context) {

    showImageBottomSheet(String imageUrl){
      SelectImageBottomSheet().showSelectImageBottomSheet(context,imageUrl.isNotEmpty
          ,(){
            showAlertDialog(context,"Delete Group Icon","Are you sure you want to delete Group Icon?",
                    () async {
                      Navigator.pop(context);
                      Navigator.pop(context);
                      setState((){
                        imageIsLoading=true;
                      });
                  DataBaseService().deleteGroupIcon(imageUrl,widget.groupId).then((value){
                    if(value==true){
                      showSnackbar(context, Colors.green, "Group Icon Deleted Successfully");
                    }
                    else{
                      showSnackbar(context, Colors.red, value);
                    }
                    setState((){
                      imageIsLoading=false;
                    });
                  });
                });
          }).then((image) async {
        if(image!=null) {
          setState((){
            imageIsLoading=true;
          });
          if(imageUrl.isNotEmpty){
           await DataBaseService().deleteGroupIcon(imageUrl,widget.groupId).then((value) async {
              if(value==true){
               await DataBaseService().updateGroupIcon(image, widget.groupId).then((value){
                  if(value==true){
                    showSnackbar(context, Colors.green, "Group Icon update Successfully");
                  }
                  else{
                    showSnackbar(context, Colors.red, value);
                  }
                });
              }
              else{
                showSnackbar(context, Colors.red, value);
              }
            });
           setState((){
             imageIsLoading=false;
           });
          }
          else{
            DataBaseService().updateGroupIcon(image, widget.groupId).then((value){
              if(value==true){
                showSnackbar(context, Colors.green, "Group Icon update Successfully");
              }
              else{
                showSnackbar(context, Colors.red, value);
              }
              setState((){
                imageIsLoading=false;
              });
            });
          }

        }
      });
    }

    return Scaffold(
        appBar: AppBar(
          title:Text("Group Info",style: TextStyle(fontSize: 25,fontWeight: FontWeight.bold),
          ),
          elevation: 0,
          centerTitle: true,
          actions: [
            IconButton(onPressed: (){
              showAlertDialog(context, "Exit","Are you sure you exit the group?",
                      () async {
                      DataBaseService().toggleGroupJoin(widget.groupId, widget.groupName).whenComplete((){
                          nextScreenReplace(context, HomePage());
                      });
                  });
            }, icon: Icon(Icons.logout_outlined))
          ],
        ),
      body: StreamBuilder(
        stream: DataBaseService().getGroupMembers(widget.groupId),
        builder: (context,AsyncSnapshot snapshot) {
          if(snapshot.hasData){
            return Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 10,vertical: 10),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(30),
                        color: Theme.of(context).primaryColor.withOpacity(0.2)),
                    child: ListTile(
                      leading: imageIsLoading
                          ?CircleAvatar(
                        radius: 30,
                        foregroundImage: AssetImage(Constants.getAssetImagePath(imageName: "loading.gif",)),
                      )
                          :Stack(
                            children: [
                              GestureDetector(
                                    onTap: (){
                                      if(snapshot.data["groupIcon"].toString().isEmpty) {
                                        showImageBottomSheet(snapshot.data["groupIcon"].toString());
                                      } else {
                                        imagePopUpDialog(snapshot.data["groupIcon"].toString(), context,widget.groupName);
                                      }
                                    },
                                    child:snapshot.data["groupIcon"].toString().isNotEmpty
                                        ?ClipOval(
                                      child: CachedNetworkImage(
                                        placeholder:(context, url) => Image.asset(Constants.getAssetImagePath(imageName: "loading.gif",)),
                                        imageUrl: snapshot.data["groupIcon"],
                                        fit: BoxFit.cover,
                                        height: 60,
                                        width: 58,
                                      ),
                                    )
                                        :CircleAvatar(
                                radius: 30,
                                backgroundColor: Constants.primaryColour,
                                child: Text(widget.groupName.substring(0,1).toUpperCase(),style: TextStyle(color: Colors.white,fontWeight: FontWeight.w500),),
                              ),
                                  ),
                              Positioned(
                                right: 0,
                                bottom: 0.0,
                                child: GestureDetector(
                                  onTap: () async {
                                    showImageBottomSheet(snapshot.data["groupIcon"].toString());
                                  },
                                  child: Container(
                                    height: 20,
                                    width: 20,
                                    decoration: BoxDecoration(
                                      color: Theme.of(context).primaryColor,
                                      borderRadius: BorderRadius.circular(30),
                                    ),
                                    child: const Center(
                                        child: Icon(
                                          Icons.edit,
                                          size: 12,
                                          color: Colors.white,
                                        )),
                                  ),
                                ),
                              ),
                            ],
                          ),
                      title: Text(widget.groupName,style: TextStyle(fontWeight: FontWeight.bold),),
                      subtitle: Text("Admin: ${getName(snapshot.data["admin"])}",
                      ),
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      itemCount: snapshot.data["members"].length,
                      shrinkWrap: true,
                      itemBuilder: (context,index) {
                        return memberTile(getName(snapshot.data["members"][index]), getId(snapshot.data["members"][index]));
                      }
                    ),
                  ),
                ],
              ),
            );
          }
          else{
            return Center(child: CircularProgressIndicator());
          }
        }
      ),
    );

  }

  memberTile(String name,String userId){

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10,vertical: 10),
      child: ListTile(
        leading: StreamBuilder(
      stream: DataBaseService().getUserProfileImage(userId),
      builder: (context,AsyncSnapshot snapshot) {
        if(snapshot.hasData){
          return snapshot.data["profilePic"].toString().isNotEmpty
              ?GestureDetector(
                onTap: (){
                  imagePopUpDialog(snapshot.data["profilePic"], context,name);
                },
                child: ClipOval(
            child: CachedNetworkImage(
                placeholder:(context, url) => Image.asset(Constants.getAssetImagePath(imageName: "loading.gif",)),
                imageUrl: snapshot.data["profilePic"],
                fit: BoxFit.cover,
                height: 60,
                width: 58,
            ),
          ),
              )
              :CircleAvatar(
                radius: 30,
                backgroundColor: Constants.primaryColour,
                child:Text(name.substring(0,1).toUpperCase(),style: TextStyle(color: Colors.white,fontWeight: FontWeight.w500),));
         }
        else{
         return CircleAvatar(
                radius: 30,
                backgroundImage: AssetImage(Constants.getAssetImagePath(imageName: "loading.gif",)),
              );
        }
        }
        ),
        // userProfileLink.isNotEmpty
        //     ?CircleAvatar(
        //   radius: 30,
        //   backgroundImage: NetworkImage(userProfileLink),
        // )
        //     :CircleAvatar(
        //   radius: 30,
        //   backgroundColor: Constants.primaryColour,
        //   child:Text(name.substring(0,1).toUpperCase(),style: TextStyle(color: Colors.white,fontWeight: FontWeight.w500),),
        // ),
        title: Text(name,style: TextStyle(fontWeight: FontWeight.bold),),
        subtitle: Text(userId),
        ),
      );
  }
}
