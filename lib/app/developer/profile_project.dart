
import 'package:devconnect_app/app/component/custom_card.dart';
import 'package:devconnect_app/app/component/custom_imgpicker.dart';
import 'package:devconnect_app/app/component/custom_menutabs.dart';
import 'package:devconnect_app/app/component/custom_outlinebutton.dart';
import 'package:devconnect_app/app/component/custom_scrollview.dart';
import 'package:devconnect_app/app/component/custom_textbutton.dart';
import 'package:devconnect_app/app/component/custom_textfield.dart';
import 'package:devconnect_app/app/project/project_detail.dart';
import 'package:devconnect_app/style/app_colors.dart';
import 'package:devconnect_app/style/server_path.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Profile_Project extends StatefulWidget{
  final Function(int) changePage;

  const Profile_Project({
    required this.changePage,
  });

  @override
  _Profile_Project createState() {
    return _Profile_Project();
  }
}

class _Profile_Project extends State< Profile_Project >{
  Dio dio = Dio();

  // 상태변수
  int page = 1;
  int size = 5;
  XFile? profileImage;
  String? profileImageUrl;
  // 로딩 확인 변수
  bool isLoading = false;
  // 빈 데이터가 오는지 확인하는 변수
  bool hasNext = true;

  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    loginCheck();
    findData();
    // 스크롤 이벤트 등록
    _scrollController.addListener(() {
      if(_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 30) {
        // 스크롤 끝에 도달하면 추가 데이터 불러오기
        if(hasNext && !isLoading) { findData(); }
      }
    });
  }

  // 로그인 상태 확인
  bool? isLogIn;

  void loginCheck() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if( token != null && token.isNotEmpty ){
      setState(() {
        isLogIn = true; print("로그인 중");
        onInfo( token );
      });
    }else{
      // Navigator.pushReplacement( context, MaterialPageRoute(builder: ( context ) =>  ) )
    }
  } // f end

  // 회원정보 가져오기
  Map<String, dynamic> developer = {};

  void onInfo( token ) async {
    try{
      dio.options.headers['Authorization'] = token;
      final response = await dio.get("${serverPath}/api/developer/info");
      final data = response.data;
      if( data != '' ){
        setState(() {
          developer = data;
          profileImageUrl = data['dprofile'];
        });
      }
    }catch( e ){ print( e ); }
  } // f end

  List< dynamic > paging = [];
  List< dynamic > project = [];

  Future<void> findData() async {
    // 중복 호출 방지
    if(isLoading || !hasNext) { return; }
    setState(() { isLoading = true; });
    try {
      // 테스트를 위한 딜레이
      await Future.delayed(Duration(seconds: 2));

      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      // 필요한 정보만 가져오기
      dio.options.headers['Authorization'] = token;
      final response = await dio.get("${serverPath}/api/project_join/findall?page=${page}&size=${size}");
      final data = response.data;

      final List<dynamic> contentData = data['content'];

      // content 내부의 project만 추출해서 리스트로 만들기
      final List<dynamic> projectList = contentData.map((item) {
        final proj = item["project"];
        proj["pjno"] = item["pjno"];
        proj["pjtype"] = item["pjtype"];
        proj["dno"] = item["dno"];
        return proj;
      }).toList();

      print(projectList);
      if(projectList.length < size) { hasNext = false; }
      setState(() {
        project.addAll(projectList);
        // 페이지 증가
        page += 1;
      });
    } catch(e) {
      print(e);
    } finally {
      setState(() { isLoading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {

    if( developer.isEmpty ){ return Center( child: CircularProgressIndicator(), ); }

    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Color( 0xfffbfbfb ),
      body: Padding(
        padding: EdgeInsets.all( 20 ),
        child: Column(
          children: [
            CustomMenuTabs(
              changePage: widget.changePage,
              selectedIndex: 9,
            ),

            SizedBox( height: 15 ,),
            Text("참여한 프로젝트", style: TextStyle( fontSize: 18, fontWeight: FontWeight.bold, ), ),
            SizedBox( height: 10 ,),

            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                itemCount : project.length + (isLoading ? 1 : 0),
                itemBuilder : (BuildContext context, int index) {
                  if(index < project.length) {
                    final data = project[index];
                    String pstart = data["pstart"].split("T")[0];
                    String pend = data["pend"].split("T")[0];
                    String rpstart = data["recruit_pstart"].split("T")[0];
                    String rpend = data["recruit_pend"].split("T")[0];
                    return GestureDetector(
                      onTap : () {
                        // 프로젝트 상세보기 페이지로 넘어감
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder : (context) => DetailProject(pno : data["pno"])),
                        );
                      },
                      child : Padding(
                        padding : EdgeInsets.only(left : 16, top : 16, right : 16),
                        child : Card(
                          color : AppColors.bgColor,
                          elevation : 0,
                          shape : RoundedRectangleBorder(
                            borderRadius : BorderRadius.circular(10),
                            side : BorderSide(color : Color(0xFFD9D9D9), width : 1,),
                          ),
                          child : Padding(
                            padding : EdgeInsets.symmetric(vertical : 10),
                            child : ListTile(
                              title : Text(
                                "${data["pname"]}",
                                style : TextStyle(
                                  fontFamily : "NanumGothic",
                                  fontSize : 20,
                                  fontWeight : FontWeight.bold,
                                ),
                              ),
                              subtitle: Column(
                                mainAxisAlignment : MainAxisAlignment.start,
                                crossAxisAlignment : CrossAxisAlignment.start,
                                children : [
                                  SizedBox(height : 10),
                                  Text("소개 : ${data["pintro"]}"),
                                  SizedBox(height : 5),
                                  Text("모집 인원 : ${data["pcount"]}"),
                                  SizedBox(height : 5),
                                  Text("프로젝트 기간 : $pstart ~ $pend"),
                                  SizedBox(height : 5),
                                  Text("모집 기간 : $rpstart ~ $rpend")
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  } else {
                    return Padding(
                      padding : EdgeInsets.all(16),
                      child : Center(
                        child : CircularProgressIndicator(),
                      ),
                    );
                  }
                },
              ),
            ),
            SizedBox( height: 30,),

            SizedBox(height: 50 + MediaQuery.of(context).padding.bottom),

          ],
        ),
      ),
    );
  }
}