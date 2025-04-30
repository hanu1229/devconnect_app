

import 'package:devconnect_app/style/server_path.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Crating_view extends StatefulWidget{

  // 평가리스트에서 클릭한 Card의 crno , pno , cno 가져오기
  int? crno;
  int? pno;
  List<dynamic>? cprofile;
  String? cname;
  Crating_view( { this.crno , this.pno , this.cprofile , this.cname } );

  @override
  State<StatefulWidget> createState() {
    print( crno );
    print( pno );
    print( cprofile );
    print(cname);
    return _Crating_viewState();
  } // createState end
} // c end

class _Crating_viewState extends State<Crating_view>{

  // 요청 값을 저장하는 상태 변수
  Map< String , dynamic > crating = {};
  Map< String , dynamic > project = {};

  final dio = Dio();
  bool real = false;

  @override
  void initState() {
    super.initState();
    // print( widget.cprofile );
    // print( widget.cname);
    onView();
  } // iniState end

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
      print( response1.data );
      print( response2.data );
      // print( response3.data );
      if( response1.data != null && response2.data != null ){
        setState(() { crating = response1.data; project = response2.data; });
        // 로그인 검증
      }
    }catch(e){print(e);}
  } // onView end

  void onUpdate() async{
    try{
      final response = await dio.put("${serverPath}/api/crating?");
    }catch(e) { print( e ); }
  } // onUpdate end

  // 요청 ==========================================================================================================================
  @override
  Widget build(BuildContext context) {
    // 공고 정보가 없으면 로딩
    if (crating.isEmpty || project.isEmpty) {
      return Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      appBar: AppBar(
        title: Text("평가 상세보기"),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.cname ?? "기업명 없음"),
            Text("${crating['crscore']}"),
            Text("${crating['ccontent']}"),
            Text("${project['pname']}"),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      barrierDismissible: false, // 바깥 클릭 막기
                      builder: (context) {
                        TextEditingController titleController = TextEditingController();
                        TextEditingController contentController = TextEditingController();
                        return Dialog(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Container(
                            width: MediaQuery.of(context).size.width * 0.5, // 가로폭 제한
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "평가 수정",
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 20),
                                TextField(
                                  controller: titleController,
                                  decoration: InputDecoration(
                                    labelText: "제목",
                                    border: OutlineInputBorder(),
                                  ),
                                ),
                                SizedBox(height: 15),
                                TextField(
                                  controller: contentController,
                                  maxLines: 4,
                                  decoration: InputDecoration(
                                    labelText: "내용",
                                    border: OutlineInputBorder(),
                                  ),
                                ),
                                SizedBox(height: 20),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context),
                                      child: Text("취소"),
                                    ),
                                    SizedBox(width: 10),
                                    ElevatedButton(
                                      onPressed: () {
                                        print("제목: ${titleController.text}");
                                        print("내용: ${contentController.text}");
                                        Navigator.pop(context); // 닫기
                                      },
                                      child: Text("수정 완료"),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                  child: Text("수정"),
                ),
                ElevatedButton(
                  onPressed: () => {},
                  child: Text("삭제"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
} // c end