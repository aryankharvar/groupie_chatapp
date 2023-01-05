
import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:groupie_chatapp/utils/AppPref.dart';
import 'package:groupie_chatapp/utils/widgets/common_widgets.dart';
import 'package:http/http.dart';

class DataBaseService{
  String uid=AppPref.getUserId()??'';

  final CollectionReference userCollection =
  FirebaseFirestore.instance.collection("users");

  final CollectionReference groupCollection =
  FirebaseFirestore.instance.collection("groups");


  final FirebaseMessaging firebaseMessaging= FirebaseMessaging.instance;

  Future getFireBaseMessagingToken() async{
    await firebaseMessaging.requestPermission();

    await firebaseMessaging.getToken().then((value) async {
      if(value!=null){
        print("token $value");
        await updateUserToken(value);
      }
    });

  }

  uidPrint(){
    print("data base User Id: $uid");
  }

  clear(){
    uid='';
  }

  Future updateUserToken(String token) async {
    try {
      await userCollection.doc(uid).update({
        "token":token,
      });
      return true;
    } on FirebaseException catch (e) {
      // TODO
      return e.message!;
    }
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
    var data=documentSnapshot.data()as Map<String, dynamic>;
    await subscribeToTopics(data["groups"]);
    return data;
  }

  Future subscribeToTopics(List groups) async{
    for(int i=0;i<groups.length;i++){
      await firebaseMessaging.subscribeToTopic(getId(groups[i]));
    }
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

    await firebaseMessaging.subscribeToTopic(groupDocumentReference.id);

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
  Future<bool> toggleGroupJoin(String groupId, String groupName) async {
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
      await firebaseMessaging.unsubscribeFromTopic(groupId);
      return false;
    } else {
      await userDocumentReference.update({
        "groups": FieldValue.arrayUnion(["${groupId}_$groupName"])
      });
      await groupDocumentReference.update({
        "members": FieldValue.arrayUnion(["${uid}_${AppPref.getUserName()}"])
      });
      await firebaseMessaging.subscribeToTopic(groupId);
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

  sendMessage(String groupId,String groupName,String msg, String sender) async {
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

    await sendPushNotification(groupId,groupName, msg, sender);
  }


  // for sending push notification
  Future<void> sendPushNotification(String groupId,String groupName,String msg, String sender) async {
    try {
      final body = {
        "to": "/topics/$groupId",
        "notification": {
          "title": groupName, //our name should be send
          "body": "$sender: $msg",
          "android_channel_id": "chats"
        },
      };
      var res = await post(Uri.parse('https://fcm.googleapis.com/fcm/send'),
          headers: {
            HttpHeaders.contentTypeHeader: 'application/json',
            HttpHeaders.authorizationHeader:
            'key=AAAAAXUJG08:APA91bF9AJgdjsNTJTZKVY95hzOxym3dbn4INh-re5YjZTxPpS2BnrvKf4MDG0ETzBHC1uM4EowmR-vAgtms0oMHK6foh3YRf4xOnU-8sz6eqzY3iHwPN9RneyjmHtG178VrOQrrRrmn'
          },
          body: jsonEncode(body));
      print('Response status: ${res.statusCode}');
      print('Response body: ${res.body}');
    } catch (e) {
      print('\nsendPushNotificationE: $e');
    }
  }

}

