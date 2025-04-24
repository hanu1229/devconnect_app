import 'package:devconnect_app/app/member/profile.dart';
import 'package:devconnect_app/style/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';

class MainApp extends StatefulWidget {
  @override
  _MainAppState createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  int selectedIndex = 0;

  final List<Widget> pages = [
    Text("프로젝트"),
    Text("게시물1 페이지"),
    Profile(), // 가운데 탭
    Text("게시물2 페이지"),
    Text("게시물3 페이지"),
  ];

  final List<String> pageTitle = [
    '프로젝트',
    '게시물1',
    '프로필',
    '게시물2',
    '게시물3',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          pageTitle[selectedIndex],
          style: TextStyle(color: AppColors.textColor),
        ),
        backgroundColor: AppColors.bgColor,
      ),
      body: pages[selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: selectedIndex,
        onTap: (index) => setState(() => selectedIndex = index),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.folder), label: '프로젝트'),
          BottomNavigationBarItem(icon: Icon(Icons.article), label: '게시물1'),

          // ✅ 가운데만 경험치 링 프로필로 표현
          BottomNavigationBarItem(
            icon: SizedBox(
              height: 40,
              width: 40,
              child: CircularPercentIndicator(
                radius: 20.0,
                lineWidth: 5.0,
                percent: 0.25,
                center: CircleAvatar(
                  radius: 15,
                  backgroundImage: NetworkImage('https://i.pravatar.cc/150?img=3'),
                ),
                progressColor: Colors.blue,
                backgroundColor: Colors.grey.shade300,
                circularStrokeCap: CircularStrokeCap.round,
              ),
            ),
            label: '프로필',
          ),

          BottomNavigationBarItem(icon: Icon(Icons.article_outlined), label: '게시물2'),
          BottomNavigationBarItem(icon: Icon(Icons.article_outlined), label: '게시물3'),
        ],
      ),
    );
  }
}