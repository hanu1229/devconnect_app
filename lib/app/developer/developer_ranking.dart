import "package:devconnect_app/style/app_colors.dart";
import "package:devconnect_app/style/server_path.dart";
import "package:dio/dio.dart";
import "package:flutter/material.dart";
import "package:flutter_svg/flutter_svg.dart";

class DeveloperRanking extends StatefulWidget {

  @override
  _DeveloperRanking createState(){
    return _DeveloperRanking();
  }

}

class _DeveloperRanking extends State<DeveloperRanking> {

  Dio dio = Dio();
  int page = 1;
  int size = 5;
  // 빈 데이터가 오는지 확인하는 변수
  bool hasNext = true;
  // 로딩 확인 변수
  bool isLoading = false;
  // 회사 로고 이미지 경로
  String logoUrl = "$imageUrl/company_logo";
  // ptype 확인 변수
  int? checkPtype = 0;
  //
  int? ptypeValue = 0;

  final ScrollController _scrollController = ScrollController();

  List<dynamic> list = [];
  /// 내 프로젝트 목록 전체 가져오기
  Future<void> onRanking() async {
    if (ptypeValue != checkPtype) { page = 0; hasNext = true; }
    print(">> before : ptypeValue : $ptypeValue , checkPtype : $checkPtype");
    // 중복 호출 방지
    if (isLoading || !hasNext) { return; }
    setState(() { isLoading = true; });
    try {
      await Future.delayed(Duration(seconds: 1));

      final response = await dio.get(
          "$serverPath/api/developer/ranking?page=${page}&size=${size}");
      final data = response.data['content'];
      print(data);
      if (data.length < size) { hasNext = false; }
      setState(() {
        if (ptypeValue != checkPtype) {
          checkPtype = ptypeValue;
          list = data;
          // checkPtype의 값이 변경될 시 스크롤을 맨 위로 올리는 함수(애니메이션)
          _scrollController.animateTo(
            0.0, duration: Duration(milliseconds: 300),
            curve: Curves.easeInOut,);
        } else {
          list.addAll(data);
        }
        print(">> after : ptypeValue : $ptypeValue , checkPtype : $checkPtype");
        // 페이지 증가
        page += 1;
      });
    } catch (e) {
      print(e);
    } finally {
      setState(() { isLoading = false; });
    }
  }

  @override
  void initState() {
    super.initState();
    onRanking();
    // 스크롤 이벤트 등록
    _scrollController.addListener(() {
      if(_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 30) {
        // 스크롤 끝에 도달하면 추가 데이터 불러오기
        if(hasNext && !isLoading) { onRanking(); }
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
            child : Row(
              mainAxisSize : MainAxisSize.max,
              mainAxisAlignment : MainAxisAlignment.end,
              crossAxisAlignment : CrossAxisAlignment.center,
              children : [
                Container(
                  // padding : EdgeInsets.symmetric(horizontal : 8),
                  width : MediaQuery.of(context).size.width * 0.3,
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
                    onChanged: (value) { setState(() { ptypeValue = value; print(ptypeValue); onRanking(); }); },
                    underline : SizedBox.shrink(),
                    items: [
                      DropdownMenuItem(value : 0, child : Text("전체"),),
                      DropdownMenuItem(value : 1, child : Text("백엔드"),),
                      DropdownMenuItem(value : 2, child : Text("프론트엔드"),),
                    ],
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
                  return GestureDetector(
                    onTap : () {
                      // 프로젝트 상세보기 페이지로 넘어감
                      // Navigator.push(
                      //   context,
                      //   MaterialPageRoute(builder : (context) => DetailProject(pno : data["pno"])),
                      // );
                    },
                    child : Padding(
                      padding : EdgeInsets.only(left : 16, top : 16, right : 16),
                      child : Card(
                        color : AppColors.bgColor,
                        elevation : 0,
                        shape : RoundedRectangleBorder(
                          borderRadius : BorderRadius.circular(10),
                          side : BorderSide(color : AppColors.cardBorderColor, width : 3,),
                        ),
                        child : Padding(
                          padding : EdgeInsets.symmetric(vertical : 10),
                          child : ListTile(
                            title : Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                SizedBox(
                                  width : 80,
                                  height : 80,
                                  child: index > -1 && index < 3
                                      ? Image.asset("assets/images/no${index + 1}_icon.png",)
                                      : Center(
                                          // padding: EdgeInsets.fromLTRB( 20, 0, 20, 0),
                                          child: Text( "${index + 1}", style: TextStyle( fontSize: 50, fontWeight: FontWeight.bold ),),
                                        ),
                                ),
                                Row(
                                  children: [
                                    Text( data["did"],
                                      style : TextStyle(
                                          fontSize : 20,
                                          fontWeight : FontWeight.bold,
                                          overflow : TextOverflow.visible
                                      ),
                                    )
                                  ]
                                ),
                                SizedBox(
                                  child: Text( "LV. ${data['dlevel']}",
                                    style: TextStyle(
                                      fontSize: 20, fontWeight: FontWeight.bold
                                    ),
                                  ),
                                )
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
          SizedBox(height : MediaQuery.of(context).size.height * 0.03),
        ],
      ),
    );
  }

}
