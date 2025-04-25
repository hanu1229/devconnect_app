import 'package:flutter/material.dart';

class Profile extends StatefulWidget{
  @override
  _ProfileState createState() {
    return _ProfileState();
  }
}

class _ProfileState extends State< Profile >{
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: Text("프로필"),
      ),
    );
  }
}
