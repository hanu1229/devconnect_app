// home.dart : 메인 페이지

import "package:devconnect_app/style/app_colors.dart";
import "package:flutter/material.dart";

class Home extends StatefulWidget {

  @override
  State<Home> createState() => _HomeState();

}

class _HomeState extends State<Home> {
  // 페이지 위젯 리스트 // 나중에 내용물 바꿔치기할때 사용 (body적용)
  List<Widget> pages = [
    Text("메인페이지"),
    Text("2"),
    Text("3"), // 가운데 경험치바(?)
    Text("4"),
    Text("5"),
  ];
  // 페이지 위젯 리스트 end

  // 페이지 상단 제목 리스트 // test 이후 없앨 예정 구분용
  List<String> pageTitle = [
    '메인페이지' ,
    '2' ,
    '3' , // 가운데 경험치바(?)
    '4' ,
    '5'
  ];
  // 페이지 상단 제목 리스트 end

  // 현재 클릭된 페이지 번호 / 상태 / main은 0
  int selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar : AppBar(
        title : Text(pageTitle[ selectedIndex ] , style: TextStyle( color: Colors.white),),
        backgroundColor: Colors.black,
      ),
      body : Center(
        child : Column(
          children: [
            Text("일반 폰트", style : TextStyle(fontSize : 24, color : AppColors.white)),
            Text("네이버 나눔 고딕 폰트", style : TextStyle(fontFamily : "NanumGothic", fontSize : 24,)),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        onTap: (i) => setState( () { selectedIndex = i; } ),
        currentIndex: selectedIndex,
        type: BottomNavigationBarType.fixed, // 아이콘 고정크기 설정
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home) , label: '메인페이지' ),
          BottomNavigationBarItem(icon: Icon(Icons.forum) , label: '2' ),
          BottomNavigationBarItem(icon: Icon(Icons.person) , label: '3' ),
          BottomNavigationBarItem(icon: Icon(Icons.forum) , label: '4' ),
          BottomNavigationBarItem(icon: Icon(Icons.forum) , label: '5' ),

        ],
      ),
    );
  }

}
