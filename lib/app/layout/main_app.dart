import 'package:devconnect_app/app/company/company_login.dart';
import 'package:devconnect_app/app/component/custimbottombar.dart';
import 'package:devconnect_app/app/developer/profile.dart';
import 'package:devconnect_app/app/layout/home.dart';
import 'package:devconnect_app/app/project/project_write.dart';
import 'package:devconnect_app/app/developer/DeveloperLogin.dart';
import 'package:devconnect_app/app/rating/crating.dart';
import 'package:devconnect_app/style/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:percent_indicator/percent_indicator.dart';

class MainApp extends StatefulWidget {
  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  int selectedIndex = 0;

  final List<Widget> pages = [
    Home(),
    WriteProject(),
    Profile(), // 가운데 탭
    Companylogin(), // 임시 로그인 창
    DeveloperLogIn(),
    Rating(), // 5 : 평가페이지
  ];

  final List<String> pageTitle = [
    '프로젝트',
    '프로젝트 등록',
    '계정 관리',
    '기업 로그인',
    '개발자 로그인',
    '평가페이지', // 5
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 가상 키보드가 열릴 픽셀이 오버되는 현상 없앰 | false
      resizeToAvoidBottomInset : false,
      appBar: AppBar(
        title: Text(
          pageTitle[selectedIndex],
          style: TextStyle(
            color: AppColors.textColor,
            fontFamily: "NanumGothic",
            fontWeight: FontWeight.bold,
          ),
        ),
        // backgroundColor: AppColors.bgColor,
        // shape : Border(bottom : BorderSide(color : Color(0x5F000000), width : 1)),
      ),
      body: pages[selectedIndex],
      bottomNavigationBar: CustomBottomNavBar(
        selectedIndex: selectedIndex,
        onTap: (index) {
          setState(() {
            selectedIndex = index;
          });
        },
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