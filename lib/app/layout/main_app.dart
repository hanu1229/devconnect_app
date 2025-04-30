import 'package:devconnect_app/app/company/company_login.dart';
import 'package:devconnect_app/app/company/company_signup.dart';
import 'package:devconnect_app/app/component/custombottombar.dart';
import 'package:devconnect_app/app/developer/developer_login.dart';
import 'package:devconnect_app/app/developer/developer_signup.dart';
import 'package:devconnect_app/app/developer/profile.dart';
import 'package:devconnect_app/app/layout/home.dart';
import 'package:devconnect_app/app/project/project_view.dart';
import 'package:devconnect_app/app/project/project_write.dart';
import 'package:devconnect_app/app/rating/crating.dart';
import 'package:devconnect_app/style/app_colors.dart';
import 'package:devconnect_app/style/server_path.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
    Signup(),
  ];
  void changePage(int index) {
    setState(() {
      selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    // 이동할 페이지
    final List<Widget> pages = [
      // 하단 바
      Home(), // 0 : 기본 페이지
      WriteProject(), // 1 : 프로젝트 작성 페이지
      Profile(), // 2: 가운데 탭
      Text("기업 목록"), // 3 : 기업 목록
      Text("개발자 순위"), // 4 : 개발자 순위
      // 이동 페이지
      Rating(), // 5 : 평가 페이지
      // DeveloperLogIn( changePage: (index) { setState(() { selectedIndex = index; }); },), // 6 : 개발자 로그인 페이지
      DeveloperLogIn(), // 6 : 개발자 로그인 페이지
      Companylogin(), // 7 : 기업 로그인 페이지
    ];

    // 앱바 제목
    final List<String> pageTitle = [
      '프로젝트', // 0
      '프로젝트 등록', // 1
      '계정 관리', // 2
      '기업 목록', // 3
      '개발자 순위', // 4
      '평가페이지', // 5
      '개발자 로그인', // 6
      '기업 로그인', // 7
    ];

    return Scaffold(
      // 가상 키보드가 열릴 픽셀이 오버되는 현상 없앰 | false
      resizeToAvoidBottomInset : false,
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              height: 100,
              alignment: Alignment.center,
              child: Image.asset("assets/images/logo.png", fit: BoxFit.contain,),
            ),
            Text(
              pageTitle[selectedIndex],
              style: TextStyle(
                color: AppColors.textColor,
                fontFamily: "NanumGothic",
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        )
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
              label: '평가',
              onTap: (){
                setState(() {
                  selectedIndex = 5;
                });
              },
            ),
            SpeedDialChild(
              label: '개발자 로그인',
              onTap: (){
                setState(() {
                  selectedIndex = 6;
                });
              },
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
              label: '임시',
              onTap : () async {
                // 임시
                Dio dio = Dio();
                final prefs = await SharedPreferences.getInstance();
                final token = prefs.getString("token");
                if(token == null) { print("토큰 없음"); return; }
                Navigator.push(
                  context,
                  MaterialPageRoute(builder : (context) => ViewProject()),
                );
              }
            ),
          ],
        ),
      ),
    );
  }
}