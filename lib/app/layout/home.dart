// home.dart : 메인 페이지

import "package:devconnect_app/app/project/project_detail.dart";
import "package:devconnect_app/style/app_colors.dart";
import "package:devconnect_app/style/server_path.dart";
import "package:dio/dio.dart";
import "package:flutter/material.dart";

class Home extends StatefulWidget {

  @override
  State<Home> createState() => _HomeState();

}

class _HomeState extends State<Home> {

  Dio dio = Dio();
  int page = 0;
  int size = 5;
  // 빈 데이터가 오는지 확인하는 변수
  bool hasNext = true;
  // 로딩 확인 변수
  bool isLoading = false;

  final ScrollController _scrollController = ScrollController();

  List<dynamic> list = [];

  Future<void> findData() async {
    // 중복 호출 방지
    if(isLoading || !hasNext) { return; }
    setState(() { isLoading = true; });
    try {
      // 테스트를 위한 딜레이
      await Future.delayed(Duration(seconds: 2));
      // 필요한 정보만 가져오기
      final response = await dio.get("$serverPath/api/project/paging?page=$page&size=$size");
      final data = response.data;
      print(data);
      if(data.length < size) { hasNext = false; }
      setState(() {
        list.addAll(data);
        // 페이지 증가
        page += 1;
      });
    } catch(e) {
      print(e);
    } finally {
      setState(() { isLoading = false; });
    }
  }

 @override
  void initState() {
    super.initState();
    findData();
   // 스크롤 이벤트 등록
   _scrollController.addListener(() {
     if(_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 30) {
       // 스크롤 끝에 도달하면 추가 데이터 불러오기
       if(hasNext && !isLoading) { findData(); }
     }
   });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 가상 키보드가 열릴 픽셀이 오버되는 현상 없앰 | false
      resizeToAvoidBottomInset : false,
      body: Column(
        children : [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              itemCount : list.length + (isLoading ? 1 : 0),
              itemBuilder : (BuildContext context, int index) {
                if(index < list.length) {
                  final data = list[index];
                  String pstart = data["pstart"].split("T")[0];
                  String pend = data["pend"].split("T")[0];
                  String rpstart = data["recruit_pstart"].split("T")[0];
                  String rpend = data["recruit_pend"].split("T")[0];
                  return GestureDetector(
                    onTap : () {
                      // 프로젝트 상세보기 페이지로 넘어감
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder : (context) => DetailProject(pno : data["pno"])),
                      );
                    },
                    child : Padding(
                      padding : EdgeInsets.only(left : 16, top : 16, right : 16),
                      child : Card(
                        color : AppColors.white,
                        elevation : 5,
                        shape : RoundedRectangleBorder(
                          borderRadius : BorderRadius.circular(10),
                          side : BorderSide(color : Color(0xFFD9D9D9), width : 2,),
                        ),
                        child : Padding(
                          padding : EdgeInsets.symmetric(vertical : 10),
                          child : ListTile(
                            title : Text(
                              "${data["pname"]}",
                              style : TextStyle(
                                fontFamily : "NanumGothic",
                                fontSize : 20,
                                fontWeight : FontWeight.bold,
                              ),
                            ),
                            subtitle: Column(
                              mainAxisAlignment : MainAxisAlignment.start,
                              crossAxisAlignment : CrossAxisAlignment.start,
                              children : [
                                SizedBox(height : 10),
                                Text("소개 : ${data["pintro"]}"),
                                SizedBox(height : 5),
                                Text("모집 인원 : ${data["pcount"]}"),
                                SizedBox(height : 5),
                                Text("프로젝트 기간 : $pstart ~ $pend"),
                                SizedBox(height : 5),
                                Text("모집 기간 : $rpstart ~ $rpend")
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                } else {
                  return Padding(
                    padding : EdgeInsets.all(16),
                    child : Center(
                      child : CircularProgressIndicator(),
                    ),
                  );
                }
              },
            ),
          ),
          SizedBox(height : MediaQuery.of(context).size.height * 0.13),
        ],
      ),
    );
  }
}