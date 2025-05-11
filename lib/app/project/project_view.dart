// project_view.dart : 자신의 프로젝트 목록을 출력 하는 페이지

import "dart:convert";

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
  String? token; // 토큰 상태필드
  String? tokenrole; // role 이름
  List<Map<String,dynamic>> dnoList = [];
  double updateValue = 0;
  int? pno = 0;
  int? selectedDno; // 선택된 dno

  // 토큰 읽기 담당
  Map<String,dynamic> parseJwt( String token ){
    // JWT 토큰은 .으로 구분 되므로 이걸로 구별해서 담기 // <Header>.<Payload>.<Signature>
    final parts = token.split('.');
    // jWT 토큰은 XXx.XXX.XXX 이렇게 나오므로 3이 아니면 안됨
    if( parts.length != 3 ){
      throw Exception('Invalid token');
    } // if end
    // JWT 토큰의 가운데인 payload 가져오기
    final payload = parts[1];
    // Base64 디코딩
    String normalized = base64.normalize(payload);
    final payloadBytes = base64.decode(normalized);
    final payloadString = utf8.decode(payloadBytes);
    final payloadMap = json.decode(payloadString);

    if( payloadMap is! Map<String,dynamic> ) {
      throw Exception('Invalid payload');
    } // if end
    return payloadMap;
  } // parseJwt end

  // 토큰읽어서 구분 후 해당하는 자료 요쳥
  void whyToken() async {
    // 토큰 있는지 확인
    final prefs = await SharedPreferences.getInstance();
    final whyToken = prefs.getString("token");
    // 토큰 유무 검사
    if( whyToken == null ){ print("권한이 없습니다."); return; }
    // 토큰이 있으면 상태필드에 저장 실행
    token = whyToken;
    final decoded = parseJwt(whyToken);
    final role = decoded['role']; // Company , Developer ,Admin
    final id = decoded['id'];
    // 토큰 검사
    print("role :  + ${role} , id :  + ${id} " );
    tokenrole = role;
  } // whyToken end

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

  @override
  void initState() {
    super.initState();
    findAllMyProject();
    whyToken();
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

  // 평가 모달을 띄우는 메서드
  void showRatingDialog() {
    Widget dropdownWidget;
    if (tokenrole == "Company") {
      dropdownWidget = DropdownButtonFormField<int>(
        value: selectedDno,
        items: dnoList.map<DropdownMenuItem<int>>((dev) {
          return DropdownMenuItem<int>(
            value: dev["dno"],
            child: Text("(${dev["dno"]}) ${dev["dname"]} "),
          );
        }).toList(),
        onChanged: (value) {
          setState(() {
            selectedDno = value!;
          });
        },
        decoration: InputDecoration(
          labelText: "개발자 선택",
          border: OutlineInputBorder(),
        ),
      );
    }else {
      dropdownWidget = Text("없습니다.");
    }

    showDialog(
      context: context,
      barrierDismissible: false, // 바깥 클릭 막기
      builder: (context) {
        return CustomAlertDialog(
          width: MediaQuery.of(context).size.width * 0.9, // 가로폭 제한
          title: "평가 등록",
          btnTitle: "등록",
          content: Container(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                dropdownWidget,
                Text("제목"),
                SizedBox(height: 10),
                CustomTextField(controller: titleController),
                SizedBox(height: 30),
                Text("내용"),
                SizedBox(height: 10),
                CustomTextField(controller: contentController, maxLines: 5),
                SizedBox(height: 20),
                // 별점으로 수정
                Center(
                  child: RatingBar(
                    initialRating: updateValue, // 초기 평점 값
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
          ),
          onPressed: () {
            Navigator.of(context).pop(); // 모달 닫기
            ratingWrite(); // 평가 등록
          },
        );
      },
    );
  }

  // 입력 컨트롤러
  TextEditingController titleController = TextEditingController();
  TextEditingController contentController = TextEditingController();

  // dno 추출 05-08 이민진 추가
  Future<void> getDno( pno ) async {
    try{
      print(token);
      print(tokenrole);
      dio.options.headers["Authorization"] = token;
      final response = await dio.get("${serverPath}/api/project-join/getdno?pno=${pno}");
      if( response.data != null ){
        setState(() {
          dnoList = List<Map<String,dynamic>>.from(response.data);
        });
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
        "dno": selectedDno,
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
                                      // 평가 버튼
                                      Container(
                                        padding : EdgeInsets.only(left : 16, top : 0, right : 16, bottom : 0),
                                        width : MediaQuery.of(context).size.width,
                                        child : ElevatedButton(
                                          onPressed : () async {
                                            Navigator.pop(context);
                                            setState(() {
                                              pno = projectList[index]["pno"];
                                            });
                                            if( pno != null ){
                                              await getDno(pno!);
                                            }
                                            showRatingDialog(); // 모달 열기
                                          },
                                          style : ElevatedButton.styleFrom(
                                            backgroundColor : AppColors.ratingbtnColor,
                                            shape : RoundedRectangleBorder(
                                              borderRadius : BorderRadius.circular(12),
                                            ),
                                          ),
                                          child : Text("평가하기", style : TextStyle(color : AppColors.buttonTextColor, fontSize : 20)),
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
                                          onPressed : () {
                                            deleteProject(context, projectList[index]["pno"]);
                                          },
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
