import 'package:devconnect_app/app/company/company_login.dart';
import 'package:devconnect_app/app/component/custimbottombar.dart';
import 'package:devconnect_app/app/developer/profile.dart';
import 'package:devconnect_app/app/layout/home.dart';
import 'package:devconnect_app/app/rating/crating.dart';
import 'package:devconnect_app/style/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:percent_indicator/percent_indicator.dart';

class MainApp extends StatefulWidget {
  @override
  _MainAppState createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  int selectedIndex = 0;

  final List<Widget> pages = [
    Home(),
    Text("게시물1 페이지"),
    Profile(), // 가운데 탭
    Companylogin(), // 임시 로그인 창
    Text("게시물3 페이지"),
    Rating(), // 5 : 평가페이지
  ];

  final List<String> pageTitle = [
    '프로젝트',
    '게시물1',
    '계정 관리',
    '게시물2',
    '게시물3',
    '평가페이지', // 5
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          pageTitle[selectedIndex],
          style: TextStyle(
            color: AppColors.textColor,
            fontFamily: "NanumGothic",
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: AppColors.bgColor,
        shape: Border( bottom: BorderSide( color: AppColors.appBarColor, width: 1 )),
      ),
      body: Stack(
        children: [
          pages[selectedIndex],
          Align(
            alignment: Alignment.bottomCenter,
            child: CustomBottomNavBar(
              selectedIndex: selectedIndex,
              onTap: (index) => setState(() => selectedIndex = index),
            ),
          ),
        ],
      ),
      floatingActionButtonLocation:  FloatingActionButtonLocation.endDocked,
      floatingActionButton: Container(
        margin: EdgeInsets.only( bottom: 105, right: 10),
        child: SpeedDial(
          icon: Icons.add, // 기본 아이콘
          activeIcon: Icons.close, // 활성화된 상태 아이콘
          // spacing: 0, // + 아이콘과 열리는 아이콘의 간격
          spaceBetweenChildren: 20, // 열렸을 때 아이콘들의 간격
          children: [
            SpeedDialChild(
              child: Icon(Icons.home),
              label: '평가',
              onTap: (){
                setState(() {
                  selectedIndex = 5;
                });
              },
            ),
            SpeedDialChild(
              child: Icon(Icons.home),
              label: '홈',
            ),
            SpeedDialChild(
              child: Icon(Icons.home),
              label: '홈',
            ),SpeedDialChild(
              child: Icon(Icons.home),
              label: '홈',
            ),
            SpeedDialChild(
              child: Icon(Icons.home),
              label: '홈',
            ),
          ],
        ),
      ),
    );
  }
}