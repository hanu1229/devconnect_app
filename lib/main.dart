import 'package:devconnect_app/app/layout/main_app.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(DevConnect());
}

class DevConnect extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme : ThemeData(
        scaffoldBackgroundColor : Colors.white,
      ),
      // 앱 탭 이름
      title: "DevConnect",
      home : MainApp(),
    );
  }

}

