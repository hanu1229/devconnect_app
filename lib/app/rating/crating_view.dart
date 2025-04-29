

import 'package:devconnect_app/style/server_path.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Crating_view extends StatefulWidget{

  // 평가리스트에서 클릭한 Card의 crno , pno , cno 가져오기
  int? crno;
  int? pno;
  int? cno;
  Crating_view( { this.crno , this.pno , this.cno } );

  @override
  State<StatefulWidget> createState() {
    print( crno );
    print( pno );
    print( cno );
    return _Crating_viewState();
  } // createState end
} // c end

class _Crating_viewState extends State<Crating_view>{

  // 요청 값을 저장하는 상태 변수
  Map< String , dynamic > crating = {};

  final dio = Dio();
  bool real = false;

  // 요청
  void onView() async{
    try{
      // 토큰 확인
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      if( token == null ) { setState(() { real = false; }); return; }
      dio.options.headers['Authorization'] = token;
      // 평가 조회
      final response1 = await dio.get("${serverPath}/api/crating/view?crno=${ widget.crno }");
      // 프로젝트 조회
      final response2 = await dio.get("${serverPath}/api/project/detail?pno=${ widget.pno }");
      // 기업 조회
      final response3 = await dio.get("${serverPath}/api/company/info?cno=${ widget.cno }");
      if( response1.data != null && response2.data != null && response3.data != null ){
        setState(() { crating = response1.data; });
        // 로그인 검증
      }
    }catch(e){print(e);}
  } // onView end

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("평가 상세보기"),
      ),
    );
  } // build end
} // c end