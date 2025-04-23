
import 'package:flutter/material.dart';

class MainApp extends StatefulWidget{
  @override
  _MainAppState createState() {
    return _MainAppState();
  }
}

class _MainAppState extends State< MainApp >{

  List<Widget> pages = [
    Text("프로젝트"),
    Text("게시물1 페이지"),
    Text("게시물2 페이지"),
    Text("게시물3 페이지"),
  ];

  List<String> pageTitle = [
    '프로젝트',
    '게시물1'
    '게시물2'
    '게시물3',
  ];

  int selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Image(
              image: AssetImage('assets/images/logo.jpg'),
              height: 50,
              width: 50,
            ),
            Text( "" ),
          ],
        ),
        backgroundColor: Colors.white,
      ),
      body: pages[ selectedIndex ],
      bottomNavigationBar: BottomNavigationBar(
        onTap: ( index ) => setState(() { selectedIndex = index; }),
        currentIndex: selectedIndex,
        type: BottomNavigationBarType.fixed,
        items: [
          BottomNavigationBarItem(icon: Icon( Icons.home ), label: '홈' ),
          BottomNavigationBarItem(icon: Icon( Icons.home ), label: '홈' ),
          BottomNavigationBarItem(icon: Icon( Icons.home ), label: '홈' ),
          BottomNavigationBarItem(icon: Icon( Icons.home ), label: '홈' ),
        ],
      ),
    );
  }
}