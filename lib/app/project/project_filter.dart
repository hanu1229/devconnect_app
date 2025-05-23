// project_filter.dart : 프로젝트 필터 적용 페이지

import 'package:devconnect_app/app/component/custom_card.dart';
import 'package:devconnect_app/style/app_colors.dart';
import 'package:flutter/material.dart';

class ProjectFilter extends StatefulWidget {

  // 직무 필터 선택값
  int? ptypeValue = 0;
  // 모집 상태 필터 선택값
  int? rstatusValue = 0;

  ProjectFilter({required this.rstatusValue, required this.ptypeValue});

  @override
  State<ProjectFilter> createState() => _ProjectFilterState();

}

class _ProjectFilterState extends State<ProjectFilter> {

  // 모집 상태 필터 선택값
  // int? rstatusValue = 0;
  // 직무 필터 선택값
  // int? ptypeValue = 0;

  TextEditingController keywordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar : AppBar(title : Text("검색 필터")),
      body : Padding(
        padding: const EdgeInsets.symmetric(horizontal : 8.0, vertical : 16.0),
        child: Column(
          children : [
            CustomCard(
              elevation : 0,
              child : Column(
                children : [
                  // 검색창
                  Row(
                    children : [
                      SizedBox(
                        width : 100,
                        child : Text("검색 : ", style : TextStyle(fontSize : 16, fontWeight : FontWeight.bold)),
                      ),
                      Expanded(
                        child: TextField(
                          controller : keywordController,
                          decoration : InputDecoration(
                            hintText : "검색...",
                            border : OutlineInputBorder(borderSide : BorderSide(color : AppColors.borderColor, width : 1,),),
                            enabledBorder : OutlineInputBorder(borderSide : BorderSide(color : AppColors.borderColor, width : 1,),),
                            focusedBorder : OutlineInputBorder(borderSide : BorderSide(color : AppColors.focusColor, width : 1),),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height : 10),
                  // 모집 여부 필터
                  Row(
                    children : [
                      SizedBox(
                        width : 100,
                        child : Text("모집 여부 : ", style : TextStyle(fontSize : 16, fontWeight : FontWeight.bold)),
                      ),
                      Expanded(
                        child: Container(
                          // width : MediaQuery.of(context).size.width * 0.35,
                          decoration : BoxDecoration(
                            borderRadius : BorderRadius.circular(6),
                            border : Border.all(color : Colors.black, width : 1),
                          ),
                          child: DropdownButton(
                            padding : EdgeInsets.symmetric(horizontal : 8),
                            isExpanded : true,
                            // 테두리가 없어서 대체로 사용
                            elevation : 9,
                            dropdownColor : Colors.white,
                            value : widget.rstatusValue,
                            onChanged: (value) { setState(() { widget.rstatusValue = value; }); },
                            underline : SizedBox.shrink(),
                            items: [
                              DropdownMenuItem(value : 0, child : Text("전체", overflow : TextOverflow.ellipsis,),),
                              DropdownMenuItem(value : 1, child : Text("모집 전", overflow : TextOverflow.ellipsis,),),
                              DropdownMenuItem(value : 2, child : Text("모집 중", overflow : TextOverflow.ellipsis,),),
                              DropdownMenuItem(value : 3, child : Text("모집 완료", overflow : TextOverflow.ellipsis,),),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height : 10),
                  // 직무 필터
                  Row(
                    children : [
                      SizedBox(
                        width : 100,
                        child : Text("직무 : ", style : TextStyle(fontSize : 16, fontWeight : FontWeight.bold)),
                      ),
                      Expanded(
                        child: Container(
                          // width : MediaQuery.of(context).size.width * 0.35,
                          decoration : BoxDecoration(
                            borderRadius : BorderRadius.circular(6),
                            border : Border.all(color : Colors.black, width : 1),
                          ),
                          child: DropdownButton(
                            padding : EdgeInsets.symmetric(horizontal : 8),
                            isExpanded : true,
                            // 테두리가 없어서 대체로 사용
                            elevation : 9,
                            dropdownColor : Colors.white,
                            value : widget.ptypeValue,
                            onChanged: (value) { setState(() { widget.ptypeValue = value; }); },
                            underline : SizedBox.shrink(),
                            items: [
                              DropdownMenuItem(value : 0, child : Text("전체", overflow : TextOverflow.ellipsis,),),
                              DropdownMenuItem(value : 1, child : Text("백엔드", overflow : TextOverflow.ellipsis,),),
                              DropdownMenuItem(value : 2, child : Text("프론트엔드", overflow : TextOverflow.ellipsis,),),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height : 10),
                  // 검색 버튼
                  Row(
                    mainAxisAlignment : MainAxisAlignment.end,
                    children: [
                      ElevatedButton(
                        onPressed : () {
                          print(">> rstatusValue : $widget.rstatusValue");
                          print(">> ptypeValue : $widget.ptypeValue");
                          // page = 0;
                          // scrollUp = true;
                          // searchClick = true;
                          // findData();
                          final filterData = {"rstatusValue" : widget.rstatusValue, "ptypeValue" : widget.ptypeValue, "keyword" : keywordController.text, "status" : true};
                          print(">> filterData : $filterData");
                          Navigator.pop(context, filterData);
                        },
                        style : ElevatedButton.styleFrom(
                          shape : RoundedRectangleBorder(borderRadius : BorderRadius.circular(6),),
                          backgroundColor : AppColors.buttonColor,
                        ),
                        child : Text("검색", style : TextStyle(fontSize : 18, color : AppColors.buttonTextColor,),),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

}
