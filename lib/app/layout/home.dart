// home.dart : 메인 페이지

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
      body: Column(
        children : [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              itemCount : list.length + (isLoading ? 1 : 0),
              itemBuilder : (BuildContext context, int index) {
                if(index < list.length) {
                  return ListTile(
                    title : Text("${list[index]}"),
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