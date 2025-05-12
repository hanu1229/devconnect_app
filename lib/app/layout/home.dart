// home.dart : 메인 페이지

import "package:devconnect_app/app/company/company_login.dart";
import "package:devconnect_app/app/component/custom_alert.dart";
import "package:devconnect_app/app/project/project_detail.dart";
import "package:devconnect_app/style/app_colors.dart";
import "package:devconnect_app/style/server_path.dart";
import "package:dio/dio.dart";
import "package:flutter/material.dart";
import "package:shared_preferences/shared_preferences.dart";

class Home extends StatefulWidget {

  final changePage;

  Home({super.key, required this.changePage});

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
  // 회사 로고 이미지 경로
  // String logoUrl = "$serverPath/upload/company_logo";
  // ptype 확인 변수
  int? checkPtype = 0;
  // 직무 필터 선택값
  int? ptypeValue = 0;
  // rstatus 확인 변수
  int? checkRstatus = 0;
  // 모집 상태 필터 선택값
  int? rstatusValue = 0;
  // 스크롤 애니메이션
  bool scrollUp = false;
  // 검색 버튼 클릭 했는지 확인
  bool searchClick = false;

  final ScrollController _scrollController = ScrollController();

  List<dynamic> list = [];

  Future<void> findData() async {
    print(">> before : ptypeValue : $ptypeValue , checkPtype : $checkPtype");
    print(">> before : rstatusValue : $rstatusValue , checkRstatus : $checkRstatus");

    if(ptypeValue != checkPtype || rstatusValue != checkRstatus) {

      hasNext = true;
      if(searchClick) {
        page = 0;
        checkPtype = ptypeValue;
        checkRstatus = rstatusValue;
        scrollUp = true;
      }
    }
    print(">> page : $page , size : $size");
    print(">> after : ptypeValue : $ptypeValue , checkPtype : $checkPtype");
    print(">> after : rstatusValue : $rstatusValue , checkRstatus : $checkRstatus");
    // 중복 호출 방지
    if(isLoading || !hasNext) { return; }
    setState(() { isLoading = true; });
    try {
      // 테스트를 위한 딜레이
      await Future.delayed(Duration(seconds: 1));
      // 필요한 정보만 가져오기
      String path = "$serverPath/api/project/paging?ptype=$checkPtype&rstatus=$checkRstatus&page=$page&size=$size";
      print(path);
      final response = await dio.get("$serverPath/api/project/paging?ptype=$checkPtype&rstatus=$checkRstatus&page=$page&size=$size");
      final data = response.data;
      print(data);
      if(data.length < size) { hasNext = false; }
      setState(() {
        if(scrollUp) {
          list = data;
          // checkPtype의 값이 변경될 시 스크롤을 맨 위로 올리는 함수(애니메이션)
          _scrollController.animateTo(0.0, duration : Duration(milliseconds : 300), curve : Curves.easeInOut,);
        } else {
          list.addAll(data);
        }
        // 페이지 증가
        page += 1;
      });
    } catch(e) {
      print(e);
      if(page == 0) {
        _scrollController.animateTo(0.0, duration : Duration(milliseconds : 300), curve : Curves.easeInOut,);
        list.clear();
      }
    } finally {
      setState(() { isLoading = false; scrollUp = false; searchClick = false; });
    }
  }

 @override
  void initState() {
    super.initState();
    ptypeValue = 0;
    rstatusValue = 0;
    scrollUp = false;
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
          Container(
            padding : EdgeInsets.only(left : 18, top : 8, right : 18, bottom : 0),
            width : MediaQuery.of(context).size.width,
            height : 50,
            child : Row(
              mainAxisSize : MainAxisSize.max,
              mainAxisAlignment : MainAxisAlignment.spaceBetween,
              crossAxisAlignment : CrossAxisAlignment.center,
              children : [
                // 모집 여부 필터
                Container(
                  width : MediaQuery.of(context).size.width * 0.35,
                  decoration : BoxDecoration(
                    borderRadius : BorderRadius.circular(6),
                    border : Border.all(color : Colors.black, width : 1),
                  ),
                  child: DropdownButton(
                    padding : EdgeInsets.symmetric(horizontal : 8),
                    isExpanded : true,
                    // 테두리가 없어서 대체로 사용
                    elevation : 9,
                    dropdownColor : Colors.white,
                    value : rstatusValue,
                    onChanged: (value) { setState(() { rstatusValue = value; }); },
                    underline : SizedBox.shrink(),
                    items: [
                      DropdownMenuItem(value : 0, child : Text("전체", overflow : TextOverflow.ellipsis,),),
                      DropdownMenuItem(value : 1, child : Text("모집 전", overflow : TextOverflow.ellipsis,),),
                      DropdownMenuItem(value : 2, child : Text("모집 중", overflow : TextOverflow.ellipsis,),),
                      DropdownMenuItem(value : 3, child : Text("모집 완료", overflow : TextOverflow.ellipsis,),),
                    ],
                  ),
                ),
                // 직무 필터
                Container(
                  width : MediaQuery.of(context).size.width * 0.35,
                  decoration : BoxDecoration(
                    borderRadius : BorderRadius.circular(6),
                    border : Border.all(color : Colors.black, width : 1),
                  ),
                  child: DropdownButton(
                    padding : EdgeInsets.symmetric(horizontal : 8),
                    isExpanded : true,
                    // 테두리가 없어서 대체로 사용
                    elevation : 9,
                    dropdownColor : Colors.white,
                    value : ptypeValue,
                    onChanged: (value) { setState(() { ptypeValue = value; }); },
                    underline : SizedBox.shrink(),
                    items: [
                      DropdownMenuItem(value : 0, child : Text("전체", overflow : TextOverflow.ellipsis,),),
                      DropdownMenuItem(value : 1, child : Text("백엔드", overflow : TextOverflow.ellipsis,),),
                      DropdownMenuItem(value : 2, child : Text("프론트엔드", overflow : TextOverflow.ellipsis,),),
                    ],
                  ),
                ),
                // 검색 버튼
                Container(
                  decoration : BoxDecoration(
                    borderRadius : BorderRadius.circular(6),
                    border : Border.all(color : Colors.black, width : 1,),
                  ),
                  child: IconButton(
                    onPressed : () {
                      print(">> rstatusValue : $rstatusValue");
                      print(">> ptypeValue : $ptypeValue");
                      page = 0;
                      scrollUp = true;
                      searchClick = true;
                      findData();
                    },
                    icon : Icon(Icons.search_rounded),
                  ),
                ),
              ],
            ),
          ),
          Divider(),
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
                  // 모집 상태
                  int rstatus = data["recruitment_status"];
                  return GestureDetector(
                    onTap : () async {
                      final prefs = await SharedPreferences.getInstance();
                      final token = prefs.getString("token");
                      if(token == null) {
                        showDialog(
                          context: context,
                          builder: (context) {
                            return CustomAlertDialog(
                              title : "비로그인 중",
                              onCancleBtn : false,
                              content : SizedBox(
                                height : 120,
                                child: Column(
                                  children : [
                                    SizedBox(
                                      width : double.infinity,
                                      child: ElevatedButton(
                                        onPressed : () {
                                          Navigator.pop(context);
                                          widget.changePage(7);
                                        },
                                        style : ElevatedButton.styleFrom(
                                          backgroundColor : AppColors.buttonColor,
                                          shape : RoundedRectangleBorder(
                                            borderRadius : BorderRadius.circular(6),
                                          ),
                                        ),
                                        child : Text("기업 로그인", style : TextStyle(fontSize : 20, color : Colors.white,),),
                                      ),
                                    ),
                                    SizedBox(height : 10),
                                    SizedBox(
                                      width : double.infinity,
                                      child: ElevatedButton(
                                        onPressed : () {
                                          Navigator.pop(context);
                                          widget.changePage(6);
                                          },
                                        style : ElevatedButton.styleFrom(
                                          backgroundColor : AppColors.buttonColor,
                                          shape : RoundedRectangleBorder(
                                            borderRadius : BorderRadius.circular(6),
                                          ),
                                        ),
                                        child : Text("개발자 로그인", style : TextStyle(fontSize : 20, color : Colors.white,),),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              onPressed : () {},
                            );
                          },
                        );
                      } else {
                        // 프로젝트 상세보기 페이지로 넘어감
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder : (context) => DetailProject(pno : data["pno"])),
                        );
                      }
                    },
                    child : Padding(
                      padding : EdgeInsets.only(left : 16, top : 8, right : 16, bottom : 8),
                      child : Card(
                        color : AppColors.bgColor,
                        // elevation : 5,
                        shape : RoundedRectangleBorder(
                          borderRadius : BorderRadius.circular(10),
                          side : BorderSide(color : AppColors.cardBorderColor, width : 1,),
                        ),
                        child : Padding(
                          padding : EdgeInsets.symmetric(vertical : 10),
                          child : ListTile(
                            title : Row(
                              crossAxisAlignment : CrossAxisAlignment.start,
                              children: [
                                SizedBox(
                                  width : 50,
                                  height : 50,
                                  // child: Image.network("$logoUrl/${data["cprofile"]}"),
                                  // child: Image.network("${data["cprofile"]}"),
                                  child: Image.network("${data["cprofile"]}"),
                                ),
                                SizedBox(width : 15),
                                Expanded(
                                  child: Text(
                                    "${data["pname"]}",
                                    maxLines : 3,
                                    style : TextStyle(
                                      fontFamily : "NanumGothic",
                                      fontSize : 20,
                                      fontWeight : FontWeight.bold,
                                      overflow : TextOverflow.visible
                                    ),
                                    softWrap : true,
                                  ),
                                ),
                              ],
                            ),
                            subtitle: Row(
                              children: [
                                SizedBox(width : 65),
                                Column(
                                  mainAxisAlignment : MainAxisAlignment.start,
                                  crossAxisAlignment : CrossAxisAlignment.start,
                                  children : [
                                    SizedBox(height : 10),
                                    // Text("소개 : ${data["pintro"]}", style : TextStyle(overflow : TextOverflow.ellipsis)),
                                    // SizedBox(height : 5),
                                    // Text("모집 인원 : ${data["pcount"]}", style : TextStyle(overflow : TextOverflow.ellipsis)),
                                    // SizedBox(height : 5),
                                    Text("프로젝트 기간\n$pstart ~ $pend", style : TextStyle(overflow : TextOverflow.ellipsis)),
                                    SizedBox(height : 5),
                                    Text("모집 기간\n$rpstart ~ $rpend", style : TextStyle(overflow : TextOverflow.ellipsis))
                                  ],
                                ),
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
          // SizedBox(height : MediaQuery.of(context).size.height * 0.03),
        ],
      ),
    );
  }
}