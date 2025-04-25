

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
        padding: EdgeInsets.all(30),
        margin: EdgeInsets.fromLTRB(60, 120, 60, 120),  // left, top , light, bottom
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [ // 하위 요소들 위젯
            TextField(
              controller: idController,
              decoration: InputDecoration(
                labelText: "id",
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20,),
            TextField(controller: pwdController,
              obscureText: true, // 입력값 감추기
              decoration: InputDecoration(
                labelText: "비밀번호",
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20,),
            ElevatedButton(onPressed: ()=>{}, child: Text("로그인"), style: ButtonStyle(backgroundColor: WidgetStateProperty.resolveWith<Color>(
                (Set<WidgetState> states) {
                  if(states.contains(WidgetState.pressed)){
                  return Colors.blue.shade700;
                }}
            ),),),
            SizedBox(height: 20,),
            TextButton(onPressed: ()=>{}, child: Text("회원가입")),
          ],
        ),
      ),

    );
  }
}