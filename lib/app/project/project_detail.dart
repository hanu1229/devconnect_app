// project_detail.dart : 프로젝트 상세보기 페이지

import "package:devconnect_app/app/component/custom_card.dart";
import "package:devconnect_app/app/developer/developer_login.dart";
import "package:devconnect_app/style/app_colors.dart";
import "package:devconnect_app/style/server_path.dart";
import "package:dio/dio.dart";
import "package:flutter/material.dart";
import "package:shared_preferences/shared_preferences.dart";

class DetailProject extends StatefulWidget {
  int pno = 0;

  DetailProject({required int pno, bool company = false}) { this.pno = pno; }

  @override
  State<DetailProject> createState() => _DetailProjectState();

}

class _DetailProjectState extends State<DetailProject> {

  Dio dio = Dio();

  Map<String, dynamic> project = {};
  Map<String, dynamic> company = {};

  String pstart = "";
  String pend = "";
  String rpstart = "";
  String rpend = "";

  final PageController _imagePageController = PageController(initialPage : 0);

  /// 서버에서 프로젝트 정보 가져오기 (토큰 필요)
  Future<void> findProject() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("token");
      final response = await dio.get("$serverPath/api/project/detail?pno=${widget.pno}", options : Options(headers : {"Authorization" : token}));
      final data = response.data;
      if(response.statusCode == 200 && data != null) {
        setState(() {
          project = data;
          print(">> project : $project");
          pstart = project["pstart"] == null ? "" : project["pstart"].split("T")[0];
          pend = project["pend"] == null ? "" : project["pend"].split("T")[0];
          rpstart = project["recruit_pstart"] == null ? "" : project["recruit_pstart"].split("T")[0];
          rpend = project["recruit_pend"] == null ? "" : project["recruit_pend"].split("T")[0];
        });
      }
    } catch(e) {
      print(e);
    }
  }

  /// 서버에서 프로젝트의 회사 정보 가져오기 (토큰 필요)
  Future<void> findCompany() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("token");
      final response = await dio.get("$serverPath/api/company/info", options : Options(headers : {"Authorization" : token}));
      final data = response.data;
      if(response.statusCode == 200 && data != null) {
        setState(() {
          company = data;
          print(">> company : $company");
        });
      }
    } catch(e) {
      print(e);
    }
  }

  /// 프로젝트에 개발자 지원서류를 등록
  Future<void> writeProjectJoin(BuildContext context) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("token");
      if(token == null) { return; }
      final response = await dio.post("$serverPath/api/project-join?pno=${project["pno"]}", options : Options(headers : {"Authorization" : token}));
      final data = response.data;
      final statusCode = response.statusCode;
      if(statusCode == 201 && data == true) {
        showModalBottomSheet(
          context: context,
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
                              // 모달창 삭제
                              Navigator.pop(context);
                              // 현재 페이지 삭제
                              Navigator.pop(context, true);
                              return;
                            },
                            style : ElevatedButton.styleFrom(
                              backgroundColor : AppColors.buttonColor,
                              shape : RoundedRectangleBorder(
                                borderRadius : BorderRadius.circular(12),
                              ),
                            ),
                            child : Text("지원완료", style : TextStyle(color : AppColors.buttonTextColor)),
                          ),
                        ),
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

  /// 토큰에 따른 지원하기 버튼의 행동
  Future<bool> isLogin() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token");
    if(token == null) { return false; }
    else { return true; }
  }

  /// 직무 number --> String
  String? ptypeToString(int? ptype) {
    switch(ptype) {
      case 0:
        return "전체";
      case 1:
        return "백엔드";
      case 2:
        return "프론트엔드";
    }
    return null;
  }

  @override
  void initState() {
    super.initState();
    findProject();
    findCompany();
  }

  int _currentPage = 0;

  @override
  Widget build(BuildContext context) {

    String pay = project["ppay"].toString().replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},');
    final List<dynamic> images = project["images"] ?? [];
    Widget imageWidget;
    if(images.isNotEmpty) {
      imageWidget = Container(
        height : 300,
        child : Stack(
          children : [
            PageView.builder(
                controller : _imagePageController,
                onPageChanged : (index) { setState(() { _currentPage = index; }); },
                scrollDirection : Axis.horizontal,
                itemCount : images.length,
                itemBuilder : (context, index) {
                  String imageUrl = "$serverPath/upload/project_image/${images[index]}";
                  return Padding(
                    padding : EdgeInsets.all(5),
                    child : Container(
                      width : MediaQuery.of(context).size.width * 0.8,
                      height : 300,
                      child: Row(
                        mainAxisAlignment : MainAxisAlignment.spaceBetween,
                        children: [
                          SizedBox(width : 20),
                          Image.network(imageUrl),
                          SizedBox(width : 20),
                        ],
                      ),
                    ),
                  );
                }
            ),
            Positioned(
              left : 0, top : 0, bottom : 0,
              child: Center(
                child: IconButton(
                  onPressed : () {
                    // 이전 페이지로 넘어가기
                    if(_currentPage > 0) {
                      _imagePageController.previousPage(duration: Duration(milliseconds : 300), curve: Curves.easeInOut);
                    }
                  },
                  style : IconButton.styleFrom(
                    shape : RoundedRectangleBorder(
                      borderRadius : BorderRadius.circular(6),
                      side : BorderSide(color : Color(0xFFD9D9D9), width : 2),
                    ),
                  ),
                  icon : Icon(Icons.arrow_left, size : 35),
                ),
              ),
            ),
            Positioned(
              right : 0, top : 0, bottom : 0,
              child: Center(
                child: IconButton(
                  onPressed : () {
                    // 다음 페이지로 넘어가기
                    if(_currentPage < images.length - 1) {
                      _imagePageController.nextPage(duration: Duration(milliseconds : 300), curve: Curves.easeInOut);
                    }
                  },
                  style : IconButton.styleFrom(
                    shape : RoundedRectangleBorder(
                      borderRadius : BorderRadius.circular(6),
                      side : BorderSide(color : Color(0xFFD9D9D9), width : 2),
                    ),
                  ),
                  icon : Icon(Icons.arrow_right, size : 35),
                ),
              ),
            ),
          ],
        ),
      );
    } else {
      imageWidget = SizedBox.shrink();
    }

    return Scaffold(
      appBar : AppBar(title : Text("프로젝트 상세보기"),),
      body : SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(16, 16, 16, 0),
          child : SingleChildScrollView(
            child : Container(
              width : MediaQuery.of(context).size.width,
              child : Column(
                crossAxisAlignment : CrossAxisAlignment.start,
                children : [
                  // 제목 | 회사명
                  CustomCard(
                    elevation : 0,
                    child : Row(
                      children: [
                        SizedBox(
                          width : 100,
                          height : 100,
                          child: Image.network("$imageUrl/${project["cprofile"]}"),
                        ),
                        SizedBox(width : 20),
                        Expanded(
                          child: Column(
                            crossAxisAlignment : CrossAxisAlignment.start,
                            children : [
                              Text("${project["pname"]}", maxLines : 2, style : TextStyle(fontSize : 20, fontWeight : FontWeight.bold, overflow : TextOverflow.visible), softWrap : true,),
                              SizedBox(height : 10),
                              Text("${project["cname"]}", style : TextStyle(fontSize : 16, fontWeight : FontWeight.bold),),
                              SizedBox(height : 10),
                              Text("급여 : $pay 만원", style : TextStyle(fontSize : 16),),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height : 20),
                  // 이미지
                  CustomCard(
                    elevation : 0,
                    child : imageWidget,
                  ),
                  SizedBox(height : 20),
                  // 직무 | 프로젝트 기간 | 모집 기간
                  CustomCard(
                    elevation : 0,
                    child : Column(
                      crossAxisAlignment : CrossAxisAlignment.start,
                      children : [
                        Text("직무", style : TextStyle(fontSize : 20, fontWeight : FontWeight.bold,),),
                        SizedBox(height : 5),
                        Text("${ptypeToString(project["ptype"])}", style : TextStyle(fontSize : 18),),
                        SizedBox(height : 5),
                        Text("프로젝트 기간", style : TextStyle(fontSize : 20, fontWeight : FontWeight.bold,),),
                        SizedBox(height : 5),
                        Text("$pstart ~ $pend", style : TextStyle(fontSize : 18),),
                        SizedBox(height : 5),
                        Text("모집 기간", style : TextStyle(fontSize : 20, fontWeight : FontWeight.bold,),),
                        SizedBox(height : 5),
                        Text("$rpstart ~ $rpend", style : TextStyle(fontSize : 18),),
                      ],
                    ),
                  ),
                  SizedBox(height : 20),
                  // 업무 소개
                  CustomCard(
                    elevation : 0,
                    child : Column(
                      crossAxisAlignment : CrossAxisAlignment.start,
                      children : [
                        Text("업무 소개", style : TextStyle(fontSize : 20, fontWeight : FontWeight.bold),),
                        SizedBox(height : 10),
                        Text("${project["pcomment"]}", style : TextStyle(fontSize : 16,),),
                      ],
                    ),
                  ),
                  SizedBox(height : 20),
                  // 지원 버튼
                  SizedBox(
                    width : MediaQuery.of(context).size.width,
                    child : ElevatedButton(
                      onPressed: () async {
                        bool result = await isLogin();
                        if(result == true) {
                          writeProjectJoin(context);
                        } else {
                          Navigator.pushReplacement(context, MaterialPageRoute(builder : (context) => DeveloperLogIn()));
                        }
                      },
                      style : ElevatedButton.styleFrom(
                        backgroundColor : AppColors.buttonColor,
                        shape : RoundedRectangleBorder(borderRadius : BorderRadius.circular(5),),
                      ),
                      child: Text("지원하기", style : TextStyle(color : AppColors.buttonTextColor, fontSize : 20),),
                    ),
                  ),
                  SizedBox(height : 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

}
