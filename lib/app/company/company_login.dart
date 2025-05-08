

import 'package:devconnect_app/app/company/company_signup.dart';
import 'package:devconnect_app/app/layout/company_main_app.dart';
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

  //오류메시지 변수
  String errorMessage = '';


  //2. 자바 통신
  void login() async{
    // 로그인 시도 전에 이전 오류 메시지 초기화
    setState(() {
      errorMessage = '';
    });

    try{
      Dio dio = Dio();
      final sendData={
        'cid' : idController.text,
        'cpwd' : pwdController.text,
      };print("1234");
      final response = await dio.post("${serverPath}/api/company/login" ,data: sendData );
      final data = response.data;
      print("로그인쪽 data정보 : $data");

      if(data != null){
        SharedPreferences prefs = await SharedPreferences.getInstance();

        await prefs.setString('token', data); // SharePreference에 토큰 저장

        setState(() {
          errorMessage = '';
        });
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => CompanyMainApp())); // 추후 루트 수정하기
      }

    }on DioException catch(e){
     if(e.response == null && e.response!.statusCode == 401) {
       print("로그인실패");
       setState(() {
         errorMessage = "존재하지않는 회원입니다.";
       });
     }else {
       print("로그인오류");
       setState(() {
         errorMessage = "로그인중 오류가 발생했습니다.";
       });
     }
    }
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
          mainAxisSize: MainAxisSize.min,
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

            if(errorMessage.isNotEmpty)
              Padding(padding: EdgeInsets.only(top: 8.0),
                child: Text(errorMessage,
                style: TextStyle(
                  color: Colors.red,
                  fontSize: 12.0,
                  fontFamily: "NanumGothic" , //폰트유지
                ),
                textAlign: TextAlign.center,
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
                    backgroundColor: AppColors.buttonColor,
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