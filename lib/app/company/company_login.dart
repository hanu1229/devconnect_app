

import 'package:devconnect_app/app/company/company_signup.dart';
import 'package:devconnect_app/app/layout/company_main_app.dart';
import 'package:devconnect_app/app/layout/home.dart';
import 'package:devconnect_app/app/layout/main_app.dart';
import 'package:devconnect_app/style/server_path.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../style/app_colors.dart';

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
      final response = await dio.post("${companyPath}/api/company/login" ,data: sendData );
      final data = response.data;
      if(data != ''){
        SharedPreferences prefs = await SharedPreferences.getInstance();

        await prefs.setString('token', data);

        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => CompanyMainApp())); // 추후 루트 수정하기
      }else{
        print("회원가입실패");
      }

    }catch(e){print(e);}
  }







  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF0078FF),
      resizeToAvoidBottomInset : false,
      body: Container(
        padding: EdgeInsets.fromLTRB(30, 50, 30, 120),
        margin: EdgeInsets.fromLTRB(30, 100, 30, 0),  // left, top , light, bottom
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
                style: TextStyle(
                  fontFamily: "NanumGothic",
                  fontSize: 13,
                ),
                decoration: InputDecoration(
                  labelText: "id",
                  enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular( 4 ),
                      borderSide: BorderSide(
                        width: 1,
                        color: AppColors.textFieldColor,
                      )
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular( 4 ),
                    borderSide: BorderSide(
                      width: 3,
                      color: AppColors.focusColor,
                    ),
                  ),
                ),
              ),
            ),

            SizedBox(height: 10,),


            SizedBox(
              width: double.infinity,
              child: TextField(
                controller: pwdController,
                obscureText: true, // 입력값 감추기
                style: TextStyle(
                  fontFamily: "NanumGothic",
                  fontSize: 13,
                ),
                decoration: InputDecoration(
                  labelText: "비밀번호",
                  enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular( 4 ),
                      borderSide: BorderSide(
                        width: 1,
                        color: AppColors.textFieldColor,
                      )
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular( 4 ),
                    borderSide: BorderSide(
                      width: 3,
                      color: AppColors.focusColor,
                    ),
                  ),
                ),
              ),
            ),

            SizedBox(height: 15,),

            SizedBox(
              width: double.infinity,
              height: 45,
              child: OutlinedButton(
                onPressed: () => { login() },
                child: Text("로그인", style: TextStyle( fontFamily: "NanumGothic" ),),
                style: TextButton.styleFrom(
                    backgroundColor: Colors.grey,
                    foregroundColor: Colors.white,
                    textStyle: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular( 4 ),
                    ),
                    side: BorderSide(
                      width: 1,
                      color: AppColors.textFieldColor,
                    )
                ),
              ),
            ),

            SizedBox(height: 10,),

            SizedBox(
              width: double.infinity,
              height: 45,
              child: OutlinedButton(
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder:(context) => Signup(),)); // Navigator
                }, //실행할 함수를 정의
                child: Text("회원가입", style: TextStyle( fontFamily: "NanumGothic" ),),
                style: TextButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                    textStyle: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular( 4 ),
                    ),
                    side: BorderSide(
                      width: 1,
                      color: AppColors.textFieldColor,
                    )
                ),
              ),
            )
          ],
        ),
      ),

    );
  }
}