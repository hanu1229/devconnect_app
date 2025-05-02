
import 'package:devconnect_app/app/component/custom_card.dart';
import 'package:devconnect_app/app/component/custom_imgpicker.dart';
import 'package:devconnect_app/app/component/custom_menutabs.dart';
import 'package:devconnect_app/app/component/custom_outlinebutton.dart';
import 'package:devconnect_app/app/component/custom_scrollview.dart';
import 'package:devconnect_app/app/component/custom_textbutton.dart';
import 'package:devconnect_app/app/component/custom_textfield.dart';
import 'package:devconnect_app/style/app_colors.dart';
import 'package:devconnect_app/style/server_path.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Profile_Rating extends StatefulWidget{
  final Function(int) changePage;

  const Profile_Rating({
    required this.changePage,
  });

  @override
  _Profile_Rating createState() {
    return _Profile_Rating();
  }
}

class _Profile_Rating extends State< Profile_Rating >{
  Dio dio = Dio();

  // 상태변수
  int mno = 0;
  XFile? profileImage;
  String? profileImageUrl;
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
          profileImageUrl = data['dprofile'];
        });
      }
    }catch( e ){ print( e ); }
  } // f end

  @override
  Widget build(BuildContext context) {

    if( developer.isEmpty ){ return Center( child: CircularProgressIndicator(), ); }

    return CustomSingleChildScrollview(
      children: [
        CustomMenuTabs(
          changePage: widget.changePage,
          selectedIndex: 10,
        ),

        SizedBox( height: 15 ,),
        Text("평가 관리", style: TextStyle( fontSize: 18, fontWeight: FontWeight.bold, ), ),
        SizedBox( height: 10 ,),

        // 첫번째 Card
        CustomCard(
          child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: !isUpdate ? CrossAxisAlignment.center : CrossAxisAlignment.start,
              children: [

              ]

          ),
        ),
        SizedBox( height: 30,),



        SizedBox(height: 50 + MediaQuery.of(context).padding.bottom),

      ],
    );
  }
}