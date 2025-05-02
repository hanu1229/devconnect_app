// project_write.dart : 프로젝트 등록 페이지

import "package:devconnect_app/app/component/custom_card.dart";
import "package:devconnect_app/app/layout/main_app.dart";
import "package:devconnect_app/style/app_colors.dart";
import "package:devconnect_app/style/server_path.dart";
import "package:fluttertoast/fluttertoast.dart";
import "package:dio/dio.dart";
import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:shared_preferences/shared_preferences.dart";

class WriteProject extends StatefulWidget {

  Function changePage;

  WriteProject({required this.changePage});

  @override
  State<WriteProject> createState() => _WriteProjectState();

}

class _WriteProjectState extends State<WriteProject> {

  Dio dio = Dio();

  // 탭키 제한
  final FocusNode _focusNode = FocusNode(
    onKeyEvent : (FocusNode node, KeyEvent event) {
    if(event is KeyDownEvent && event.logicalKey == LogicalKeyboardKey.tab) {
    // Tab키 무시하고 포커스 이동 제한
    return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
    }
  );

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
  
  // 컨트롤러 선언
  TextEditingController pnameController = TextEditingController();
  TextEditingController pintroController = TextEditingController();
  TextEditingController pcommentController = TextEditingController();
  TextEditingController pcountController = TextEditingController();
  TextEditingController pstartController = TextEditingController();
  TextEditingController pendController = TextEditingController();
  TextEditingController rpstartController = TextEditingController();
  TextEditingController rpendController = TextEditingController();
  TextEditingController ppayController = TextEditingController();

  /// Custom TextField
  Widget customTextField({required String labelText, bool totalCheck = false, bool dateCheck = false, int maxLines = 1, TextEditingController? controller}) {
    return Container(
        margin : EdgeInsets.fromLTRB(0, 0, 0, 20),
        width : totalCheck ? MediaQuery.of(context).size.width * 0.43 : MediaQuery.of(context).size.width,
        child : TextField(
          controller : controller,
          maxLines : maxLines,
          onTap : () async {
            if(dateCheck) {
              DateTime? dateTime = await showDatePicker(
                barrierDismissible : false,
                initialDate : DateTime.now(),
                context: context,
                firstDate: firstDate,
                lastDate: lastDate,
              );
              setState(() {
                final dateSplit = dateTime.toString().split(" ");
                controller?.text = dateTime == null ? "" : dateSplit[0];
              });
            }
          },
          readOnly : dateCheck,
          // focusNode : _focusNode,
          decoration : InputDecoration(
            labelText : labelText,
            labelStyle : TextStyle(overflow : TextOverflow.clip),
            enabledBorder : OutlineInputBorder(
              borderSide : BorderSide(color : AppColors.borderColor),
            ),
            border : OutlineInputBorder(
              borderSide : BorderSide(color : AppColors.borderColor),
            ),
          ),
        )
    );
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

  Future<void> writeProject(BuildContext context) async {
    try {
      SharedPreferences pref = await SharedPreferences.getInstance();
      final token = pref.getString("token");
      int ptype = 0;
      if(ptypeValue == "전체") { ptype = 0; }
      else if(ptypeValue == "백엔드") { ptype = 1; }
      else if(ptypeValue == "프론트엔드") { ptype = 2; }
      final formData = FormData.fromMap({
        "pname" : pnameController.text,
        "pintro" : pintroController.text,
        "pcomment" : pcommentController.text,
        "ptype" : ptype,
        "pcount" : int.parse(pcountController.text),
        "pstart" : parseDate(pstart!).toIso8601String(),
        "pend" : parseDate(pend!).toIso8601String(),
        "recruit_pstart" : parseDate(rpstart!).toIso8601String(),
        "recruit_pend" : parseDate(rpend!).toIso8601String(),
        "ppay" : ppayController.text,
      });
      print(formData);
      final response = await dio.post(
        "$serverPath/api/project",
        data : formData,
        options : Options(headers : {"Authorization" : token}),
      );
      final data = response.data;
      print(data);
      if(data) {
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
                              Navigator.pushReplacement(
                                context,
                                widget.changePage(0),
                              );
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
      } else {
        Fluttertoast.showToast(
          msg: "프로젝트 등록 실패",
          // 메시지 유지시간
          toastLength : Toast.LENGTH_LONG,
          // 메시지 표시 위치 : 앱 적용
          gravity : ToastGravity.BOTTOM,
          // 자세한 유지시간
          timeInSecForIosWeb : 3,
          // 배경색
          backgroundColor : Colors.black,
          // 글자색
          textColor : Colors.white,
          // 글자크기
          fontSize : 16,
          webShowClose: true,
        );
      }
    } catch(e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset : true,
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
                        mainAxisSize : MainAxisSize.min,
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
                                pstart = dateTime == null ? nowDate : dateSplit[0];
                                print(">> pstart : $pstart");
                              });
                            },
                            child: Text("$pstart", style : TextStyle(color : AppColors.buttonColor,fontFamily : "NanumGothic", fontSize : 20,),),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisSize : MainAxisSize.max,
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
                                pend = dateTime == null ? nowDate : dateSplit[0];
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
                                rpstart = dateTime == null ? nowDate : dateSplit[0];
                              });
                            },
                            child: Text("$rpstart", style : TextStyle(color : AppColors.buttonColor,fontFamily : "NanumGothic", fontSize : 20,),),
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
                                rpend = dateTime == null ? nowDate : dateSplit[0];
                              });
                            },
                            child: Text("$rpend", style : TextStyle(color : AppColors.buttonColor,fontFamily : "NanumGothic", fontSize : 20,),),
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
                        child: Text("내용", style : TextStyle(fontFamily : "NanumGothic", fontSize : 20,),),
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
                        child: Text("급여(만원)", style : TextStyle(fontFamily : "NanumGothic", fontSize : 20,),),
                      ),
                      customTextFieldUpdate(labelText : "급여(만원)", controller : ppayController, numberKey : true),
                    ],
                  ),
                ),
                SizedBox(height : 20),
                // 등록 버튼
                SizedBox(
                  width : MediaQuery.of(context).size.width,
                  child : ElevatedButton(
                    onPressed: () {
                      writeProject(context);
                    },
                    style : ElevatedButton.styleFrom(
                      backgroundColor : AppColors.buttonColor,
                      shape : RoundedRectangleBorder(
                        borderRadius : BorderRadius.circular(12),
                      ),
                    ),
                    child: Text("등록하기", style : TextStyle(fontSize : 20, color : AppColors.buttonTextColor)),
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

  /*
    // 이 위젯을 사용하면 그냥 달력 자체가 생김
    CalendarDatePicker(
      initialDate: DateTime.now(),
      firstDate: firstDate,
      lastDate: lastDate,
      onDateChanged: (date) {setState(() { newDate = date; }); },
    ),
  */

}