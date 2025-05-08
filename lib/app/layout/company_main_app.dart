import 'package:devconnect_app/app/company/company_login.dart';
import 'package:devconnect_app/app/company/company_bottombar.dart';
import 'package:devconnect_app/app/company/company_profile.dart';
import 'package:devconnect_app/app/company/company_projectview.dart';
import 'package:devconnect_app/app/developer/developer_login.dart';
import 'package:devconnect_app/app/layout/home.dart';
import 'package:devconnect_app/app/project/project_view.dart';
import 'package:devconnect_app/app/project/project_write.dart';
import 'package:devconnect_app/app/rating/rating_main.dart';
import 'package:devconnect_app/app/rating/rating_view.dart';
import 'package:devconnect_app/style/app_colors.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../developer/profile.dart';

class CompanyMainApp extends StatefulWidget {
  @override
  _CompanyMainApp createState() {
    return _CompanyMainApp();
  }
}

class _CompanyMainApp extends State<CompanyMainApp> {
  int selectedIndex = 0;

  void changePage(int index) {
    setState(() {
      selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    // 이동할 페이지
    final List<Widget> pages = [
      Home(),
      WriteProject(changePage : changePage),
      Companyprofile(changePage: changePage,), // 가운데 탭
      ViewProject(), // 3 : 내프로젝트( 메뉴탭 X )
      RatingMain(), // 4 : 개발자 평가페이지(전체)
      DeveloperLogIn(), // 5 : 개발자 로그인 페이지
      Companylogin(), // 6 : 기업 로그인 페이지
      RatingView(changePage: changePage,), // 7 : 개발자 평가페이지(로그인한 회원)
      CompanyProjectView(changePage : changePage), // 8 : 내 프로젝트( 메뉴탭 O )
    ];

    // 앱바 제목
    final List<String> pageTitle = [
      '프로젝트', // 0
      '프로젝트 등록', // 1
      '기업계정 관리', // 2
      '내 프로젝트', // 3
      '전체평가', // 4
      '개발자 로그인', // 5
      '기업 로그인', // 6
      '기업계정 관리', // 7
      '기업계정 관리', // 8
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

      ),
      body: pages[selectedIndex],
      bottomNavigationBar: CompanyBottomNavBar( // 이부분 변경
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