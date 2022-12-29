import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:groupie_chatapp/pages/chat_page.dart';
import 'package:groupie_chatapp/utils/constants.dart';
import 'package:groupie_chatapp/utils/widgets/common_widgets.dart';

import '../../services/database_service.dart';

class GroupTile extends StatelessWidget {
  GroupTile({Key? key, required this.groupId, required this.userName, required this.groupName}) : super(key: key);

  final String groupId;
  final String groupName;
  final String userName;

  @override
  Widget build(BuildContext context) {

    return GestureDetector(
      onTap: (){
        nextScreen(context, ChatPage(groupName: groupName,groupId: groupId,userName: userName,));
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 5,vertical: 10),
        child: ListTile(
          leading: StreamBuilder(
              stream: DataBaseService().getGroupMembers(groupId),
              builder: (context,AsyncSnapshot snapshot) {
                if(snapshot.hasData){
                  return circleImageWidget(snapshot.data["groupIcon"].toString(), context, groupName);
                }
                else{
                  return CircleAvatar(
                    radius: 30,
                    backgroundImage: AssetImage(Constants.getAssetImagePath(imageName: "loading.gif",)),
                  );
                }
              }
          ),
          title: Text(groupName,style: TextStyle(fontWeight: FontWeight.bold),),
          subtitle: Text("Join the conversation as $userName",
            style: const TextStyle(fontSize: 13),),
        ),
      ),
    );
  }
}
