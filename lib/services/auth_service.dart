import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:groupie_chatapp/services/database_service.dart';
import 'package:groupie_chatapp/utils/AppPref.dart';

import '../utils/constants.dart';

class AuthService{

  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;

  Future loginWithEmailAndPassword(String email,String password) async {
    try{
      User user = (await firebaseAuth.signInWithEmailAndPassword(email: email, password: password)).user!;
      if(user != null){
        print("User Id: ${user.uid}");
        AppPref.setIsUserLogin(true);
        await AppPref.setUserId(user.uid);
        var data = await DataBaseService().getUserData();
        print(data);
        AppPref.setUserName(data["fullName"]);
        AppPref.setUserEmail(data["email"]);
        AppPref.setUserProfileImage(data["profilePic"]);
        return true;
      }
    }
    on FirebaseAuthException catch (e){
      return e.message;
    }
  }

  Future registerUserWithEmailAndPassword(String fullName,String email,String password) async {
    try{
      User user = (await firebaseAuth.createUserWithEmailAndPassword(email: email, password: password)).user!;

      if(user != null){
        print("User Id: ${user.uid}");
        await AppPref.setUserId(user.uid);
        DataBaseService().uidPrint();
        await DataBaseService().savingUserData(fullName, email);
        AppPref.setUserName(fullName);
        AppPref.setUserEmail(email);
        AppPref.setIsUserLogin(true);
        return true;
      }
    }
    on FirebaseAuthException catch (e){
      return e.message;
    }
  }

  Future signOut() async {
    try {
      DataBaseService().clear();
      AppPref.removeAll();
      await firebaseAuth.signOut();
    } catch (e) {
      return null;
    }
  }

}