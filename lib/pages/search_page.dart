import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:groupie_chatapp/services/database_service.dart';
import 'package:groupie_chatapp/utils/AppPref.dart';
import 'package:groupie_chatapp/utils/widgets/common_widgets.dart';

import '../utils/widgets/customLoader.dart';
import 'chat_page.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({Key? key}) : super(key: key);

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  TextEditingController searchController = TextEditingController();
  bool isLoading = false;
  List searchSnapshot=[];
  bool hasUserSearched = false;
  String userName = "";
  List<bool> isJoined=[];
  User? user;

  @override
  void initState() {
    super.initState();
    getCurrentUserIdandName();
  }

  getCurrentUserIdandName() async {
    userName=AppPref.getUserName()!;
    user = FirebaseAuth.instance.currentUser;
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Theme.of(context).primaryColor,
        title: const Text(
          "Search",
          style: TextStyle(
              fontSize: 27, fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
      body: Column(
        children: [
          Container(
            color: Theme.of(context).primaryColor,
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: searchController,
                    style: const TextStyle(color: Colors.white),
                    onChanged: (value){
                      //initiateSearchMethod();
                    },
                    onEditingComplete: initiateSearchMethod,
                    decoration: const InputDecoration(
                        border: InputBorder.none,
                        hintText: "Search groups....",
                        hintStyle:
                        TextStyle(color: Colors.white, fontSize: 16)),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    initiateSearchMethod();
                  },
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(40)),
                    child: const Icon(
                      Icons.search,
                      color: Colors.white,
                    ),
                  ),
                )
              ],
            ),
          ),
          isLoading
              ? Center(child: CircularProgressIndicator())
              : groupList(),
        ],
      ),
    );
  }

  initiateSearchMethod() async {

    if (searchController.text.isNotEmpty) {
      FocusScope.of(context).requestFocus(new FocusNode());
      setState(() {
        isLoading = true;
      });
      await DataBaseService()
          .searchByName(searchController.text)
          .then((snapshot) {
            isJoined.clear();
          searchSnapshot = snapshot.docs.where((element) => element["groupName"].toString().toLowerCase().contains(searchController.text.toLowerCase())).toList();

          for(int i=0;i<searchSnapshot.length;i++){
            isJoined.add(false);
          }
          setState(() {
          isLoading = false;
          hasUserSearched = true;
        });
      });
    }
    else{
      searchSnapshot.clear();
      setState(() {
        hasUserSearched = false;
      });
    }
  }

  groupList() {
    return hasUserSearched
        ? Expanded(
          child: ListView.builder(
      shrinkWrap: true,
      itemCount: searchSnapshot.length,
      itemBuilder: (context, index) {
          return groupTile(
            searchSnapshot[index]['groupId'],
            searchSnapshot[index]['groupName'],
            searchSnapshot[index]['admin'],
              searchSnapshot[index]['groupIcon'],
            index
          );
      },
    ),
        )
        : Container();
  }

  joinedOrNot(
       String groupId, String groupname, String admin,int index) async {
    isJoined[index] = await DataBaseService()
        .isUserJoined(groupname, groupId);
    setState(() {});
  }

  Widget groupTile(
      String groupId, String groupName, String admin,String imageURl,int index) {
    // function to check whether user already exists in group
    joinedOrNot(groupId, groupName, admin,index);
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      leading: circleImageWidget(imageURl, context, groupName),
      title:
      Text(groupName, style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: Text("Admin: ${getName(admin)}"),
      trailing: InkWell(
        onTap: () async {
          if (await DataBaseService()
              .toggleGroupJoin(groupId, groupName)) {
            showSnackbar(context, Colors.green, "Successfully joined $groupName group");
            Future.delayed(const Duration(seconds: 2), () {
              nextScreen(
                  context,
                  ChatPage(
                      groupId: groupId,
                      groupName: groupName,
                      userName: userName));
            });
          } else {
            setState(() {
              showSnackbar(context, Colors.red, "Left the group $groupName");
            });
          }
        },
        child: isJoined[index]
            ? Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: Colors.black,
            border: Border.all(color: Colors.white, width: 1),
          ),
          padding:
          const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: const Text(
            "Joined",
            style: TextStyle(color: Colors.white),
          ),
        )
            : Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: Theme.of(context).primaryColor,
          ),
          padding:
          const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: const Text("Join Now",
              style: TextStyle(color: Colors.white)),
        ),
      ),
    );
  }
}
