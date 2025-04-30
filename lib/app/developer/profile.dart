
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
      final response = await dio.get("${serverPath}/api/developer/info");
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
  TextEditingController dphoneController = TextEditingController();
  TextEditingController demailController = TextEditingController();
  TextEditingController daddressController = TextEditingController();

  // 상세정보 수정
  void onUpdate( ) async {
    final sendData = {
      "dno" : developer['dno'],
      "dpwd" : dpwdController.text,
      "dname" : dnameController.text,
      "dphone" : dphoneController.text,
      "demail" : demailController.text,
      "daddress" : daddressController.text,
    };

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    try{
      dio.options.headers['Authorization'] = token;
      final response = await dio.put("${serverPath}/api/developer/update", data: sendData);
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

    final image = developer['dprofile'];
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

                Text( developer['dname'],
                    style: TextStyle( fontSize: 20, fontWeight: FontWeight.bold, ) ),
                SizedBox( height: 12, ),

                Text( developer['demail'],
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
                          didController.text = developer['did'];
                          dnameController.text = developer['dname'];
                          dphoneController.text = developer['dphone'];
                          demailController.text = developer['demail'];
                          daddressController.text = developer['daddress'];
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
                CustomTextField( controller: didController, readOnly: true, ),
                SizedBox( height: 12, ),

                Text("비밀번호"),
                SizedBox( height: 12, ),
                CustomTextField( controller: dpwdController, ),
                SizedBox( height: 12, ),

                Text("휴대번호"),
                SizedBox( height: 12, ),
                CustomTextField( controller: dphoneController, ),
                SizedBox( height: 12, ),

                Text("이메일"),
                SizedBox( height: 12, ),
                CustomTextField( controller: demailController, ),
                SizedBox( height: 12, ),

                Text("주소"),
                SizedBox( height: 12, ),
                CustomTextField( controller: daddressController, ),
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
              Text("최근 업데이트 : ${developer['updateAt'].split('T')[0]}",
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