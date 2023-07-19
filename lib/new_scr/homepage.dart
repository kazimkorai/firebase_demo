import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_demo/new_scr/productItem.dart';

import 'package:flutter/material.dart';

import 'addProduct.dart';

class HomePage extends StatefulWidget {
  static const routeName = 'homePage';

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String id = '';

 Future<void> stream() async  {
  await FirebaseFirestore.instance.collection("products").snapshots();

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(child: Icon(Icons.add),onPressed: () {

        Navigator.of(context).pushNamed(AddUser.routeName);
      }),
      appBar: AppBar(
        title: Text("Product Items"),
        actions: <Widget>[

        ],
        backgroundColor: Colors.green,
      ),
      body: 0 == 0
          ? RefreshIndicator(

              onRefresh: () async {
                stream();
              },
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection("products")
                    .snapshots(),
                builder: (context, snapshot) {
                  return !snapshot.hasData
                      ? Center(child: CircularProgressIndicator())
                      : ListView.builder(
                          itemCount: snapshot.data!.size,
                          itemBuilder: (context, index) {
                            DocumentSnapshot data =
                                snapshot.requireData.docs[index];
                            return ProductItem(
                              documentSnapshot: data,
                              id: data.id,
                              isFavourite: data['isFavourite'],
                              imageUrl: data['imageUrl'],
                              productName: data['productName'],
                              productPrice: data['productPrice'],
                            );
                          },
                        );
                },
              ),
            )
          : StreamBuilder<QuerySnapshot>(
              stream:
                  FirebaseFirestore.instance.collection("products").snapshots(),
              builder: (context, snapshot) {
                return !snapshot.hasData
                    ? Center(child: CircularProgressIndicator())
                    : ListView.builder(
                        itemCount: snapshot.data!.size,
                        itemBuilder: (context, index) {
                          DocumentSnapshot data =
                              snapshot.requireData.docs[index];
                          return ProductItem(
                            documentSnapshot: data,
                            id: data.id,
                            isFavourite: data['isFavourite'],
                            imageUrl: data['imageUrl'],
                            productName: data['productName'],
                            productPrice: data['productPrice'],
                          );
                        },
                      );
              },
            ),
    );
  }
}
