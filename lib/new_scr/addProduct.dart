import 'dart:io';

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart' as path;
import 'package:path/path.dart';
import '../notification/firebase_notification.dart';
import 'operations.dart';

class AddUser extends StatefulWidget {
  static const routeName = 'adduser';

  @override
  _AddUserState createState() => _AddUserState();
}

class _AddUserState extends State<AddUser> {
  String id = "";
  FirebaseStorage storage = FirebaseStorage.instance;
  TextEditingController productNameController = TextEditingController();
  TextEditingController productPriceController = TextEditingController();
  TextEditingController imageUrlController = TextEditingController();
  String productName = "";
  String productPrice = "";
  String imageUrl = "";
  bool isFavourite = false;
  File? imageFile = null;
  void sendNotificationToAllUsers() async {
    String message = "Hello, everyone!";
    String topic = "all_users";
    String type = "general";
    String title = "New Notification";

    NotificationApiHitting notificationApi = NotificationApiHitting();
    bool success = await notificationApi.callOnFcmApiSendPushNotifications(
      message: message,
      topic: topic,
      type: type,
      title: title,
    );

    if (success) {
      print("Notification sent successfully to all users.");

      AwesomeNotifications().initialize(null, [
        // notification icon
        NotificationChannel(
          channelGroupKey: 'basic_test',
          channelKey: 'basic',
          channelName: 'Basic notifications',
          channelDescription: 'Notification channel for basic tests',
          channelShowBadge: true,
          importance: NotificationImportance.High,
          enableVibration: true,
        ),

        //add more notification type with different configuration
      ]);
      showNotificationn();
    } else {
      print("Failed to send notification to all users.");
    }
  }
  void showNotificationn() {
    AwesomeNotifications().createNotification(
        content: NotificationContent(
          //simgple notification
          id: 123,
          channelKey: 'basic', //set configuration wuth key "basic"
          title: 'Welcome to App',
          body: 'New post added in timelines',
        ));
  }
  Future<void> _upload() async {
    final picker = ImagePicker();
    XFile? pickedImage;
    try {
      pickedImage =
          await picker.pickImage(source: ImageSource.gallery, maxWidth: 1920);

      final String fileName = path.basename(pickedImage!.path);
      imageFile = File(pickedImage.path);

      try {

        String fileName = basename(imageFile!.path);
        FirebaseStorage storage = FirebaseStorage.instance;


      var firebaseStorageRef=await FirebaseStorage.instance.ref().child('uploads/$fileName');
        UploadTask uploadTask = firebaseStorageRef.putFile(imageFile!);
        TaskSnapshot taskSnapshot = await uploadTask;
           taskSnapshot.ref.getDownloadURL().then(
              (value) {
                setState(() {
                  imageUrl=value;
                });
              },
        );

        //  sendNotificationToAllUsers();
      } on FirebaseException catch (error) {}
    } catch (err) {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("ADD "),
        backgroundColor: Colors.green,
      ),
      body: Column(
        children: <Widget>[

          Padding(
            padding: const EdgeInsets.only(left: 12,right: 12,top: 12),
            child: imageFile == null
                ? InkWell(
                    onTap: () {
                      _upload();
                    },
                    child: Text('PickImage'))
                : Image.file(File(imageFile!.path.toString(),),width: 100,height: 100,),
          ),
          SizedBox(height: 12,),
          TextField(
            decoration: InputDecoration(
                focusedBorder: new UnderlineInputBorder(
                    borderSide: new BorderSide(
                        color: Colors.green,
                        width: 2,
                        style: BorderStyle.solid)),
                labelText: "Title",
                icon: Icon(
                  Icons.assignment,
                  color: Colors.orangeAccent,
                ),
                fillColor: Colors.white,
                labelStyle: TextStyle(
                  color: Colors.green,
                )),
            onChanged: (value) {
              productName = value;
            },
            controller: productNameController,
          ),
          TextField(

            decoration: InputDecoration(
                focusedBorder: new UnderlineInputBorder(
                    borderSide: new BorderSide(
                        color: Colors.green,
                        width: 2,
                        style: BorderStyle.solid)),
                labelText: "Desc",
                icon: Icon(
                  Icons.assignment,
                  color: Colors.orangeAccent,
                ),
                fillColor: Colors.white,
                labelStyle: TextStyle(
                  color: Colors.green,
                )),
            onChanged: (value) {
              productPrice = value;
            },
            controller: productPriceController,
          ),

          Row(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(top: 8.0, left: 40),
                child: ElevatedButton(
                  // color: Colors.black,
                  child: Text(
                    "Add",
                    style: TextStyle(color: Colors.white),
                  ),
                  onPressed: () {
                    uploadingData(
                        productName, productPrice, imageUrl, isFavourite);
                    sendNotificationToAllUsers();

                    Navigator.of(context).pop();
                  },
                ),
              )
            ],
          ),
        ],
      ),
    );
  }
}
