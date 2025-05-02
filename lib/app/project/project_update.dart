// project_update.dart : 프로젝트 수정 페이지

import "package:devconnect_app/app/component/custom_card.dart";
import "package:devconnect_app/app/project/project_view.dart";
import "package:devconnect_app/style/app_colors.dart";
import "package:devconnect_app/style/server_path.dart";
import "package:dio/dio.dart";
import "package:flutter/material.dart";
import "package:shared_preferences/shared_preferences.dart";

class UpdateProject extends StatefulWidget {
  Map<String, dynamic> project = {};

  UpdateProject({super.key, required this.project});

  @override
  State<UpdateProject> createState() => _UpdateProjectState();

}

class _UpdateProjectState extends State<UpdateProject> {

  Dio dio = Dio();

  DateTime firstDate = DateTime(2000, 1, 1);
  DateTime lastDate = DateTime(2100, 12, 31);
  DateTime? newDate = DateTime(2025);

  String? pstart = DateTime.now().toString().split(" ")[0];
  String? pend = DateTime.now().toString().split(" ")[0];
  String? rpstart = DateTime.now().toString().split(" ")[0];
  String? rpend = DateTime.now().toString().split(" ")[0];
  String nowDate = DateTime.now().toString().split(" ")[0];

  List<String> ptypeList = ["전체", "백엔드", "프론트엔드"];
  String? ptypeValue;

  DateTime parseDate(String date) => DateTime.parse(date);

  TextEditingController pnameController = TextEditingController();
  TextEditingController pintroController = TextEditingController();
  TextEditingController pcommentController = TextEditingController();
  TextEditingController pcountController = TextEditingController();
  TextEditingController pstartController = TextEditingController();
  TextEditingController pendController = TextEditingController();
  TextEditingController rpstartController = TextEditingController();
  TextEditingController rpendController = TextEditingController();
  TextEditingController ppayController = TextEditingController();

  /// 서버에 수정된 데이터 전달하기
  Future<void> updateProject(BuildContext context) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("token");
      int index = ptypeList.indexOf(ptypeValue!);
      if(index == -1) { return; }
      Map<String, dynamic> sendData = {
        "pno" : widget.project["pno"],
        "pname" : pnameController.text,
        "ptype" : index,
        "pcount" : int.parse(pcountController.text),
        "pstart" : parseDate(pstart!).toIso8601String(),
        "pend" : parseDate(pend!).toIso8601String(),
        "recruit_pstart" : parseDate(rpstart!).toIso8601String(),
        "recruit_pend" : parseDate(rpend!).toIso8601String(),
        "pintro" : pintroController.text,
        "pcomment" : pcommentController.text,
        "ppay" : int.parse(ppayController.text),
      };
      final options = Options(headers : {"Authorization" : token});
      final response = await dio.put("$serverPath/api/project", data : sendData, options : options);
      final data = response.data;
      final statusCode = response.statusCode;
      if(statusCode == 200 && data == true) {
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
                            child : Text("확인", style : TextStyle(color : AppColors.buttonTextColor)),
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

  @override
  void initState() {
    super.initState();
    print(widget.project);
    print(">> ${widget.project["pno"].runtimeType}");
    int ptype = widget.project["ptype"];
    switch(ptype) {
      case 0 :
        ptypeValue = "전체";
        break;
      case 1:
        ptypeValue = "백엔드";
        break;
      case 2:
        ptypeValue = "프론트엔드";
        break;
    }
    pnameController.text = widget.project["pname"];
    // ptypeValue =  widget.project["ptype"];
    pcountController.text = widget.project["pcount"].toString();
    pstart = widget.project["pstart"].toString().split("T")[0];
    pend = widget.project["pend"].toString().split("T")[0];
    rpstart = widget.project["recruit_pstart"].toString().split("T")[0];
    rpend = widget.project["recruit_pend"].toString().split("T")[0];
    pintroController.text = widget.project["pintro"];
    pcommentController.text = widget.project["pcomment"];
    ppayController.text = widget.project["ppay"].toString();
  }

  Widget customTextFieldUpdate({required String labelText, required TextEditingController? controller, bool numberKey = false}) {
    return TextField(
      controller : controller,
      keyboardType : numberKey ? TextInputType.number : TextInputType.text,
      decoration : InputDecoration(
        hintText : labelText,
        border : OutlineInputBorder(borderSide : BorderSide(color : AppColors.borderColor, width : 1,),),
        enabledBorder : OutlineInputBorder(borderSide : BorderSide(color : AppColors.borderColor, width : 1,),),
        focusedBorder : OutlineInputBorder(borderSide : BorderSide(color : AppColors.focusColor, width : 1),),
      ),
    );
  }

  Widget customTheme(BuildContext context, Widget? child) {
    return Theme(
      data : Theme.of(context).copyWith(
        dialogTheme : DialogTheme(backgroundColor : AppColors.bgColor,),
        colorScheme : ColorScheme.light(
          primary : AppColors.buttonColor,
          surface : AppColors.bgColor,
        ),
        textButtonTheme : TextButtonThemeData(
          style : TextButton.styleFrom(foregroundColor : AppColors.buttonColor),
        ),
      ),
      child: child!,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset : true,
      appBar : AppBar(
        title : Text("프로젝트 수정"),
      ),
      body : SafeArea(
        child: SingleChildScrollView(
          child : Container(
            padding : EdgeInsets.all(16),
            width : MediaQuery.of(context).size.width,
            child : Column(
              children : [
                // 제목 | 직무 | 모집 인원
                CustomCard(
                  elevation : 0,
                  child : Column(
                    crossAxisAlignment : CrossAxisAlignment.start,
                    children : [
                      Text("제목", style : TextStyle(fontFamily : "NanumGothic", fontWeight : FontWeight.bold, fontSize : 20,),),
                      SizedBox(height : 10),
                      customTextFieldUpdate(labelText: "제목", controller: pnameController),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical : 10),
                        child: Text("직무", style : TextStyle(fontFamily : "NanumGothic", fontWeight : FontWeight.bold, fontSize : 20,),),
                      ),
                      DropdownButtonFormField(
                        value : ptypeValue,
                        dropdownColor : Colors.white,
                        decoration : InputDecoration(
                          hintText : "직무",
                          enabledBorder : OutlineInputBorder(borderSide : BorderSide(color : AppColors.borderColor, width : 1),),
                          border : OutlineInputBorder(borderSide : BorderSide(color : AppColors.borderColor, width : 1),),
                          focusedBorder : OutlineInputBorder(borderSide : BorderSide(color : AppColors.focusColor, width : 1),),
                        ),
                        items: ptypeList.map((item) {
                          return DropdownMenuItem<String>(
                            value : item,
                            child : Text(item),
                          );
                        }).toList(),
                        onChanged: (String? value) {
                          setState(() { ptypeValue = value; });
                        },
                        validator: (value) => value == null ? '값을 선택해주세요' : null,
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical : 10),
                        child: Text("모집 인원", style : TextStyle(fontFamily : "NanumGothic", fontWeight : FontWeight.bold, fontSize : 20,),),
                      ),
                      customTextFieldUpdate(labelText: "모집 인원", controller: pcountController, numberKey : true),
                    ],
                  ),
                ),
                SizedBox(height : 20),
                // 프로젝트 기간
                CustomCard(
                  elevation : 0,
                  child : Column(
                    crossAxisAlignment : CrossAxisAlignment.start,
                    children : [
                      Text("프로젝트 기간", style : TextStyle(fontFamily : "NanumGothic", fontSize : 20, fontWeight : FontWeight.bold),),
                      Row(
                        children: [
                          Text("시작일", style : TextStyle(fontFamily : "NanumGothic", fontSize : 20,),),
                          TextButton(
                            onPressed: () async {
                              DateTime? dateTime = await showDatePicker(
                                barrierDismissible : false,
                                initialDate : DateTime.now(),
                                context: context,
                                firstDate: firstDate,
                                lastDate: lastDate,
                                builder : (BuildContext context, Widget? child) {
                                  return customTheme(context, child);
                                },
                              );
                              setState(() {
                                final dateSplit = dateTime.toString().split(" ");
                                pstart = dateTime == null ? pstart : dateSplit[0];
                                print(">> pstart : $pstart");
                              });
                            },
                            child: Text("$pstart", style : TextStyle(color : AppColors.buttonColor,fontFamily : "NanumGothic", fontSize : 20,),),
                          ),
                        ],
                      ),
                      Row(
                        children : [
                          Text("마감일", style : TextStyle(fontFamily : "NanumGothic", fontSize : 20,),),
                          TextButton(
                            onPressed: () async {
                              DateTime? dateTime = await showDatePicker(
                                barrierDismissible : false,
                                initialDate : DateTime.now(),
                                context: context,
                                firstDate: firstDate,
                                lastDate: lastDate,
                                builder : (BuildContext context, Widget? child) {
                                  return customTheme(context, child);
                                },
                              );
                              setState(() {
                                final dateSplit = dateTime.toString().split(" ");
                                pend = dateTime == null ? pend : dateSplit[0];
                              });
                            },
                            child: Text("$pend", style : TextStyle(color : AppColors.buttonColor,fontFamily : "NanumGothic", fontSize : 20,),),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(height : 20),
                // 모집 기간
                CustomCard(
                  elevation : 0,
                  child : Column(
                    crossAxisAlignment : CrossAxisAlignment.start,
                    children : [
                      Text("모집 기간", style : TextStyle(fontFamily : "NanumGothic", fontSize : 20, fontWeight : FontWeight.bold),),
                      Row(
                        children : [
                          Text("시작일", style : TextStyle(fontFamily : "NanumGothic", fontSize : 20,),),
                          TextButton(
                            onPressed: () async {
                              DateTime? dateTime = await showDatePicker(
                                barrierDismissible : false,
                                initialDate : DateTime.now(),
                                context: context,
                                firstDate: firstDate,
                                lastDate: lastDate,
                                builder : (BuildContext context, Widget? child) {
                                  return customTheme(context, child);
                                },
                              );
                              setState(() {
                                final dateSplit = dateTime.toString().split(" ");
                                rpstart = dateTime == null ? rpstart : dateSplit[0];
                              });
                            },
                            child: Text("$rpstart", style : TextStyle(color : AppColors.buttonColor, fontFamily : "NanumGothic", fontSize : 20,),),
                          ),
                        ],
                      ),
                      Row(
                        children : [
                          Text("마감일", style : TextStyle(fontFamily : "NanumGothic", fontSize : 20,),),
                          TextButton(
                            onPressed: () async {
                              DateTime? dateTime = await showDatePicker(
                                barrierDismissible : false,
                                initialDate : DateTime.now(),
                                context: context,
                                firstDate: firstDate,
                                lastDate: lastDate,
                                builder : (BuildContext context, Widget? child) {
                                  return customTheme(context, child);
                                },
                              );
                              setState(() {
                                final dateSplit = dateTime.toString().split(" ");
                                rpend = dateTime == null ? rpend : dateSplit[0];
                              });
                            },
                            child: Text("$rpend", style : TextStyle(color : AppColors.buttonColor, fontFamily : "NanumGothic", fontSize : 20,),),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(height : 20),
                // 간단한 소개 | 내용 | 급여
                CustomCard(
                  elevation : 0,
                  child : Column(
                    crossAxisAlignment : CrossAxisAlignment.start,
                    children : [
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical : 10),
                        child: Text("간단한 소개", style : TextStyle(fontFamily : "NanumGothic", fontWeight : FontWeight.bold, fontSize : 20,),),
                      ),
                      customTextFieldUpdate(labelText : "간단한 소개", controller : pintroController),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical : 10),
                        child: Text("내용", style : TextStyle(fontFamily : "NanumGothic", fontWeight : FontWeight.bold, fontSize : 20,),),
                      ),
                      // customTextFieldUpdate(labelText : "내용", controller : null),
                      TextField(
                        controller : pcommentController,
                        maxLines : 10,
                        decoration : InputDecoration(
                          hintText : "내용",
                          border : OutlineInputBorder(borderSide : BorderSide(color : AppColors.borderColor, width : 1,),),
                          enabledBorder : OutlineInputBorder(borderSide : BorderSide(color : AppColors.borderColor, width : 1,),),
                          focusedBorder : OutlineInputBorder(borderSide : BorderSide(color : AppColors.focusColor, width : 1),),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical : 10),
                        child: Text("급여(만원)", style : TextStyle(fontFamily : "NanumGothic", fontWeight : FontWeight.bold, fontSize : 20,),),
                      ),
                      customTextFieldUpdate(labelText : "급여(만원)", controller : ppayController, numberKey : true),
                    ],
                  ),
                ),
                SizedBox(height : 20),
                // 수정 버튼
                SizedBox(
                  width : MediaQuery.of(context).size.width,
                  child : ElevatedButton(
                    onPressed: () {
                      updateProject(context);
                    },
                    style : ElevatedButton.styleFrom(
                      backgroundColor : AppColors.buttonColor,
                      shape : RoundedRectangleBorder(
                        borderRadius : BorderRadius.circular(12),
                      ),
                    ),
                    child: Text("수정하기", style : TextStyle(fontSize : 20, color : AppColors.buttonTextColor)),
                  ),
                ),
                SizedBox(height : 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
