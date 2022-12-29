import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

import '../../services/database_service.dart';
import 'common_widgets.dart';

class SelectImageBottomSheet {

  File? _image;
  Future<File?> showSelectImageBottomSheet(BuildContext context,bool showDeleteButton,VoidCallback deleteOnPressed) async {
    await showModalBottomSheet(
        context: context,
        shape: const RoundedRectangleBorder(
            borderRadius:  BorderRadius.vertical(top:  Radius.circular(20))),
        builder: (builder) {
          return StatefulBuilder(builder: (context, State) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Select Image from",
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w500),
                      ),
                      showDeleteButton?InkWell(
                        child: Icon(Icons.delete),
                        onTap: deleteOnPressed,
                      ):SizedBox(),
                    ],
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      InkWell(
                        onTap: () async {
                          pickImage(context, ImageSource.gallery);
                        },
                        child: Card(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: 20, horizontal: 30),
                            child: Column(
                              children: [
                                Icon(Icons.photo),
                                const SizedBox(
                                  height: 10,
                                ),
                                const Text("From Gallery"),
                              ],
                            ),
                          ),
                        ),
                      ),
                      InkWell(
                        onTap: () async {
                          pickImage(context, ImageSource.camera);
                        },
                        child: Card(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: 20, horizontal: 30),
                            child: Column(
                              children: [
                                Icon(Icons.camera_alt),
                                const SizedBox(
                                  height: 10,
                                ),
                                const Text("From Camera"),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          });
        });
    return _image;
  }

  pickImage(BuildContext context,ImageSource imageSource) async {
    try {
      final image = await ImagePicker().pickImage(source: imageSource,imageQuality: 10);
      if(image==null) return;
      _image=File(image.path);
      Navigator.pop(context);
    } on PlatformException catch (e) {
      // TODO
      showSnackbar(context, Colors.red, e.message);
    }
  }
}