import 'package:devconnect_app/home.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(DevConnect());
}

class DevConnect extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner : false,
      theme : ThemeData(
        scaffoldBackgroundColor : Colors.white,
      ),
      home : Home(),
    );
  }

}

