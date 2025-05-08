// project_view.dart : 자신의 프로젝트 목록을 출력 하는 페이지

import "package:devconnect_app/app/company/company_menutabs.dart";
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

class CompanyProjectView extends StatefulWidget {

  final Function(int) changePage;

  const CompanyProjectView({
    required this.changePage,
  });

  @override
  State<CompanyProjectView> createState() => _CompanyProjectViewState();

}

class _CompanyProjectViewState extends State<CompanyProjectView> {

  Dio dio = Dio();
  List<dynamic> projectList = [];
  List<dynamic> dnoList = [];
  double updateValue = 0;
  int? pno = 0;

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

  // 입력 컨트롤러
  TextEditingController titleController = TextEditingController();
  TextEditingController contentController = TextEditingController();

  // dno 추출 05-08 이민진 추가
  void getDno( pno ) async {
    try{
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("token");
      dio.options.headers["Authorization"] = token;
      final response = await dio.get("${serverPath}/api/project-join/getdno?pno=${pno}");
      if( response.data != null ){
        dnoList = response.data;
        print( "dnoList : ${dnoList}");
      }
    }catch(e) { print(e); }
  } // getDno end

  // 평가등록 05-08 이민진 추가
  void ratingWrite() async {
    try {
      final sendData = {
        "dtitle": titleController.text,
        "dcontent": contentController.text,
        "drscore" : updateValue,
        "pno": pno,
        "dno": dnoList,
      };
      print("senddata : ${sendData}");
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("token");
      dio.options.headers['Authorization'] = token;
      final response = await dio.post("${serverPath}/api/drating", data: sendData);
      final data = response.data;
      if( data == true ){
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
    } catch (e) {
      print(e);
    }
  } // ratingWrite end

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
    print("projectList : ${projectList}");
    return Scaffold(
      backgroundColor: AppColors.textFieldBGColor,
      body : Padding(
        padding: EdgeInsets.all(20),
        child: Container(
          child : Column(
            children : [
              CompanyMenuTabs(
                  changePage: widget.changePage,
                  selectedIndex: 8,
              ),
              SizedBox( height: 15 ,),
              Text("내프로젝트", style: TextStyle( fontSize: 18, fontWeight: FontWeight.bold, ), ),
              SizedBox( height: 10 ,),
              Expanded(child : ListView.builder(
                controller : null,
                itemCount : projectList.length,
                itemBuilder: (context, index) {
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
                                            backgroundColor : Colors.black,
                                          ),
                                          child : Text("신청 현황", style : TextStyle(color : AppColors.buttonTextColor)),
                                        ),
                                      ),
                                      // 평가 버튼
                                      Container(
                                        padding: EdgeInsets.only(left: 16, top: 0 , right: 16, bottom: 0 ),
                                        width: MediaQuery.of(context).size.width,
                                        child: ElevatedButton(
                                            onPressed: () async {
                                              Navigator.pop(context);
                                              pno = projectList[index]["pno"];
                                              getDno(pno);
                                              print( "pno : ${pno }");
                                              showDialog(
                                                  context: context,
                                                  barrierDismissible: false, // 바깥 클릭 막기
                                                  builder: (context) {
                                                    return CustomAlertDialog(
                                                      width: MediaQuery.of(context).size.width * 0.9, // 가로폭 제한
                                                      title: "평가하기",
                                                      btnTitle: "평가",
                                                      content: Container(
                                                        constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.7 ),
                                                        child: SingleChildScrollView(
                                                          child: Column(
                                                            mainAxisSize: MainAxisSize.min,
                                                            crossAxisAlignment: CrossAxisAlignment.start,
                                                            children: [
                                                              Text("제목"),
                                                              SizedBox( height: 10,),
                                                              CustomTextField(
                                                                controller: titleController,
                                                              ),
                                                              SizedBox(height: 15),
                                                              Text("내용"),
                                                              SizedBox( height: 10,),
                                                              CustomTextField(
                                                                controller: contentController,
                                                                maxLines: 5,
                                                              ),
                                                              SizedBox(height: 10),
                                                              Center(
                                                                child:
                                                                  RatingBar(
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
                                                                      full: Icon(Icons.star,
                                                                        color: AppColors
                                                                            .ratingTextColor,),
                                                                      half: Icon(Icons.star_half,
                                                                        color: AppColors
                                                                            .ratingTextColor,),
                                                                      empty: Icon(Icons.star_border,
                                                                        color: AppColors
                                                                            .ratingTextColor,),
                                                                    ),
                                                                  ),
                                                              ),
                                                              SizedBox(height: 10,),
                                                              Divider(),
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                      onPressed: () {
                                                        Navigator.of(context).pop();
                                                        ratingWrite();
                                                      },
                                                    );
                                                  }
                                              );
                                            },
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: AppColors.focusColor,
                                            ),
                                            child: Text("평가하기" , style: TextStyle( color: AppColors.buttonTextColor) ),
                                        ),
                                      ),
                                      // 수정 버튼
                                      Container(
                                        padding : EdgeInsets.only(left : 16, top : 0, right : 16, bottom : 0),
                                        width : MediaQuery.of(context).size.width,
                                        child : ElevatedButton(
                                          onPressed : () async {
                                            Navigator.pop(context);
                                            bool? result = await Navigator.push(
                                              context,
                                              MaterialPageRoute(builder : (context) => UpdateProject(project : projectList[index])),
                                            );
                                            if(result == true) { setState(() { findAllMyProject(); }); }
                                            return;
                                          },
                                          style : ElevatedButton.styleFrom(
                                            backgroundColor : AppColors.buttonColor,
                                          ),
                                          child : Text("수정하기", style : TextStyle(color : AppColors.buttonTextColor)),
                                        ),
                                      ),
                                      // 삭제 버튼
                                      Container(
                                        padding : EdgeInsets.only(left : 16, top : 0, right : 16, bottom : 0),
                                        width : MediaQuery.of(context).size.width,
                                        child : ElevatedButton(
                                          onPressed : () {
                                            deleteProject(context, projectList[index]["pno"]);
                                          },
                                          style : ElevatedButton.styleFrom(
                                            backgroundColor : Colors.red,
                                          ),
                                          child : Text("삭제하기", style : TextStyle(color : AppColors.buttonTextColor)),
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