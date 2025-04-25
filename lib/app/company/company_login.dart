

import 'package:flutter/material.dart';

class Companylogin extends StatefulWidget{
  @override
  State<StatefulWidget> createState() {
    return _CompanyLogin();
  }
}

// 입력상자 컨트롤러
TextEditingController idController = TextEditingController();
TextEditingController pwdController = TextEditingController();

class _CompanyLogin extends State<Companylogin>{
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue,
      body: Container(
        padding: EdgeInsets.fromLTRB(30, 50, 30, 120),
        margin: EdgeInsets.fromLTRB(30, 150, 30, 230),  // left, top , light, bottom
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [ // 하위 요소들 위젯
            SizedBox(
             width : double.infinity, // 넓이 화면 크기에 따라 자동 조절
            child:
            TextField(
              controller: idController,
              decoration: InputDecoration(
                labelText: "id",
                border: OutlineInputBorder(),

              ),
            ),),


            SizedBox(height: 20,),


            SizedBox(
              width: double.infinity,
              child: TextField(
              controller: pwdController,
              obscureText: true, // 입력값 감추기
              decoration: InputDecoration(
                labelText: "비밀번호",
                border: OutlineInputBorder(),
              ),
            ),),

            SizedBox(height: 20,),

            SizedBox(
              width: double.infinity,
              child:
            ElevatedButton(onPressed: ()=>{}, style: ButtonStyle(backgroundColor: WidgetStateProperty.resolveWith<Color>(
                (Set<WidgetState> states) {
                  if(states.contains(WidgetState.pressed)){
                  return Colors.blue.shade700;
                }
                return Colors.blue; // 기본 배경색은 파란
                }
            ),
              shape: WidgetStateProperty.all<OutlinedBorder>(
                RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),  // 둥글기 크기 조절
                )
              ) ,

            ), child: Text("로그인", style: TextStyle(color: Colors.black),),),),

            SizedBox(height: 20,),

            SizedBox(
              width: double.infinity,
              child:
              ElevatedButton(onPressed: ()=>{}, style: ButtonStyle(backgroundColor: WidgetStateProperty.resolveWith<Color>(
                      (Set<WidgetState> states) {
                    if(states.contains(WidgetState.pressed)){
                      return Colors.blue.shade700;
                    }
                    return Colors.blue; // 기본 배경색은 파란
                  }
              ),
                shape: WidgetStateProperty.all<OutlinedBorder>(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),  // 둥글기 크기 조절
                    )
                ) ,

              ), child: Text("회원가입", style: TextStyle(color: Colors.black),),),),

          ],
        ),
      ),

    );
  }
}