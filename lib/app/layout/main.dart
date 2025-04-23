
import 'package:devconnect_app/app/layout/mainapp.dart';
import 'package:flutter/material.dart';

class MyApp extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "DevConnect", // 앱 탭 이름
      home: MainApp(),
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.white
      ),
    );
  }
}