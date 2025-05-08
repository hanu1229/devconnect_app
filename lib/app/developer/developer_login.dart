
import 'package:devconnect_app/app/component/custom_outlinebutton.dart';
import 'package:devconnect_app/app/component/custom_textbutton.dart';
import 'package:devconnect_app/app/developer/developer_signup.dart';
import 'package:devconnect_app/app/layout/main_app.dart';
import 'package:devconnect_app/style/app_colors.dart';
import 'package:devconnect_app/style/server_path.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DeveloperLogIn extends StatefulWidget{

  @override
  _DeveloperLogInState createState() {
    return _DeveloperLogInState();
  }
}

class _DeveloperLogInState extends State< DeveloperLogIn >{
  TextEditingController didController = TextEditingController();
  TextEditingController dpwdController = TextEditingController();
  String errorMsg = '';

  void login() async{
    try{
      Dio dio = Dio();
      final sendData={
        'did' : didController.text,
        'dpwd' : dpwdController.text,
      };
      final response = await dio.post("${serverPath}/api/developer/login" ,data: sendData );
      final data = response.data;
      if(data['data'] != ''){
        SharedPreferences prefs = await SharedPreferences.getInstance();

        await prefs.setString('token', data['data']);

        Navigator.pushReplacement( context, MaterialPageRoute(builder: (context) => MainApp())); // 추후 루트 수정하기
      }else{
        print("로그인 실패");
      }

    } on DioException catch(e){
      setState(() {
        errorMsg = e.response?.data['message'] ?? '아이디와 비밀번호를 확인해주세요.';
      });
    }catch(e){
      print(e);
      setState(() {
        errorMsg = '서버 오류 발생';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset : false,
      backgroundColor: Color(0xFF0078FF),
      body: Container(
        height: 420,
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
                controller: didController,
                style: TextStyle( fontSize: 13, ),
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
                controller: dpwdController,
                obscureText: true, // 입력값 감추기
                style: TextStyle( fontSize: 13, ),
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
            SizedBox(height: 8,),

            if (errorMsg.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(left: 15),
                child: Text(
                  errorMsg,
                  style: TextStyle(
                      color: Color(0xffbc443d),
                      fontSize: 12
                  ),
                ),
              ),
            SizedBox(height: 8,),

            CustomTextButton(
              onPressed: login,
              title: "로그인",
              width: double.infinity,
            ),

            SizedBox(height: 10,),

            CustomOutlineButton(
              onPressed: () => {
                Navigator.push( context,
                    MaterialPageRoute( builder : (context) =>
                        DeveloperSignUp( changePage: (index) => index, ) )
                ),
              },
              title: "회원가입",
              width: double.infinity,
            ),
            
            
          ],
        ),
      ),
    );
  }
}