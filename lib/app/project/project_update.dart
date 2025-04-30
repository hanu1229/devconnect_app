// project_update.dart : 프로젝트 수정 페이지

import "package:devconnect_app/style/app_colors.dart";
import "package:dio/dio.dart";
import "package:flutter/material.dart";

class UpdateProject extends StatefulWidget {
  Map<String, dynamic> project = {};

  UpdateProject({super.key, required this.project});

  @override
  State<UpdateProject> createState() => _UpdateProjectState();

}

class _UpdateProjectState extends State<UpdateProject> {

  @override
  void initState() {
    super.initState();
    print(widget.project);
  }

  Widget customTextFieldUpdate({required String labelText, required TextEditingController? controller}) {
    return TextField(
      controller : controller,
      decoration : InputDecoration(
        labelText : labelText,
        border : OutlineInputBorder(borderSide : BorderSide(color : AppColors.borderColor, width : 1,),),
        enabledBorder : OutlineInputBorder(borderSide : BorderSide(color : AppColors.borderColor, width : 1,),),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    Dio dio = Dio();

    DateTime firstDate = DateTime(2000, 1, 1);
    DateTime lastDate = DateTime(2100, 12, 31);
    DateTime? newDate = DateTime(2025);

    List<String> ptypeList = ["전체", "백엔드", "프론트엔드"];
    String? ptypeValue;

    TextEditingController pnameController = TextEditingController();
    TextEditingController pintroController = TextEditingController();
    TextEditingController pcommentController = TextEditingController();
    TextEditingController pcountController = TextEditingController();
    TextEditingController pstartController = TextEditingController();
    TextEditingController pendController = TextEditingController();
    TextEditingController rpstartController = TextEditingController();
    TextEditingController rpendController = TextEditingController();
    TextEditingController ppayController = TextEditingController();

    return Scaffold(
      resizeToAvoidBottomInset : false,
      appBar : AppBar(
        title : Text("프로젝트 수정"),
      ),
      body : SingleChildScrollView(
        child : Container(
          padding : EdgeInsets.all(16),
          width : MediaQuery.of(context).size.width,
          child : Column(
            children : [
              SizedBox(
                width : MediaQuery.of(context).size.width,
                child: Card(
                  color : AppColors.bgColor,
                  child : Container(
                    padding : EdgeInsets.all(10),
                    child: Column(
                      crossAxisAlignment : CrossAxisAlignment.start,
                      children : [
                        Text("제목", style : TextStyle(fontFamily : "NanumGothic", fontSize : 28,),),
                        customTextFieldUpdate(labelText: "제목", controller: null),
                        Text("직무", style : TextStyle(fontFamily : "NanumGothic", fontSize : 28,),),
                        DropdownButtonFormField(
                          value : ptypeValue,
                          dropdownColor : Colors.white,
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
                        Text("모집 인원", style : TextStyle(fontFamily : "NanumGothic", fontSize : 28,),),
                        customTextFieldUpdate(labelText: "모집 인원", controller: null),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(height : 20),
              SizedBox(
                width : MediaQuery.of(context).size.width,
                child: Card(
                  color : AppColors.bgColor,
                  child : Container(
                    padding : EdgeInsets.all(10),
                    child: Column(
                      crossAxisAlignment : CrossAxisAlignment.start,
                      children : [
                        Text("프로젝트", style : TextStyle(fontFamily : "NanumGothic", fontSize : 28, fontWeight : FontWeight.bold),),
                        SizedBox(height : 20),
                        Text("시작일", style : TextStyle(fontFamily : "NanumGothic", fontSize : 28,),),
                        TextButton(
                          onPressed: () async {
                            DateTime? dateTime = await showDatePicker(
                              barrierDismissible : false,
                              initialDate : DateTime.now(),
                              context: context,
                              firstDate: firstDate,
                              lastDate: lastDate,
                            );
                            setState(() {
                              final dateSplit = dateTime.toString().split(" ");
                              pstartController.text = dateTime == null ? "" : dateSplit[0];
                            });
                          },
                          child: Text("시작일", style : TextStyle(fontFamily : "NanumGothic", fontSize : 28,),),
                        ),
                        Text("마감일", style : TextStyle(fontFamily : "NanumGothic", fontSize : 28,),),
                        TextButton(
                          onPressed: () async {
                            DateTime? dateTime = await showDatePicker(
                              barrierDismissible : false,
                              initialDate : DateTime.now(),
                              context: context,
                              firstDate: firstDate,
                              lastDate: lastDate,
                            );
                            setState(() {
                              final dateSplit = dateTime.toString().split(" ");
                              pstartController.text = dateTime == null ? "" : dateSplit[0];
                            });
                          },
                          child: Text("마감일", style : TextStyle(fontFamily : "NanumGothic", fontSize : 28,),),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(height : 20),
              SizedBox(
                width : MediaQuery.of(context).size.width,
                child: Card(
                  color : AppColors.bgColor,
                  child : Container(
                    padding : EdgeInsets.all(10),
                    child: Column(
                      crossAxisAlignment : CrossAxisAlignment.start,
                      children : [
                        Text("모집", style : TextStyle(fontFamily : "NanumGothic", fontSize : 28, fontWeight : FontWeight.bold),),
                        SizedBox(height : 20),
                        Text("시작일", style : TextStyle(fontFamily : "NanumGothic", fontSize : 28,),),
                        TextButton(
                          onPressed: () async {
                            DateTime? dateTime = await showDatePicker(
                              barrierDismissible : false,
                              initialDate : DateTime.now(),
                              context: context,
                              firstDate: firstDate,
                              lastDate: lastDate,
                            );
                            setState(() {
                              final dateSplit = dateTime.toString().split(" ");
                              pstartController.text = dateTime == null ? "" : dateSplit[0];
                            });
                          },
                          child: Text("시작일", style : TextStyle(fontFamily : "NanumGothic", fontSize : 28,),),
                        ),
                        Text("마감일", style : TextStyle(fontFamily : "NanumGothic", fontSize : 28,),),
                        TextButton(
                          onPressed: () async {
                            DateTime? dateTime = await showDatePicker(
                              barrierDismissible : false,
                              initialDate : DateTime.now(),
                              context: context,
                              firstDate: firstDate,
                              lastDate: lastDate,
                            );
                            setState(() {
                              final dateSplit = dateTime.toString().split(" ");
                              pstartController.text = dateTime == null ? "" : dateSplit[0];
                            });
                          },
                          child: Text("마감일", style : TextStyle(fontFamily : "NanumGothic", fontSize : 28,),),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(height : 20),
              SizedBox(
                width : MediaQuery.of(context).size.width,
                child: Card(
                  color : AppColors.bgColor,
                  child : Container(
                    padding : EdgeInsets.all(10),
                    child: Column(
                      crossAxisAlignment : CrossAxisAlignment.start,
                      children : [
                        Text("간단한 소개", style : TextStyle(fontFamily : "NanumGothic", fontSize : 28,),),
                        customTextFieldUpdate(labelText : "간단한 소개", controller : null),
                        Text("내용", style : TextStyle(fontFamily : "NanumGothic", fontSize : 28,),),
                        customTextFieldUpdate(labelText : "내용", controller : null),
                        Text("연봉", style : TextStyle(fontFamily : "NanumGothic", fontSize : 28,),),
                        customTextFieldUpdate(labelText : "연봉", controller : null),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(height : 20),
              SizedBox(
                width : MediaQuery.of(context).size.width,
                child : ElevatedButton(
                  onPressed: () {},
                  style : ElevatedButton.styleFrom(
                    backgroundColor : AppColors.buttonColor,
                  ),
                  child: Text("수정하기", style : TextStyle(fontSize : 20, color : AppColors.buttonTextColor)),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

}
