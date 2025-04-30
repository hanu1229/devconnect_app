// project_update.dart : 프로젝트 수정 페이지

import "package:devconnect_app/style/app_colors.dart";
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                        Text("제목", style : TextStyle(fontFamily : "NanumGothic", fontSize : 28,)),
                        TextField(
                          controller : null,
                          decoration : InputDecoration(
                            border : OutlineInputBorder(borderSide : BorderSide(color : AppColors.borderColor, width : 1,),),
                            enabledBorder : OutlineInputBorder(borderSide : BorderSide(color : AppColors.borderColor, width : 1,),),
                          ),
                        ),
                        Text("타입"),
                        Text("모집 인원"),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(
                width : MediaQuery.of(context).size.width,
                child: Card(
                  color : AppColors.bgColor,
                  child : Container(
                    padding : EdgeInsets.all(10),
                    child: Column(
                      children : [
                        Text("프로젝트 시작일"),
                        Text("프로젝트 마감일"),
                        Text("모집 시작일"),
                        Text("모집 마감일"),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(
                width : MediaQuery.of(context).size.width,
                child: Card(
                  color : AppColors.bgColor,
                  child : Container(
                    padding : EdgeInsets.all(10),
                    child: Column(
                      children : [
                        Text("간단한 소개"),
                        Text("내용"),
                        Text("연봉"),
                      ],
                    ),
                  ),
                ),
              ),

            ],
          ),
        ),
      ),
    );
  }

}
