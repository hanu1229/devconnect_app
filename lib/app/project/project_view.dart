// project_view.dart : 자신의 프로젝트 목록을 출력 하는 페이지

import "package:devconnect_app/app/project/project_detail.dart";
import "package:devconnect_app/app/project/project_update.dart";
import "package:devconnect_app/app/project/projectjoin_company_view.dart";
import "package:devconnect_app/style/app_colors.dart";
import "package:devconnect_app/style/server_path.dart";
import "package:dio/dio.dart";
import "package:flutter/material.dart";
import "package:shared_preferences/shared_preferences.dart";

class ViewProject extends StatefulWidget {

  @override
  State<ViewProject> createState() => _ViewProjectState();

}

class _ViewProjectState extends State<ViewProject> {

  Dio dio = Dio();
  List<dynamic> projectList = [];

  /// 내 프로젝트 목록 전체 가져오기
  Future<void> findAllMyProject() async {
    try {
      final pref = await SharedPreferences.getInstance();
      final token = pref.getString("token");
      final response = await dio.get("$serverPath/api/project/company", options : Options(headers : {"Authorization" : token}));
      final data = response.data;
      if(data == null) { return; }
      print(data);
      setState(() { projectList = data; });
    } catch(e) {
      print(e);
    }
  }

  /// 내 프로젝트 목록 삭제하기 | 추후 모집 기한이 지난 프로젝트는 삭제 못하도록 막기
  Future<void> deleteProject(BuildContext context, int pno) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("token");
      final response = await dio.delete("$serverPath/api/project?pno=$pno", options : Options(headers : {"Authorization" : token}));
      final data = response.data;
      final statusCode = response.statusCode;
      if(statusCode == 200 && data == true) {
        Navigator.pop(context);
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
                              setState(() { findAllMyProject(); });
                              return;
                            },
                            style : ElevatedButton.styleFrom(
                              backgroundColor : AppColors.buttonColor,
                              shape : RoundedRectangleBorder(
                                borderRadius : BorderRadius.circular(12),
                              ),
                            ),
                            child : Text("확인", style : TextStyle(fontSize : 20, color : AppColors.buttonTextColor)),
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
      // 404 오류 시 실행
      Navigator.pop(context);
      showModalBottomSheet(
        context: context,
        builder: (context) {
          return SafeArea(
            child: Container(
              margin : EdgeInsets.all(16),
              height : 150,
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
                      Center(child : Text("삭제할 수 없습니다.", style : TextStyle(fontSize : 20, fontWeight : FontWeight.bold, color : Colors.red,),),),
                      Container(
                        padding : EdgeInsets.only(left : 16, top : 0, right : 16, bottom : 0),
                        width : MediaQuery.of(context).size.width,
                        child : ElevatedButton(
                          onPressed : () {
                            // 모달창 삭제
                            Navigator.pop(context);
                            // setState(() { findAllMyProject(); });
                            return;
                          },
                          style : ElevatedButton.styleFrom(
                            backgroundColor : AppColors.buttonColor,
                            shape : RoundedRectangleBorder(
                              borderRadius : BorderRadius.circular(12),
                            ),
                          ),
                          child : Text("확인", style : TextStyle(fontSize : 20, color : AppColors.buttonTextColor)),
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
      print(e);
    }
  }

  @override
  void initState() {
    super.initState();
    findAllMyProject();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    print(">>>> 실행");
    findAllMyProject();
  }

  Widget CustomCard({required Map<String, dynamic> project}) {

    String pstart = project["pstart"].split("T")[0];
    String pend = project["pend"].split("T")[0];
    String rpstart = project["recruit_pstart"].split("T")[0];
    String rpend = project["recruit_pend"].split("T")[0];

    return Container(
      padding : EdgeInsets.only(bottom : 16),
      child: Card(
        color : AppColors.bgColor,
        shape : RoundedRectangleBorder(
          borderRadius : BorderRadius.circular(10),
          side : BorderSide(color : Color(0xFFD9D9D9), width : 1,),
        ),
        child : ListTile(
          title : Text("${project["pname"]}"),
          subtitle : Column(
            crossAxisAlignment : CrossAxisAlignment.start,
            children : [
              SizedBox(height : 20),
              Text("프로젝트 기한 : $pstart ~ $pend"),
              SizedBox(height : 10),
              Text("모집 기한 : $rpstart ~ $rpend"),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body : SafeArea(
        child: Container(
          padding : EdgeInsets.all(16),
          child : Column(
            children : [
              Expanded(child : ListView.builder(
                controller : null,
                itemCount : projectList.length,
                itemBuilder: (context, index) {
                  final project = projectList[index];
                  // buttonClick이 false이면 수정 및 삭제 안됨
                  bool buttonClick = true;
                  if(project["recruitment_status"] >= 2) { buttonClick = false; }
                  return GestureDetector(
                    onTap : () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder : (context) => DetailProject(pno : projectList[index]["pno"])),
                      );
                    },
                    onLongPress : () {
                      showModalBottomSheet(
                        context: context,
                        builder: (context) {
                          return SafeArea(
                            child : Container(
                              margin : EdgeInsets.all(16),
                              height : 200,
                              width : MediaQuery.of(context).size.width,
                              decoration : BoxDecoration(
                                color : AppColors.bgColor,
                                borderRadius : BorderRadius.all(Radius.circular(16)),
                              ),
                              child : Center(
                                child : Padding(
                                  padding: EdgeInsets.symmetric(vertical : 16),
                                  child : Column(
                                    mainAxisAlignment : MainAxisAlignment.spaceAround,
                                    children : [
                                      // 신청 현황 버튼
                                      Container(
                                        padding : EdgeInsets.only(left : 16, top : 0, right : 16, bottom : 0),
                                        width : MediaQuery.of(context).size.width,
                                        child : ElevatedButton(
                                          onPressed : () async {
                                            Navigator.pop(context);
                                            bool? result = await Navigator.push(
                                              context,
                                              MaterialPageRoute(builder : (context) => ViewProjectJoin(pno : projectList[index]["pno"], pname : projectList[index]["pname"])),
                                            );
                                            if(result == true) { setState(() { findAllMyProject(); }); }
                                            return;
                                          },
                                          style : ElevatedButton.styleFrom(
                                            backgroundColor : Colors.deepPurpleAccent,
                                            shape : RoundedRectangleBorder(
                                              borderRadius : BorderRadius.circular(12),
                                            ),
                                          ),
                                          child : Text("신청 현황", style : TextStyle(color : AppColors.buttonTextColor, fontSize : 20)),
                                        ),
                                      ),
                                      // 수정 버튼
                                      Container(
                                        padding : EdgeInsets.only(left : 16, top : 0, right : 16, bottom : 0),
                                        width : MediaQuery.of(context).size.width,
                                        child : ElevatedButton(
                                          onPressed : buttonClick ? () async {
                                            if(buttonClick) {
                                              Navigator.pop(context);
                                              bool? result = await Navigator.push(
                                                context,
                                                MaterialPageRoute(builder : (context) => UpdateProject(project : projectList[index])),
                                              );
                                              if(result == true) { setState(() { findAllMyProject(); }); }
                                            } else {
                                              Navigator.pop(context);
                                              showModalBottomSheet(
                                                context: context,
                                                builder: (context) {
                                                  return SafeArea(
                                                    child: Container(
                                                      margin : EdgeInsets.all(16),
                                                      height : 150,
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
                                                              Center(child : Text("수정할 수 없습니다.", style : TextStyle(fontSize : 20, fontWeight : FontWeight.bold, color : Colors.red,),),),
                                                              Container(
                                                                padding : EdgeInsets.only(left : 16, top : 0, right : 16, bottom : 0),
                                                                width : MediaQuery.of(context).size.width,
                                                                child : ElevatedButton(
                                                                  onPressed : () {
                                                                    // 모달창 삭제
                                                                    Navigator.pop(context);
                                                                    // setState(() { findAllMyProject(); });
                                                                    return;
                                                                  },
                                                                  style : ElevatedButton.styleFrom(
                                                                    backgroundColor : AppColors.buttonColor,
                                                                    shape : RoundedRectangleBorder(
                                                                      borderRadius : BorderRadius.circular(12),
                                                                    ),
                                                                  ),
                                                                  child : Text("확인", style : TextStyle(fontSize : 20, color : AppColors.buttonTextColor)),
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

                                            return;
                                          } : null,
                                          style : ElevatedButton.styleFrom(
                                            backgroundColor : AppColors.buttonColor,
                                            shape : RoundedRectangleBorder(
                                              borderRadius : BorderRadius.circular(12),
                                            ),
                                          ),
                                          child : Text("수정하기", style : TextStyle(color : AppColors.buttonTextColor, fontSize : 20)),
                                        ),
                                      ),
                                      // 삭제 버튼
                                      Container(
                                        padding : EdgeInsets.only(left : 16, top : 0, right : 16, bottom : 0),
                                        width : MediaQuery.of(context).size.width,
                                        child : ElevatedButton(
                                          onPressed : buttonClick ? () {
                                            showDialog(
                                              context : context,
                                              builder : (context) {
                                                return AlertDialog(
                                                  title : Text("정말 삭제하시겠습니까?"),
                                                  actions : [
                                                    ElevatedButton(
                                                      onPressed : () {
                                                        Navigator.pop(context);
                                                        Navigator.pop(context);
                                                      },
                                                      style : ElevatedButton.styleFrom(
                                                        backgroundColor : Colors.grey,
                                                        shape : RoundedRectangleBorder(
                                                          borderRadius : BorderRadius.circular(10),
                                                        ),
                                                      ),
                                                      child : Text("취소", style : TextStyle(color : Colors.white,),),
                                                    ),
                                                    ElevatedButton(
                                                      onPressed : () {
                                                        deleteProject(context, projectList[index]["pno"]);
                                                        Navigator.pop(context);
                                                      },
                                                      style : ElevatedButton.styleFrom(
                                                        backgroundColor : Colors.blue,
                                                        shape : RoundedRectangleBorder(
                                                          borderRadius : BorderRadius.circular(10),
                                                        ),
                                                      ),
                                                      child : Text("확인", style : TextStyle(color : Colors.white,),),
                                                    ),
                                                  ],
                                                );
                                              }
                                            );
                                            // deleteProject(context, projectList[index]["pno"]);
                                          } : null,
                                          style : ElevatedButton.styleFrom(
                                            backgroundColor : Colors.red,
                                            shape : RoundedRectangleBorder(
                                              borderRadius : BorderRadius.circular(12),
                                            ),
                                          ),
                                          child : Text("삭제하기", style : TextStyle(color : AppColors.buttonTextColor, fontSize : 20)),
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
                    },
                    child : CustomCard(project : projectList[index]),
                  );
                },
              ),),
            ],
          ),
        ),
      ),
    );
  }

}
