

import 'package:devconnect_app/app/company/company_signup.dart';
import 'package:devconnect_app/app/layout/main_app.dart';
import 'package:devconnect_app/style/server_path.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Companylogin extends StatefulWidget{
  @override
  State<StatefulWidget> createState() {
    return _CompanyLogin();
  }
}



class _CompanyLogin extends State<Companylogin>{

// 입력상자 컨트롤러
  TextEditingController idController = TextEditingController();
  TextEditingController pwdController = TextEditingController();


  //2. 자바 통신
  void login() async{
    try{
      Dio dio = Dio();
      final sendData={
        'cid' : idController.text,
        'cpwd' : pwdController.text,
      };
      final response = await dio.post("${serverPath}/api/company/login" ,data: sendData );
      final data = response.data;
      if(data != ''){
        SharedPreferences prefs = await SharedPreferences.getInstance();

        await prefs.setString('token', data);

        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => MainApp())); // 추후 루트 수정하기
      }else{
        print("회원가입실패");
      }

    }catch(e){print(e);}
  }







  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset : false,
      backgroundColor: Colors.blue,
      body: Container(
        padding: EdgeInsets.fromLTRB(30, 50, 30, 120),
        margin: EdgeInsets.fromLTRB(30, 100, 30, 160),  // left, top , light, bottom
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
              controller: idController, // id 값 저장 controller
              decoration: InputDecoration(
                labelText: "id",
                border: OutlineInputBorder(),

              ),
            ),),


            SizedBox(height: 20,),


            SizedBox(
              width: double.infinity,
              child: TextField(
              controller: pwdController,    // 비밀번호값 저장 controller
              obscureText: true, // 입력값 감추기
              decoration: InputDecoration(
                labelText: "비밀번호",
                border: OutlineInputBorder(),
              ),
            ),),

            SizedBox(height: 15,),

            SizedBox(
              width: double.infinity,
              child:
            ElevatedButton(onPressed: login, style: ButtonStyle(backgroundColor: WidgetStateProperty.resolveWith<Color>( // 로그인시 연결
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

            SizedBox(height: 15,),

            SizedBox(
              width: double.infinity,
              child:
              ElevatedButton(onPressed: ()=>{Navigator.pushReplacement(context , MaterialPageRoute(builder: (context)=> Signup()) )}, style: ButtonStyle(backgroundColor: WidgetStateProperty.resolveWith<Color>( // 회원가입시 연결
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