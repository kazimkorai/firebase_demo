// listViewPostItems.dart
import 'dart:convert';

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart' as path;
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

import 'notification/firebase_notification.dart';

// class MyApp extends StatelessWidget {
//   const MyApp({Key? key}) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       // Remove the debug banner
//       debugShowCheckedModeBanner: false,
//       title: 'Kindacode.com',
//       theme: ThemeData(primarySwatch: Colors.green),
//       home: const ListViewPostItems(),
//     );
//   }
// }

class ListViewPostItems extends StatefulWidget {
  const ListViewPostItems({Key? key}) : super(key: key);

  @override
  State<ListViewPostItems> createState() => _ListViewPostItemsState();
}

class _ListViewPostItemsState extends State<ListViewPostItems> {
  FirebaseStorage storage = FirebaseStorage.instance;
  final databaseRef = FirebaseDatabase.instance.reference();

  Future<void> sendNotification() async {
    final url = Uri.parse('https://fcm.googleapis.com/fcm/send');
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Authorization':
          'key=AAAADE-eIxo:APA91bEbrLxQ8KizBsbxdD-0vbDjivBRAxmZfP_EZ2nU2NvUOIvu_c5itybd3yOtB14Clg631UohZXM2vOyfnTFYJdGfVqJbz3cZG_t3p4VNcZ7v95sgmfA1v3IzV63FVpKlybfv2u5j',
    };
    final body = jsonEncode({
      'notification': {
        'title': 'New Entry Added',
        'body': 'A new entry has been added to the database.',
      },
      'topic': 'yourTopic',
      // Replace with your desired topic to receive the notification
    });
    try {
      final response = await http.post(url, headers: headers, body: body);
      print(response.body.toString() + "*kazim");
      if (response.statusCode == 200) {
        print('Notification sent successfully');
      } else {
        print('Error sending notification');
      }
    } catch (ex) {
      print(ex.toString());
    }
  }

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
      kk();
    } else {
      print("Failed to send notification to all users.");
    }
  }

  void kk() {
    AwesomeNotifications().createNotification(
        content: NotificationContent(
      //simgple notification
      id: 123,
      channelKey: 'basic', //set configuration wuth key "basic"
      title: 'Welcome to FlutterCampus.com',
      body: 'This simple notification is from Flutter App',
    ));
  }

  // Select and image from the gallery or take a picture with the camera
  // Then upload to Firebase Storage
  Future<void> _upload(String inputSource) async {
    final picker = ImagePicker();
    XFile? pickedImage;
    try {
      pickedImage = await picker.pickImage(
          source: inputSource == 'camera'
              ? ImageSource.camera
              : ImageSource.gallery,
          maxWidth: 1920);

      final String fileName = path.basename(pickedImage!.path);
      File imageFile = File(pickedImage.path);

      try {
        // Uploading the selected image with some custom meta data
        var kk = await storage.ref(fileName).putFile(
            imageFile,
            SettableMetadata(customMetadata: {
              'uploaded_by': 'A bad guy',
              'description': 'Some description...'
            }));

        FirebaseFirestore.instance.collection('data').add({
          'title': 'title',
          "desc": "Description",
          "imagePath": kk.state..toString()
        });

        // Refresh the UI

        setState(() {});

        sendNotificationToAllUsers();
      } on FirebaseException catch (error) {
        if (kDebugMode) {
          print(error);
        }
      }
    } catch (err) {
      if (kDebugMode) {
        print(err);
      }
    }
  }

  // Retriew the uploaded images
  // This function is called when the app launches for the first time or when an image is uploaded or deleted
  Future<List<Map<String, dynamic>>> _loadImages() async {
    List<Map<String, dynamic>> files = [];

    final ListResult result = await storage.ref().list();
    final List<Reference> allFiles = result.items;

    await Future.forEach<Reference>(allFiles, (file) async {
      final String fileUrl = await file.getDownloadURL();
      final FullMetadata fileMeta = await file.getMetadata();
      files.add({
        "url": fileUrl,
        "path": file.fullPath,
        "uploaded_by": fileMeta.customMetadata?['uploaded_by'] ?? 'Nobody',
        "description":
            fileMeta.customMetadata?['description'] ?? 'No description'
      });
    });

    return files;
  }

  // Delete the selected image
  // This function is called when a trash icon is pressed
  Future<void> _delete(String ref) async {
    await storage.ref(ref).delete();
    // Rebuild the UI
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: InkWell(onTap: () {}, child: const Text('DemoApp')),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ElevatedButton.icon(
                    onPressed: () => _upload('camera'),
                    icon: const Icon(Icons.camera),
                    label: const Text('camera')),
                ElevatedButton.icon(
                    onPressed: () => _upload('gallery'),
                    icon: const Icon(Icons.library_add),
                    label: const Text('Gallery')),
              ],
            ),
            Expanded(
              child: FutureBuilder(
                future: _loadImages(),
                builder: (context,
                    AsyncSnapshot<List<Map<String, dynamic>>> snapshot) {
                  if (snapshot.connectionState == ConnectionState.done) {
                    return 0 == 0
                        ? RefreshIndicator(
                            child: StreamBuilder(
                              stream: FirebaseFirestore.instance
                                  .collection('data')
                                  .snapshots(),
                              builder: (BuildContext context,
                                  AsyncSnapshot<QuerySnapshot> snapshot) {
                                if (!snapshot.hasData) {
                                  return Center(
                                    child: CircularProgressIndicator(),
                                  );
                                }

                                return ListView(
                                  children: snapshot.data!.docs.map((document) {
                                    return Container(
                                      child: Center(
                                          child: Text(document['title'])),
                                    );
                                  }).toList(),
                                );
                              },
                            ),
                            onRefresh: () {
                              return Future.delayed(
                                Duration(seconds: 1),
                                () {
                                  /// adding elements in list after [1 seconds] delay
                                  /// to mimic network call
                                  ///
                                  /// Remember: setState is necessary so that
                                  /// build method will run again otherwise
                                  /// list will not show all elements
                                  setState(() {
                                    _loadImages();
                                  });
                                },
                              );
                            })
                        : ListView.builder(
                            itemCount: snapshot.data?.length ?? 0,
                            itemBuilder: (context, index) {
                              final Map<String, dynamic> image =
                                  snapshot.data![index];

                              return Card(
                                margin:
                                    const EdgeInsets.symmetric(vertical: 10),
                                child: ListTile(
                                  dense: false,
                                  leading: Image.network(image['url']),
                                  title: Text(image['uploaded_by']),
                                  subtitle: Text(image['description']),
                                  trailing: IconButton(
                                    onPressed: () => _delete(image['path']),
                                    icon: const Icon(
                                      Icons.delete,
                                      color: Colors.red,
                                    ),
                                  ),
                                ),
                              );
                            },
                          );
                  }

                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
