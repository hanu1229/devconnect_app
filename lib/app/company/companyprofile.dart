
import 'package:devconnect_app/app/component/custom_card.dart';
import 'package:devconnect_app/app/component/custom_outlinebutton.dart';
import 'package:devconnect_app/app/component/custom_scrollview.dart';
import 'package:devconnect_app/app/component/custom_textbutton.dart';
import 'package:devconnect_app/app/component/custom_textfield.dart';
import 'package:devconnect_app/style/app_colors.dart';
import 'package:devconnect_app/style/server_path.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Companyprofile extends StatefulWidget{
  @override
  _CompanyProfileState createState() {
    return _CompanyProfileState();
  }
}

class _CompanyProfileState extends State< Companyprofile >{
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
      final response = await dio.get("${serverPath}/api/company/info");
      print("response : $response");
      final data = response.data;
      print("data : $data");
      if( data != '' ){
        setState(() {
          developer = data;
        });
      }
    }catch( e ){ print( e ); }
  } // f end

  final TextEditingController cidController = TextEditingController();
  final TextEditingController cpwdController = TextEditingController();
  final TextEditingController cnameController = TextEditingController();
  final TextEditingController cphoneController= TextEditingController();
  final TextEditingController cadressController = TextEditingController();
  final TextEditingController cemailController = TextEditingController();
  final TextEditingController cbusinessController = TextEditingController();

  // 상세정보 수정
  void onUpdate( ) async {
    final sendData = {
      "cno" : developer['cno'],
      "cpwd" : cpwdController.text,
      "cname" : cnameController.text,
      "cphone" : cphoneController.text,
      "demail" :  cemailController.text,
      "cadress" : cadressController.text,
      "cbusiness" : cbusinessController.text
    };

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    try{
      dio.options.headers['Authorization'] = token;
      final response = await dio.put("${serverPath}/api/company/update", data: sendData);
      final data = response.data;
      if( data ){
        setState(() {
          onInfo( token );
          isUpdate = false;
        });
      }
    }catch( e ){ print( e ); }
  } // f end

  @override
  Widget build(BuildContext context) {

    if( developer.isEmpty ){ return Center( child: CircularProgressIndicator(), ); }

    final image = developer['cprofile']; // 이미지 문제 있었음
    String imgUrl = "${serverPath}/upload/${image}";

    // if( !isLogIn ){ Navigator.pushNamed( context, MainApp() ) }

    return CustomSingleChildScrollview(
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
        CustomCard(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: !isUpdate ? CrossAxisAlignment.center : CrossAxisAlignment.start,
            children: !isUpdate
                ? // 수정버튼 클릭 전
              [
                ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: Container(
                    width: 100, height: 100,
                    child: Image.network( imgUrl, fit: BoxFit.cover, ),
                  ),
                ),
                SizedBox( height: 20, ),

                Text( developer['cname'],   // 이부분 수정함
                    style: TextStyle( fontSize: 20, fontWeight: FontWeight.bold, ) ),
                SizedBox( height: 12, ),

                Text( developer['cemail'], // 이부분 수정함
                    style: TextStyle( fontSize: 15, ) ),
                SizedBox( height: 12, ),

                // 버튼
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    CustomTextButton(
                      onPressed: () => {
                        setState(() {
                          isUpdate = true;
                          cidController.text = developer['cid'];
                          cnameController.text = developer['cname'];
                          cphoneController.text = developer['cphone'];
                          cemailController.text = developer['cemail'];
                          cadressController.text = developer['cadress'];
                          cbusinessController.text = developer['cbusiness'];
                        }),
                      },
                      title: "수정",
                    ),
                  ],
                ),
              ]
                : // 수정버튼 클릭 후
              [
                Center(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(999),
                    child: Container(
                      width: 100, height: 100,
                      child: Image.network( imgUrl, fit: BoxFit.cover, ),
                    ),
                  ),
                ),
                SizedBox( height: 20, ),

                Text("아이디"),
                SizedBox( height: 12, ),
                CustomTextField( controller: cidController, readOnly: true, ),
                SizedBox( height: 12, ),

                Text("비밀번호"),
                SizedBox( height: 12, ),
                CustomTextField( controller: cpwdController, ),
                SizedBox( height: 12, ),

                Text("휴대번호"),
                SizedBox( height: 12, ),
                CustomTextField( controller: cphoneController, ),
                SizedBox( height: 12, ),

                Text("이메일"),
                SizedBox( height: 12, ),
                CustomTextField( controller: cemailController, ),
                SizedBox( height: 12, ),

                Text("주소"),
                SizedBox( height: 12, ),
                CustomTextField( controller: cadressController, ),
                SizedBox( height: 15, ),

                Text("사업자 등록번호"),
                SizedBox( height: 12, ),
                CustomTextField( controller: cbusinessController, ),
                SizedBox( height: 15, ),

                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [

                    CustomOutlineButton(
                      onPressed: () => { setState(() => { isUpdate = false }) },
                      title: "취소",
                    ),
                    SizedBox( width: 15,),

                    CustomTextButton( onPressed: onUpdate, title: "저장" ),

                  ],
                )
              ]

          ),
        ),
        SizedBox( height: 30,),

        Text("비밀번호", style: TextStyle( fontSize: 18, fontWeight: FontWeight.bold, ), ),
        SizedBox( height: 15 ,),

        // 두번째 Card
        CustomCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("최근 업데이트 : ${developer['updateAt'].split('T')[0]}", // 스플라이스 개념 헷갈리는듯 다시하기
                style: TextStyle( fontSize: 15, ),
              ),
              SizedBox( height: 5 ,),

              Text("비밀번호", style: TextStyle( fontSize: 18, ), ),
              SizedBox( height: 10 ,),

              // 버튼
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  CustomOutlineButton(
                    onPressed: () => { setState(() => { isUpdate = false }) },
                    title: "비밀번호 변경",
                    width: 140,
                  ),
                ]
              ),

            ],
          ),
        ),
        SizedBox( height: 30,),

        // 세번째 Card
        CustomCard(
          child : Text(""),
        ),

        SizedBox(height: 50 + MediaQuery.of(context).padding.bottom),

      ],
    );
  }
}