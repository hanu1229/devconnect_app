// project_detail.dart : 프로젝트 상세보기 페이지

import "package:devconnect_app/style/app_colors.dart";
import "package:flutter/material.dart";

class DetailProject extends StatefulWidget {
  int pno = 0;

  DetailProject({required int pno}) { this.pno = pno; }

  @override
  State<DetailProject> createState() => _DetailProjectState();

}

class _DetailProjectState extends State<DetailProject> {

  /// 서버에서 정보 가져오기 (토큰 필요)

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar : AppBar(title : Text("프로젝트 상세보기"),),
      body : Padding(
        padding: EdgeInsets.fromLTRB(16, 16, 16, 0),
        child : SingleChildScrollView(
          child : Expanded(
            child : Container(
              width : MediaQuery.of(context).size.width,
              child : Column(
                children : [
                  Text("프로젝트명"),
                  SizedBox(height : 10),
                  Text("회사명"),
                  SizedBox(height : 10),
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
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

}
