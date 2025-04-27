// project_write.dart : 프로젝트 등록 페이지

import "package:devconnect_app/style/app_colors.dart";
import "package:devconnect_app/style/server_path.dart";
import "package:fluttertoast/fluttertoast.dart";
import "package:dio/dio.dart";
import "package:flutter/material.dart";
import "package:flutter/services.dart";

class WriteProject extends StatefulWidget {

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

  List<String> ptypeList = ["전체", "백엔드", "프론트엔드"];
  String? ptypeValue;
  
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

  Future<void> writeProject() async {
    try {
      int ptype = 0;
      if(ptypeValue == "전체") { ptype = 0; }
      else if(ptypeValue == "백엔드") { ptype = 1; }
      else if(ptypeValue == "프론트엔드") { ptype = 2; }
      final sendData = {
        "pname" : pnameController.text,
        "pintro" : pintroController.text,
        "pcomment" : pcommentController.text,
        "ptype" : ptype,
        "pcount" : int.parse(pcountController.text),
        "pstart" : pstartController.text,
        "pend" : pendController.text,
        "recruit_pstart" : rpstartController.text,
        "recruit_pend" : rpendController.text,
        "ppay" : ppayController.text,
      };
      print(sendData);
      final response = await dio.post("$serverPath/api/project", data : sendData);
      final data = response.data;
      if(data) {
        Fluttertoast.showToast(
          msg: "프로젝트 등록 성공",
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
        Navigator.pop(context);
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
      // 가상 키보드가 열릴 픽셀이 오버되는 현상 없앰 | false
      resizeToAvoidBottomInset : false,
      body : SizedBox(
        height : MediaQuery.of(context).size.height * 0.83,
        child : SingleChildScrollView(
          child : Column(
            children: [
              Container(
                // color : Colors.amberAccent,
                width : MediaQuery.of(context).size.width,
                child : Padding(
                  padding : EdgeInsets.symmetric(horizontal : 20),
                  child : Column(
                    crossAxisAlignment : CrossAxisAlignment.start,
                    children : [

                      SizedBox(height : 10),
                      Text("제목", style : TextStyle(fontSize : 18,),),
                      SizedBox(height : 10),
                      customTextField(labelText: "제목", controller : pnameController),

                      Divider(color : AppColors.borderColor, height : 2),

                      SizedBox(height : 10),
                      Row(
                        mainAxisAlignment : MainAxisAlignment.spaceAround,
                        children : [
                          Text("직무", style : TextStyle(fontSize : 18,),),
                          Text("모집 인원수", style : TextStyle(fontSize : 18,),),
                        ],
                      ),
                      SizedBox(height : 10),
                      Row(
                        mainAxisAlignment : MainAxisAlignment.spaceAround,
                        crossAxisAlignment : CrossAxisAlignment.start,
                        children : [
                          Expanded(
                            child : DropdownButtonFormField(
                              value : ptypeValue,
                              decoration : InputDecoration(
                                labelText : "직무",
                                enabledBorder : OutlineInputBorder(borderSide : BorderSide(color : AppColors.borderColor, width : 1),),
                                border : OutlineInputBorder(borderSide : BorderSide(color : AppColors.borderColor, width : 1),),
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
                          ),
                          SizedBox(width : MediaQuery.of(context).size.width * 0.02),
                          Expanded(child : customTextField(labelText : "인원수", totalCheck : true, controller : pcountController),)
                        ],
                      ),

                      Divider(color : AppColors.borderColor, height : 2),

                      SizedBox(height : 10),
                      Text("간단 소개", style : TextStyle(fontSize : 18,),),
                      SizedBox(height : 10),
                      customTextField(labelText : "간단 소개", controller : pintroController),
                      Text("상세 소개", style : TextStyle(fontSize : 18,),),
                      SizedBox(height : 10),
                      customTextField(labelText : "상세 소개", controller : pcommentController, maxLines : 5),

                      Divider(color : AppColors.borderColor, height : 2),

                      SizedBox(height : 10),
                      Row(
                        mainAxisAlignment : MainAxisAlignment.spaceAround,
                        children : [
                          Text("프로젝트 시작일", style : TextStyle(fontSize : 18,),),
                          Text("프로젝트 마감일", style : TextStyle(fontSize : 18,),),
                        ],
                      ),
                      SizedBox(height : 10),
                      Row(
                        mainAxisAlignment : MainAxisAlignment.spaceBetween,
                        children : [
                          customTextField(labelText : "프로젝트 시작일", totalCheck : true, dateCheck : true, controller : pstartController),
                          customTextField(labelText : "프로젝트 마감일", totalCheck : true, dateCheck : true, controller : pendController),
                        ],
                      ),

                      Divider(color : AppColors.borderColor, height : 2),

                      SizedBox(height : 10),
                      Row(
                        mainAxisAlignment : MainAxisAlignment.spaceAround,
                        children : [
                          Text("모집 시작일", style : TextStyle(fontSize : 18,),),
                          Text("모집 마감일", style : TextStyle(fontSize : 18,),),
                        ],
                      ),
                      SizedBox(height : 10),
                      Row(
                        mainAxisAlignment : MainAxisAlignment.spaceBetween,
                        children : [
                          customTextField(labelText : "모집 시작일", totalCheck : true, dateCheck : true, controller : rpstartController),
                          customTextField(labelText : "모집 마감일", totalCheck : true, dateCheck : true, controller :rpendController),
                        ],
                      ),

                      Divider(color : AppColors.borderColor, height : 2),

                      SizedBox(height : 10),
                      Text("봉급", style : TextStyle(fontSize : 18,),),
                      SizedBox(height : 10),
                      customTextField(labelText : "봉급", controller : ppayController),
                      Row(
                        mainAxisAlignment : MainAxisAlignment.end,
                        children : [
                          ElevatedButton(
                            onPressed : () {
                              writeProject();
                            },
                            style : ElevatedButton.styleFrom(
                              backgroundColor : AppColors.buttonColor,
                            ),
                            child : Text("등록하기", style : TextStyle(color : AppColors.buttonTextColor,),),
                          ),
                        ],
                      ),

                    ],
                  ),
                ),
              ),
              // SizedBox(height : MediaQuery.of(context).size.height * 0.2,),
            ],
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