import 'package:flutter/material.dart';
import 'package:groupie_chatapp/pages/group_info.dart';
import 'package:groupie_chatapp/utils/widgets/common_widgets.dart';
import 'package:groupie_chatapp/utils/widgets/message_tile.dart';

import '../services/database_service.dart';

class ChatPage extends StatelessWidget {
  ChatPage({Key? key, required this.groupId, required this.groupName, required this.userName}) : super(key: key);

  final String groupId;
  final String groupName;
  final String userName;

  TextEditingController messageController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:Text(groupName,style: TextStyle(fontSize: 25,fontWeight: FontWeight.bold),
      ),
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(onPressed: (){
            nextScreen(context, groupInfo(groupId: groupId,groupName: groupName,userName: userName,));
          }, icon: Icon(Icons.info))
        ],
      ),
      bottomNavigationBar: Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 10,horizontal: 15),
          width: MediaQuery.of(context).size.width,
          color: Colors.grey[700],
          child: TextFormField(
            controller: messageController,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: "Send a message...",
              hintStyle: TextStyle(color: Colors.white, fontSize: 16),
              border: InputBorder.none,
              suffixIcon: GestureDetector(
                onTap: (){
                  if(messageController.text.isNotEmpty){
                    DataBaseService().sendMessage(groupId, messageController.text, userName);
                    messageController.clear();
                  }
                },
                child: Container(
                  height: 35,
                  width: 35,
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: const Center(
                      child: Icon(
                        Icons.send,
                        color: Colors.white,
                      )),
                ),
              ),
            ),
          ),
        ),
      ),
      body: StreamBuilder(
          stream: DataBaseService().getChats(groupId),
          builder: (context,AsyncSnapshot snapshot) {
            if(snapshot.hasData){
              if (snapshot.data.docs.length!=0) {
                return ListView.builder(
                    itemCount: snapshot.data.docs.length,
                    shrinkWrap: true,
                    reverse: true,
                    itemBuilder: (context,index) {
                      int reverseIndex = snapshot.data.docs.length - index - 1;
                      return MessageTile(message: snapshot.data.docs[reverseIndex]['message'], sender: snapshot.data.docs[reverseIndex]['sender'], sentByMe: userName ==
                          snapshot.data.docs[reverseIndex]['sender']
                      );
                    }
                );
              }
              else{
                return Center(child: Text("No Messages Send"));
              }
            }
            else{
              return Center(child: CircularProgressIndicator());
            }
          }
      ),
    );
  }
}
