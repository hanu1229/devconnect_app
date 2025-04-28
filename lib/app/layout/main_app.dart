import 'package:devconnect_app/app/company/company_login.dart';
import 'package:devconnect_app/app/component/custombottombar.dart';
import 'package:devconnect_app/app/developer/DeveloperLogin.dart';
import 'package:devconnect_app/app/developer/profile.dart';
import 'package:devconnect_app/style/app_colors.dart';
import 'package:flutter/material.dart';

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
    Companylogin(), // 임시 로그인 창
    DeveloperLogIn(),
  ];

  final List<String> pageTitle = [
    '프로젝트',
    '게시물1',
    '계정 관리',
    '게시물2',
    '개발자 로그인',
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
      body: pages[selectedIndex],
      bottomNavigationBar: CustomBottomNavBar(
        selectedIndex: selectedIndex,
        onTap: (index) {
          setState(() {
            selectedIndex = index;
          });
        },
      ),
    );
  }
}