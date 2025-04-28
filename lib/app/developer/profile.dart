
import 'package:devconnect_app/style/app_colors.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

String baseUrl = "http://localhost:8080";

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
  // 수정 상태 확인
  bool isUpdate = false;

  @override
  void initState() {
    loginCheck();
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

  // 회원정보 가져오기
  Map<String, dynamic> developer = {};

  void onInfo( token ) async {
    try{
      dio.options.headers['Authorization'] = token;
      final response = await dio.get("${baseUrl}/api/developer/info");
      final data = response.data;
      if( data != '' ){
        setState(() {
          developer = data;
        });
      }
    }catch( e ){ print( e ); }
  } // f end

  TextEditingController didController = TextEditingController();
  TextEditingController dpwdController = TextEditingController();
  TextEditingController dnameController = TextEditingController();
  TextEditingController demailController = TextEditingController();
  TextEditingController daddressController = TextEditingController();
  TextEditingController dlevelController = TextEditingController();

  @override
  Widget build(BuildContext context) {

    if( developer.isEmpty ){ return Center( child: CircularProgressIndicator(), ); }

    final image = developer['dprofile'];
    String imgUrl = "${baseUrl}/upload/${image}";

    // if( !isLogIn ){ Navigator.pushNamed( context, MainApp() ) }

    return Scaffold(
      body: SingleChildScrollView(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: MediaQuery.of( context ).size.height * 0.7,
          ),
          child: Column(
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

                    SizedBox( height: 10 ,),

                    // 첫번째 Card
                    SizedBox(
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
                              ClipRRect(
                                borderRadius: BorderRadius.circular(999),
                                child: Container(
                                  width: 100, height: 100,
                                  child: Image.network(
                                    imgUrl,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),

                              SizedBox( height: 12,),

                              Text( developer['did'] ),

                              SizedBox( height: 12,),

                              OutlinedButton(
                                onPressed: () {
                                  setState(() {
                                    isUpdate = true;
                                    didController = TextEditingController(text: developer['did']);
                                    dnameController = TextEditingController(text: developer['dname']);
                                    demailController = TextEditingController(text: developer['demail']);
                                    daddressController = TextEditingController(text: developer['daddress']);
                                  });
                                },
                                child: Text("수정"),
                              )
                            ]
                          )
                            : // 수정버튼 클릭 후
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Center(
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(999),
                                  child: Container(
                                    width: 100, height: 100,
                                    child: Image.network(
                                      imgUrl,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                              ),

                              SizedBox( height: 12,),

                              Text("아이디"),

                              SizedBox( height: 12,),

                              TextField(
                                controller: didController,
                                readOnly: true,
                                decoration: InputDecoration(
                                  filled: true,
                                  fillColor: AppColors.textFieldBGColor,
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular( 8 ),
                                    borderSide: BorderSide(
                                      width: 1.5,
                                      color: AppColors.textFieldColor,
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular( 8 ),
                                    borderSide: BorderSide(
                                      width: 1.5,
                                      color: AppColors.textFieldColor,
                                    ),
                                  ),
                                ),
                              ),

                              SizedBox( height: 12,),

                              Text("이름"),

                              SizedBox( height: 12,),

                              TextField(
                                controller: dnameController,
                                decoration: InputDecoration(
                                  filled: true,
                                  fillColor: AppColors.textFieldBGColor,
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular( 8 ),
                                    borderSide: BorderSide(
                                      width: 1.5,
                                      color: AppColors.textFieldColor,
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular( 8 ),
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
                                controller: demailController,
                                decoration: InputDecoration(
                                  filled: true,
                                  fillColor: AppColors.textFieldBGColor,
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular( 8 ),
                                    borderSide: BorderSide(
                                      width: 1.5,
                                      color: AppColors.textFieldColor,
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular( 8 ),
                                    borderSide: BorderSide(
                                      width: 3,
                                      color: AppColors.focusColor,
                                    )
                                  ),
                                ),
                              ),

                              SizedBox( height: 12,),

                              Text("주소"),

                              SizedBox( height: 12,),

                              TextField(
                                controller: daddressController,
                                decoration: InputDecoration(
                                  filled: true,
                                  fillColor: AppColors.textFieldBGColor,
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular( 8 ),
                                    borderSide: BorderSide(
                                      width: 1.5,
                                      color: AppColors.textFieldColor,
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular( 8 ),
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
                                  SizedBox(
                                    width: 80, height: 40,
                                    child: OutlinedButton(
                                      onPressed: () => { setState(() => { isUpdate = false }) },
                                      child: Text("취소"),
                                      style: OutlinedButton.styleFrom(
                                        side: BorderSide(
                                          color: AppColors.textFieldColor,
                                          width: 1,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular( 5 ),
                                        ),
                                      ),
                                    ),
                                  ),

                                  SizedBox( width: 15,),

                                  SizedBox(
                                    width: 80, height: 40,
                                    child: TextButton(
                                      onPressed: () => { },
                                      child: Text("저장"),
                                      style: TextButton.styleFrom(
                                        backgroundColor: Colors.blueAccent,
                                        foregroundColor: Colors.white,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular( 5 ),
                                        )
                                      )
                                    ),
                                  )
                                ],
                              )
                            ],
                          ),
                        ),
                      )
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
                            color: AppColors.cardBorderColor,
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
                            color: AppColors.cardBorderColor,
                          ),
                        ),
                        elevation: 0,
                        color: Colors.white,
                      ),
                    ),

                    SizedBox(height: 50 + MediaQuery.of(context).padding.bottom),

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
