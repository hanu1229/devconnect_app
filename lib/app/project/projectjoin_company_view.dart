// projectjoin_company_view.dart : 기업이 본인 프로젝트에 따른 신청 현황을 보는 페이지

import "package:devconnect_app/app/component/custom_card.dart";
import "package:devconnect_app/style/app_colors.dart";
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
      print(">> $token");
      print(">>$serverPath/api/project-join/paging?pno=${widget.pno}&page=$page&size=$size");
      if(token == null) { return; }
      dio.options.headers['Authorization'] = token;
      print( dio.options.headers );
      final response = await dio.get("$serverPath/api/project-join/paging?pno=${widget.pno}&page=$page&size=$size");
      print( response );
      final data = response.data;
      print(data);
      print(data["content"]);
      if(data.length < size) { hasNext = false; }
      if(response.statusCode == 200 && data != null) {
        setState(() {
          if(page == 0) {
            joinList = data["content"];
          } else {
            joinList.addAll(data["content"]);
          }
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

  /// 신청한 개발자 상태 변경 함수
  Future<void> updateProjectJoin({required BuildContext context, required int pjno, required int pjtype}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("token");
      final sendData = {
        "pjno" : pjno,
        "pjtype" : pjtype,
      };
      print(">> sendData = $sendData");
      final options = Options(headers : {"Authorization" : token});
      final response = await dio.put("$serverPath/api/project-join", data : sendData, options : options);
      final data = response.data;
      if(response.statusCode == 200 && data == true) {
        showModalBottomSheet(
          context: context,
          isDismissible : false,
          enableDrag : false,
          builder: (context) {
            return SafeArea(
              child: Container(
                margin : EdgeInsets.all(16),
                height : 100,
                width : MediaQuery.of(context).size.width,
                decoration : BoxDecoration(
                  color : AppColors.bgColor,
                  borderRadius : BorderRadius.all(Radius.circular(12)),
                ),
                child : Center(
                  child : Padding(
                    padding: EdgeInsets.symmetric(vertical : 16),
                    child : Column(
                      mainAxisAlignment : MainAxisAlignment.spaceAround,
                      children : [
                        Container(
                          padding : EdgeInsets.only(left : 16, top : 0, right : 16, bottom : 0),
                          width : MediaQuery.of(context).size.width,
                          child : ElevatedButton(
                            onPressed : () {
                              setState( () {
                                page = 0;
                                hasNext = true;
                                findProjectJoin();
                              });
                              // 모달창 삭제
                              Navigator.pop(context);
                              return;
                            },
                            style : ElevatedButton.styleFrom(
                              backgroundColor : AppColors.buttonColor,
                              shape : RoundedRectangleBorder(
                                borderRadius : BorderRadius.circular(12),
                              ),
                            ),
                            child : Text("확인", style : TextStyle(color : AppColors.buttonTextColor)),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
          backgroundColor : Colors.transparent,
        );
      }
    } catch(e) {
      print(e);
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
                        onLongPress : () {
                          if(developer["pjtype"] == 0) {
                            showModalBottomSheet(
                              context: context,
                              // 모달창 바깥 터치 막음
                              isDismissible: false,
                              // 드래그로 닫히지 않게 막음
                              enableDrag: false,
                              builder: (context) {
                                return SafeArea(
                                  child: Container(
                                    margin: EdgeInsets.all(16),
                                    height: 230,
                                    width: MediaQuery.of(context).size.width,
                                    decoration: BoxDecoration(
                                      color: AppColors.bgColor,
                                      borderRadius: BorderRadius.all(Radius.circular(12)),
                                    ),
                                    child: Center(
                                      child: Padding(
                                        padding: EdgeInsets.symmetric(vertical: 16),
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment
                                              .spaceAround,
                                          children: [
                                            // 수락 버튼
                                            Container(
                                              padding: EdgeInsets.only(left: 16, top: 0, right: 16, bottom: 0),
                                              width: MediaQuery.of(context).size.width,
                                              child: ElevatedButton(
                                                onPressed: () {
                                                  // 모달창 삭제
                                                  Navigator.pop(context);
                                                  setState(() { updateProjectJoin(context: context, pjno: developer["pjno"], pjtype: 1); });
                                                  return;
                                                },
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor: AppColors.buttonColor,
                                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12),),
                                                ),
                                                child: Text("수락", style: TextStyle(color: AppColors.buttonTextColor, fontSize: 20,),),
                                              ),
                                            ),
                                            // 거절 버튼
                                            Container(
                                              padding: EdgeInsets.only(left: 16, top: 0, right: 16, bottom: 0),
                                              width: MediaQuery.of(context).size.width,
                                              child: ElevatedButton(
                                                onPressed: () {
                                                  // 모달창 삭제
                                                  Navigator.pop(context);
                                                  setState(() { updateProjectJoin(context: context, pjno: developer["pjno"], pjtype: 2); });
                                                  return;
                                                },
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor: Colors.red,
                                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12),),
                                                ),
                                                child: Text("거절", style: TextStyle(color: AppColors.buttonTextColor, fontSize: 20,),),
                                              ),
                                            ),
                                            // 취소 버튼
                                            Container(
                                              padding: EdgeInsets.only(left: 16, top: 0, right: 16, bottom: 0),
                                              width: MediaQuery.of(context).size.width,
                                              child: ElevatedButton(
                                                onPressed: () {
                                                  // 모달창 삭제
                                                  Navigator.pop(context);
                                                  return;
                                                },
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor: Colors.grey,
                                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12),),
                                                ),
                                                child: Text("취소", style: TextStyle(color: AppColors.buttonTextColor, fontSize: 20,),),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                              backgroundColor: Colors.transparent,
                            );
                          } else {
                            showModalBottomSheet(
                              context: context,
                              builder: (context) {
                                return SafeArea(
                                  child: Container(
                                    margin: EdgeInsets.all(16),
                                    height: 100,
                                    width: MediaQuery.of(context).size.width,
                                    decoration: BoxDecoration(
                                      color: AppColors.bgColor,
                                      borderRadius: BorderRadius.all(Radius.circular(12)),
                                    ),
                                    child: Center(
                                      child: Padding(
                                        padding: EdgeInsets.symmetric(vertical: 16),
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                                          children: [
                                            // 확인 버튼
                                            Container(
                                              padding: EdgeInsets.only(left: 16, top: 0, right: 16, bottom: 0),
                                              width: MediaQuery.of(context).size.width,
                                              child: ElevatedButton(
                                                onPressed: () {
                                                  // 모달창 삭제
                                                  Navigator.pop(context);
                                                  return;
                                                },
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor: AppColors.buttonColor,
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius: BorderRadius
                                                        .circular(12),
                                                  ),
                                                ),
                                                child: Text("확인", style: TextStyle(color: AppColors.buttonTextColor, fontSize: 20,),),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                              backgroundColor: Colors.transparent,
                            );
                          }
                        },
                        child : CustomCard(
                          elevation : 0,
                          child : Row(
                            mainAxisAlignment : MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment : CrossAxisAlignment.start,
                                  children : [
                                    Text("상태 : ${state ?? ""}", style : TextStyle(fontSize : 16,),),
                                    Text("이름(레벨) : ${developer["dname"]}(${developer["dlevel"]})", style : TextStyle(fontSize : 16,),),
                                  ],
                                ),
                              ),
                              // Text("평점 : ${developer["davg"]}", style : TextStyle(fontSize : 16,),),
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
