
import 'package:devconnect_app/style/app_colors.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

String path = "http://localhost:8080/api/developer";

class Profile extends StatefulWidget{
  @override
  _ProfileState createState() {
    return _ProfileState();
  }
}

class _ProfileState extends State< Profile >{
  
  Dio dio = Dio();
  
  // 상태변수
  int mno = 0;
  String did = "";
  String dname = "";
  // 수정 상태 확인
  bool isUpdate = false;

  @override
  void initState() {

  } // f end
  
  // 로그인 상태 확인
  bool? isLogIn;

  void loginCheck() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if( token != null && token.isNotEmpty ){
      setState(() {
        isLogIn = true; print("로그인 중");
        onInfo( token );
      });
    }else{
      // Navigator.pushReplacement( context, MaterialPageRoute(builder: ( context ) =>  ) )
    }
  } // f end

  Map<String, Object> dList = {};

  void onInfo( token ) async {
    try{
      dio.options.headers['Authorization'] = token;
      final response = await dio.get( path + "/info" );
      final data = response.data;
      if( data != '' ){
        setState(() {
          dList = data;
        });
      }
    }catch( e ){ print( e ); }
  } // f end

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: MediaQuery.of( context ).size.height,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: EdgeInsets.all( 20 ),
                color: Color(0xfffbfbfb),
                width: double.infinity,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    Text("기본 정보",
                      style: TextStyle(
                        fontFamily: "NanumGothic",
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    SizedBox( height: 20 ,),

                    // 첫번째 Card
                    SizedBox(
                      height: 500,
                      width: double.infinity,
                      child: Card(
                        shape: RoundedRectangleBorder(
                          borderRadius:
                          BorderRadius.circular(12),
                          side: BorderSide(
                            width: 1,
                            color: AppColors.cardBorderColor,
                          ),
                        ),
                        elevation: 0,
                        color: Colors.white,
                        child: Padding(
                          padding: EdgeInsets.all( 20 ),
                          child:
                          !isUpdate
                            ? // 수정버튼 클릭 전
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text("테스트"),
                              OutlinedButton(
                                onPressed: () => { setState(() => { isUpdate = true }) },
                                child: Text("수정"),
                              )
                            ]
                          )
                            : // 수정버튼 클릭 후
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("아이디"),

                              SizedBox( height: 12,),

                              TextField(
                                decoration: InputDecoration(
                                  filled: true,
                                  fillColor: AppColors.textFieldBGColor,
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular( 12 ),
                                    borderSide: BorderSide(
                                      width: 1.5,
                                      color: AppColors.textFieldColor,
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular( 12 ),
                                    borderSide: BorderSide(
                                      width: 3,
                                      color: AppColors.focusColor,
                                    ),
                                  ),
                                ),
                              ),

                              SizedBox( height: 12,),

                              Text("이름"),

                              SizedBox( height: 12,),

                              TextField(
                                decoration: InputDecoration(
                                  filled: true,
                                  fillColor: AppColors.textFieldBGColor,
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular( 12 ),
                                    borderSide: BorderSide(
                                      width: 1.5,
                                      color: AppColors.textFieldColor,
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular( 12 ),
                                      borderSide: BorderSide(
                                        width: 3,
                                        color: AppColors.focusColor,
                                      )
                                  ),
                                ),
                              ),

                              SizedBox( height: 12,),

                              Text("이메일"),

                              SizedBox( height: 12,),

                              TextField(
                                decoration: InputDecoration(
                                  filled: true,
                                  fillColor: Color(0xfffbfbfb),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular( 12 ),
                                    borderSide: BorderSide(
                                      width: 1.5,
                                      color: AppColors.textFieldColor,
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular( 12 ),
                                      borderSide: BorderSide(
                                        width: 3,
                                        color: AppColors.focusColor,
                                      )
                                  ),
                                ),
                              ),

                              SizedBox( height: 15,),

                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  TextButton(
                                    onPressed: () => { setState(() => { isUpdate = false }) },
                                    child: Text("이전"),
                                  ),

                                  SizedBox( width: 10,),

                                  TextButton(
                                    onPressed: () => { },
                                    child: Text("저장")
                                  ),
                                ],
                              )

                            ],
                          ),
                        )
                      ),
                    ),

                    SizedBox( height: 20,),

                    SizedBox(
                      height: 200,
                      width: double.infinity,
                      child: Card(
                        shape: RoundedRectangleBorder(
                          borderRadius:
                          BorderRadius.circular(12),
                          side: BorderSide(
                            width: 1,
                            color: Color(0xffccdbe3),
                          ),
                        ),
                        elevation: 0,
                        color: Colors.white,
                      ),
                    ),
                    
                    SizedBox( height: 20,),

                    SizedBox(
                      height: 200,
                      width: double.infinity,
                      child: Card(
                        shape: RoundedRectangleBorder(
                          borderRadius:
                          BorderRadius.circular(12),
                          side: BorderSide(
                            width: 1,
                            color: Color(0xffccdbe3),
                          ),
                        ),
                        elevation: 0,
                        color: Colors.white,
                      ),
                    ),

                    SizedBox( height: 90 ,),

                  ],
                )
              ),
            ],
          ),
        ),
      )
    );
  }
}
