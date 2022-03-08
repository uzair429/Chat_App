import 'dart:io';

import 'package:chap_app/model/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../model/uihelper_model.dart';

class CompleteProfileScreen extends StatefulWidget {
  // userModel and user is imported from SignUp Page
  final UserModel userModel;
  final User firebaseUser;

  const CompleteProfileScreen({Key? key, required this.userModel, required this.firebaseUser})
      : super(key: key);

  @override
  _CompleteProfileScreenState createState() => _CompleteProfileScreenState();
}

class _CompleteProfileScreenState extends State<CompleteProfileScreen> {
  // File to Store the Image From Gallery
  File? imageFile;

  TextEditingController nameController = TextEditingController();

  // Function to Pick Image From Gallery
  void selectImage(ImageSource source) async {
    XFile? pickedFile = await ImagePicker().pickImage(
      source: source,
      maxWidth: 1800,
      maxHeight: 1800,
    );
    if (pickedFile != null) {
      setState(() {
        imageFile = File(pickedFile.path);
        //print("*************Successful initialized");
      });
    }
  }


  void cropImage() {}

  // Check is Image and Fullname are not Null
  void checkValues() {
    String fullName = nameController.text.trim();
    if (imageFile == null || fullName == "") {
      UIHelper.showAlertDialog(context, "Incomplete Data", "Please fill all the fields and upload a profile picture");

    } else {
      uploadData();
    }
  }

  // Function to Upload the image in 'Firebase Storage' and the name and path of image in 'Firestore Database
  void uploadData() async {

    UIHelper.showLoadingDialog(context, "Uploading image..");

    // Upload Image to Storage
    UploadTask uploadTask = FirebaseStorage.instance
        .ref("ProfilePictures")
        .child(widget.userModel.uid.toString())
        .putFile(imageFile!);

    // update or initialize the values of image link and Fullname
    TaskSnapshot snapshot = await uploadTask;
    String imageUrl = await snapshot.ref.getDownloadURL();
    String fullName = nameController.text.trim();
    widget.userModel.fullname = fullName;
    widget.userModel.profilepic = imageUrl;

    await FirebaseFirestore.instance
        .collection("users")
        .doc(widget.userModel.uid)
        .set(
          widget.userModel.toMap()
        ).then((value) => print('*********Data Uploaded'));
  }

  // Dialog to select the Option either upload from Gallery or Take a NEw ONe Using Camera
  void showPhotoOptions() {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
              title: Text("Upload Profile Picture"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ListTile(
                    onTap: () {
                      selectImage(ImageSource.gallery);
                      Navigator.pop(context);
                    },
                    leading: Icon(Icons.photo_album),
                    title: Text('Upload from Gallery'),
                  ),
                  ListTile(
                    onTap: () {
                      selectImage(ImageSource.camera);
                    },
                    leading: Icon(Icons.camera_alt),
                    title: Text('Take Photo'),
                  )
                ],
              ));
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text('Complete Profile'),
      ),
      body: SafeArea(
          child: Container(
              padding: EdgeInsets.symmetric(horizontal: 40),
              child: ListView(
                children: [
                  const SizedBox(
                    height: 20,
                  ),
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    onPressed: () {
                      showPhotoOptions();
                    },
                    child: CircleAvatar(
                      backgroundImage:(imageFile != null)? FileImage(imageFile!): null,
                      radius: 60,
                      child: (imageFile == null) ? Icon(Icons.person) : null,
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  TextField(
                    controller: nameController,
                    decoration: InputDecoration(labelText: 'Full Name'),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  CupertinoButton(
                    child: Text(" Submitt"),
                    onPressed: () {
                     // Navigator.pop(context);
                      checkValues();
                    },
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                ],
              ))),
    );
  }
}
