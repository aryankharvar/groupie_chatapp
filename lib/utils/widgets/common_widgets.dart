import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:groupie_chatapp/services/auth_service.dart';
import 'package:groupie_chatapp/utils/constants.dart';

import '../../pages/auth/login_page.dart';

var commonTextInputDecoration = InputDecoration(
  labelStyle: TextStyle(color: Colors.black, fontWeight: FontWeight.w400),
  focusedBorder: OutlineInputBorder(
    borderSide: BorderSide(color: Constants.primaryColour, width: 2),
  ),
  enabledBorder: OutlineInputBorder(
    borderSide: BorderSide(color: Constants.primaryColour, width: 2),
  ),
  errorBorder: OutlineInputBorder(
    borderSide: BorderSide(color: Colors.red, width: 2),
  ),
  focusedErrorBorder: OutlineInputBorder(
    borderSide: BorderSide(color: Colors.red, width: 2),
  )
);

void nextScreen(context, page) {
  Navigator.push(context, MaterialPageRoute(builder: (context) => page));
}

void nextScreenReplace(context, page) {
  Navigator.pushReplacement(
      context, MaterialPageRoute(builder: (context) => page));
}

void showSnackbar(context, color, message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(
        message,
        style: const TextStyle(fontSize: 14),
      ),
      backgroundColor: color,
      duration: const Duration(seconds: 3),
    ),
  );
}

String getId(String res) {
  return res.substring(0, res.indexOf("_"));
}

String getName(String res) {
  return res.substring(res.indexOf("_") + 1);
}

showAlertDialog(BuildContext context,String title,String content,VoidCallback onPressed){
  showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: Text(content),
          actions: [
            IconButton(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: const Icon(
                Icons.cancel,
                color: Colors.red,
              ),
            ),
            IconButton(
              onPressed: onPressed,
              icon: const Icon(
                Icons.done,
                color: Colors.green,
              ),
            ),
          ],
        );
      });
}

imagePopUpDialog(String imageURl,BuildContext context,String text){
  showDialog(
    //barrierDismissible: false,
      context: context,
      builder: (context) {
        return Dialog(
          child: Stack(
            children: [
              Container(
                width: 400,
                height: 300,
                child: CachedNetworkImage(
                  placeholder:(context, url) => Image.asset(Constants.getAssetImagePath(imageName: "loading.gif",)),
                  imageUrl: imageURl,
                  fit: BoxFit.cover,
                ),
              ),
              Container(
                width: 400, height: 40,
                  color: Colors.transparent.withOpacity(0.2),
                  padding: EdgeInsets.only(left: 20,top: 5),
                  child: Text(text,style: TextStyle(fontSize: 24,color: Colors.white),)),
            ],
          ),
        );
      });
}

Widget circleImageWidget(String imageURl,BuildContext context,String name){
 return imageURl.isNotEmpty
      ?GestureDetector(
    onTap: (){
      imagePopUpDialog(imageURl, context,name);
    },
    child: ClipOval(
      child: CachedNetworkImage(
        placeholder:(context, url) => Image.asset(Constants.getAssetImagePath(imageName: "loading.gif",)),
        imageUrl: imageURl,
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
