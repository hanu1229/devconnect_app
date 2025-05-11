// project_view.dart : 자신의 프로젝트 목록을 출력 하는 페이지

import "package:devconnect_app/app/component/custom_alert.dart";
import "package:devconnect_app/app/component/custom_boolalert.dart";
import "package:devconnect_app/app/component/custom_textfield.dart";
import "package:devconnect_app/app/project/project_detail.dart";
import "package:devconnect_app/app/project/project_update.dart";
import "package:devconnect_app/app/project/projectjoin_company_view.dart";
import "package:devconnect_app/style/app_colors.dart";
import "package:devconnect_app/style/server_path.dart";
import "package:dio/dio.dart";
import "package:flutter/material.dart";
import "package:flutter_rating_bar/flutter_rating_bar.dart";
import "package:shared_preferences/shared_preferences.dart";

class ViewProject extends StatefulWidget {

  @override
  State<ViewProject> createState() => _ViewProjectState();

}

class _ViewProjectState extends State<ViewProject> {

  Dio dio = Dio();
  List<dynamic> projectList = [];
  // 개발자 리스트
  List<Map<String,dynamic>> developerList = [];
  // 점수 변수
  double updateValue = 0;
  int? selectedDno;

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

  // 입력 컨트롤러
  TextEditingController titleController = TextEditingController();
  TextEditingController contentController = TextEditingController();

  // 평가 모달을 띄우는 메서드
  void showRatingDialog(int pno , int dno) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return CustomAlertDialog(
          width: MediaQuery.of(context).size.width * 0.9,
          title: "평가 등록",
          btnTitle: "등록",
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("개발자 선택"),
              SizedBox(height: 10),
              DropdownButtonFormField<int>(
                value: selectedDno,
                hint: Text("개발자를 선택하세요"),
                items: developerList.map((dev) {
                  return DropdownMenuItem<int>(
                    value: dev["dno"],
                    child: Text(dev["dname"] ?? "이름없음"),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedDno = value;
                  });
                },
              ),
              SizedBox(height: 20),
              Text("제목"),
              SizedBox(height: 10),
              CustomTextField(controller: titleController),
              SizedBox(height: 30),
              Text("내용"),
              SizedBox(height: 10),
              CustomTextField(controller: contentController, maxLines: 5),
              SizedBox(height: 20),
              Center(
                child: RatingBar(
                  initialRating: updateValue,
                  minRating: 0.5,
                  direction: Axis.horizontal,
                  itemCount: 5,
                  itemSize: 40,
                  allowHalfRating: true,
                  onRatingUpdate: (ratingValue) {
                    setState(() {
                      updateValue = ratingValue;
                    });
                  },
                  ratingWidget: RatingWidget(
                    full: Icon(Icons.star, color: AppColors.ratingTextColor),
                    half: Icon(Icons.star_half, color: AppColors.ratingTextColor),
                    empty: Icon(Icons.star_border, color: AppColors.ratingTextColor),
                  ),
                ),
              ),
              SizedBox(height: 20),
              Divider(),
            ],
          ),
          onPressed: () {
            Navigator.of(context).pop();
            ratingWrite(pno,dno);
          },
        );
      },
    );
  } // showRatingDialog end

  // 프로젝트 번호로 개발자 정보 찾기
  Future<void> getDno( pno ) async {
    try{
      final presf = await SharedPreferences.getInstance();
      final token = presf.getString("token");
      dio.options.headers["Authorization"] = token;
      final response = await dio.get("${serverPath}/api/project-join/getdno?pno=${pno}");
      print("response.data = ${response.data}");
      if( response.data != null ){
        setState(() {
          developerList = List<Map<String, dynamic>>.from(response.data);
          print("developerList = ${developerList}");
        });
      }
    }catch(e) { print( e ); }
  } // getDno end

  // 평가 등록 05-11 이민진 추가
  void ratingWrite( int pno , int dno) async {
    try{
      final sendData = {
        "dtitle": titleController.text,
        "dcontent": contentController.text,
        "drscore" : updateValue,
        "pno": pno,
        "dno": dno,
      };
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("token");
      dio.options.headers['Authorization'] = token;
      final response = await dio.post("${serverPath}/api/drating" , data: sendData );
      final data = response.data;
      if( data == true ) {
        showDialog(
            context: context,
            builder: (context) => CustomBoolAlertDialog(
              title: "등록 완료",
              content: Text("평가를 등록했습니다."),
              onPressed: () {
                setState(() {
                  Navigator.of(context).pop();
                });
              },
            )
        );
      }
    }catch(e) { print( e ); }
  } // ratingWrite end

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
                                      // 평가하기 버튼
                                      Container(
                                        padding: EdgeInsets.only(left: 16, top: 0, right: 16, bottom: 0),
                                        width: MediaQuery.of(context).size.width,
                                        child: ElevatedButton(
                                          onPressed: () async {
                                            Navigator.pop(context); // 모달 닫기
                                            await getDno(project["pno"]);
                                            if( developerList.isNotEmpty){
                                              int dno = developerList[0]["dno"];
                                              showRatingDialog(project["pno"],dno);
                                            }else{
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                SnackBar(content: Text("해당 프로젝트에 등록된 개발자가 없습니다.")),
                                              );
                                            }
                                          },
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.green,
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(12),
                                            ),
                                          ),
                                          child: Text("평가하기", style: TextStyle(color: AppColors.buttonTextColor, fontSize: 20)),
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