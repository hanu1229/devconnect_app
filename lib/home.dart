// home.dart : 메인 페이지

import "package:devconnect_app/style/app_colors.dart";
import "package:flutter/material.dart";

class Home extends StatefulWidget {

  @override
  State<Home> createState() => _HomeState();

}

class _HomeState extends State<Home> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar : AppBar(
        title : Text("메인페이지"),
      ),
      body : Center(
        child : Column(
          children: [
            Text("일반 폰트", style : TextStyle(fontSize : 24, color : AppColors.subColor)),
            Text("네이버 나눔 고딕 폰트", style : TextStyle(fontFamily : "NanumGothic", fontSize : 24,)),
          ],
        ),
      ),
    );
  }

}
