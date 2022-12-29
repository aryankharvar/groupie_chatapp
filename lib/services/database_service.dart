
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:groupie_chatapp/utils/AppPref.dart';

class DataBaseService{
  String uid=AppPref.getUserId()??'';

  final CollectionReference userCollection =
  FirebaseFirestore.instance.collection("users");

  final CollectionReference groupCollection =
  FirebaseFirestore.instance.collection("groups");

  uidPrint(){
    print("data base User Id: $uid");
  }

  clear(){
    uid='';
  }

  Future uploadUserProfileImage(File imageFile) async {
      try {
        final ref = await FirebaseStorage.instance.ref("usersProfileImage/$uid").putFile(imageFile);
        String imageUrl=await ref.ref.getDownloadURL();
        print("image url: $imageUrl");
        await userCollection.doc(uid).update({
          "profilePic":imageUrl,
        });
        AppPref.setUserProfileImage(imageUrl);
        return true;
      } on FirebaseException catch (e) {
        // TODO
        return e.message!;
      }
  }

  Stream getUserProfileImage(String userId) {
   return userCollection.doc(userId).snapshots();
  }

  Future deleteUserProfileImage(String imageUrl) async {
    try {
      await FirebaseStorage.instance.refFromURL(imageUrl).delete();
      await userCollection.doc(uid).update({
        "profilePic":"",
      });
      AppPref.setUserProfileImage('');
      return true;
    } on FirebaseException catch (e) {
      // TODO
      return e.message!;
    }
  }

  Future savingUserData(String fullName,String email) async{
    return await userCollection.doc(uid).set({
      "fullName":fullName,
      "email":email,
      "groups":[],
      "profilePic":"",
      "uid":uid,
    });
  }

  Future getUserData() async {
    DocumentSnapshot documentSnapshot=await userCollection.doc(uid).get();
    return documentSnapshot.data()! as Map<String, dynamic>;
  }

  Stream getUserGroups() {
    return userCollection.doc(uid).snapshots();
  }

  Stream getGroupMembers(String groupId) {
    return groupCollection.doc(groupId).snapshots();
  }

  // search
  searchByName(String groupName) {
    return groupCollection.where("groupName").get();
  }

  Future createGroup(String userName, String id, String groupName,File? imageFile) async {
    DocumentReference groupDocumentReference = await groupCollection.add({
      "groupName": groupName,
      "groupIcon": "",
      "admin": "${id}_$userName",
      "members": ["${uid}_$userName"],
      "groupId": "",
      "recentMessage": "",
      "recentMessageSender": "",
    });

    print(imageFile);
    String imageUrl='';
    if (imageFile!=null) {
      final ref = await FirebaseStorage.instance.ref("groupIcons/${groupDocumentReference.id}").putFile(imageFile);
      imageUrl=await ref.ref.getDownloadURL();
      print("image url: $imageUrl");
    }

    await groupDocumentReference.update({
      "groupId": groupDocumentReference.id,
      "groupIcon": imageUrl,
    });

    return await userCollection.doc(uid).update({
      "groups": FieldValue.arrayUnion(["${groupDocumentReference.id}_$groupName"])
    });
  }

  Future deleteGroupIcon(String imageUrl,String groupId) async {
    try {
      await FirebaseStorage.instance.refFromURL(imageUrl).delete();
      await groupCollection.doc(groupId).update({
        "groupIcon": "",
      });
      return true;
    } on FirebaseException catch (e) {
      // TODO
      return e.message!;
    }
  }

  Future updateGroupIcon(File image,String groupId) async {
    try {
      final ref = await FirebaseStorage.instance.ref("groupIcons/${groupId}").putFile(image);
      String imageUrl=await ref.ref.getDownloadURL();
      print("image url: $imageUrl");
      await groupCollection.doc(groupId).update({
        "groupIcon": imageUrl,
      });
      return true;
    } on FirebaseException catch (e) {
      // TODO
      return e.message!;
    }
  }

  Future<bool> isUserJoined(
      String groupName, String groupId) async {
    DocumentReference userDocumentReference = userCollection.doc(uid);
    DocumentSnapshot documentSnapshot = await userDocumentReference.get();

    List<dynamic> groups = await documentSnapshot['groups'];
    if (groups.contains("${groupId}_$groupName")) {
      return true;
    } else {
      return false;
    }
  }

  // toggling the group join/exit
  Future<bool> toggleGroupJoin(
      String groupId, String groupName) async {
    // doc reference
    DocumentReference userDocumentReference = userCollection.doc(uid);
    DocumentReference groupDocumentReference = groupCollection.doc(groupId);

    // if user has our groups -> then remove then or also in other part re join
    if (await isUserJoined(groupName, groupId)) {
      await userDocumentReference.update({
        "groups": FieldValue.arrayRemove(["${groupId}_$groupName"])
      });
      await groupDocumentReference.update({
        "members": FieldValue.arrayRemove(["${uid}_${AppPref.getUserName()}"])
      });
      return false;
    } else {
      await userDocumentReference.update({
        "groups": FieldValue.arrayUnion(["${groupId}_$groupName"])
      });
      await groupDocumentReference.update({
        "members": FieldValue.arrayUnion(["${uid}_${AppPref.getUserName()}"])
      });
      return true;
    }
  }

  // getting the chats
 Stream getChats(String groupId){
    return groupCollection
        .doc(groupId)
        .collection("messages")
        .orderBy("time")
        .snapshots();
  }

  sendMessage(String groupId,String msg, String sender) async {
    String time=DateTime.now().millisecondsSinceEpoch.toString();

    await groupCollection.doc(groupId).collection("messages").add({
      "message": msg,
      "sender": sender,
      "time": time,
    });

    await groupCollection.doc(groupId).update({
      "recentMessage": msg,
      "recentMessageSender": sender,
      "recentMessageTime": time,
    });
  }

}

