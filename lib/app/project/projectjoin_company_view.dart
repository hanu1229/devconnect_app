// projectjoin_company_view.dart : 기업이 본인 프로젝트에 따른 신청 현황을 보는 페이지

import "package:devconnect_app/app/component/custom_card.dart";
import "package:devconnect_app/style/server_path.dart";
import "package:dio/dio.dart";
import "package:flutter/material.dart";
import "package:shared_preferences/shared_preferences.dart";

class ViewProjectJoin extends StatefulWidget {

  int pno = 0;
  String pname;

  ViewProjectJoin({super.key, required this.pno, required this.pname});

  @override
  State<ViewProjectJoin> createState() => _ViewProjectJoinState();

}


class _ViewProjectJoinState extends State<ViewProjectJoin> {

  Dio dio = Dio();

  int page = 0;
  int size = 10;

  List<dynamic> joinList = [];

  // 빈 데이터가 오는지 확인하는 변수
  bool hasNext = true;
  // 로딩 확인 변수
  bool isLoading = false;
  final ScrollController _scrollController = ScrollController();

  /// 프로젝트를 신청한 신청 목록 가져오기
  Future<void> findProjectJoin() async {
    if(isLoading || !hasNext) { return; }
    setState(() { isLoading = true; });
    try {
      // 테스트를 위한 딜레이
      await Future.delayed(Duration(seconds: 1));
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("token");
      if(token == null) { return; }
      final response = await dio.get("$serverPath/api/project-join/paging?pno=${widget.pno}&page=$page&size=$size", options : Options(headers : {"Authorization" : token}));
      final data = response.data;
      print(data);
      print(data["content"]);
      if(data.length < size) { hasNext = false; }
      if(response.statusCode == 200 && data != null) {
        setState(() {
          joinList.addAll(data["content"]);
          // 페이지 증가
          page += 1;
        });
      }
    } catch(e) {
      print(e);
    } finally {
      setState(() { isLoading = false; });
    }
  }

  @override
  void initState() {
    super.initState();
    print("pno : ${widget.pno}");
    findProjectJoin();
    // 스크롤 이벤트 등록
    _scrollController.addListener(() {
      if(_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 30) {
        // 스크롤 끝에 도달하면 추가 데이터 불러오기
        if(hasNext && !isLoading) { findProjectJoin(); }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 가상 키보드가 열릴 픽셀이 오버되는 현상 없앰 | false
      resizeToAvoidBottomInset : false,
      appBar : AppBar(title : Text("${widget.pname} 신청 현황")),
      body : SafeArea(
        child: Container(
          padding : EdgeInsets.all(16),
          // width : MediaQuery.of(context).size.width,
          child : Column(
            children : [
              Expanded(
                child : ListView.builder(
                  controller : _scrollController,
                  itemCount : joinList.length + (isLoading ? 1 : 0),
                  itemBuilder : (BuildContext context, int index) {
                    if(index < joinList.length) {
                      Map<String, dynamic> developer = joinList[index];
                      String? state;
                      switch(developer["pjtype"]) {
                        case 0:
                          state = "대기";
                          break;
                        case 1:
                          state = "수락";
                          break;
                        case 2:
                          state = "거절";
                          break;
                      }
                      return GestureDetector(
                        onTap : () {
                          print("클릭 $index!");
                        },
                        child : CustomCard(
                          elevation : 0,
                          child : Row(
                            mainAxisAlignment : MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment : CrossAxisAlignment.start,
                                children : [
                                  Text("상태 : ${state ?? ""}", style : TextStyle(fontSize : 20,),),
                                  Text("이름(레벨) : ${developer["dname"]}(${developer["dlevel"]})", style : TextStyle(fontSize : 20,),),
                                ],
                              ),
                              Text("평점 : ${developer["davg"]}", style : TextStyle(fontSize : 20,),),
                            ],
                          ),
                        ),
                      );
                    } else {
                      return Padding(
                        padding : EdgeInsets.all(16),
                        child : Center(child : CircularProgressIndicator(),),
                      );
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
