import 'package:flutter/material.dart';

import 'addProduct.dart';
import 'homepage.dart';



class CrudFirestore extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: HomePage.routeName,
      routes: {
        HomePage.routeName:(ctx) =>HomePage(),
        AddUser.routeName:(ctx) =>AddUser(),
      },
    );
  }
}
