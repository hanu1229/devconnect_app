// project_detail.dart : 프로젝트 상세보기 페이지

import "package:devconnect_app/app/component/custom_card.dart";
import "package:devconnect_app/style/app_colors.dart";
import "package:devconnect_app/style/server_path.dart";
import "package:dio/dio.dart";
import "package:flutter/material.dart";
import "package:shared_preferences/shared_preferences.dart";

class DetailProject extends StatefulWidget {
  int pno = 0;

  DetailProject({required int pno}) { this.pno = pno; }

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

  @override
  Widget build(BuildContext context) {
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
                    child : Column(
                      crossAxisAlignment : CrossAxisAlignment.start,
                      children : [
                        Text("${project["pname"]}", style : TextStyle(fontSize : 20, fontWeight : FontWeight.bold),),
                        SizedBox(height : 10),
                        Text("${project["cname"]}", style : TextStyle(fontSize : 16, fontWeight : FontWeight.bold),),
                      ],
                    ),
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
                        Text("${project["pcomment"]}"),
                      ],
                    ),
                  ),
                  SizedBox(height : 20),
                  // 지원 버튼
                  SizedBox(
                    width : MediaQuery.of(context).size.width,
                    child : ElevatedButton(
                      onPressed: () {},
                      style : ElevatedButton.styleFrom(
                        backgroundColor : AppColors.buttonColor,
                        shape : RoundedRectangleBorder(borderRadius : BorderRadius.circular(5),),
                      ),
                      child: Text("지원하기", style : TextStyle(color : AppColors.buttonTextColor,),),
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
