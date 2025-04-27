import 'package:devconnect_app/app/company/company_login.dart';
import 'package:devconnect_app/app/component/custimbottombar.dart';
import 'package:devconnect_app/app/developer/profile.dart';
import 'package:devconnect_app/app/layout/home.dart';
import 'package:devconnect_app/app/project/project_write.dart';
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
    Home(),
    WriteProject(),
    Profile(), // 가운데 탭
    Companylogin(), // 임시 로그인 창
    Text("게시물3 페이지"),
  ];

  final List<String> pageTitle = [
    '프로젝트',
    '프로젝트 등록',
    '프로필',
    '게시물2',
    '게시물3',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 가상 키보드가 열릴 픽셀이 오버되는 현상 없앰 | false
      resizeToAvoidBottomInset : false,
      appBar: AppBar(
        title: Text(
          pageTitle[selectedIndex],
          style: TextStyle(color: AppColors.black),
        ),
        // backgroundColor: AppColors.white,
        // shape : Border(bottom : BorderSide(color : Color(0x5F000000), width : 1)),
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
    );
  }
}