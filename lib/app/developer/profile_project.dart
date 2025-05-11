
import 'package:devconnect_app/app/component/custom_alert.dart';
import 'package:devconnect_app/app/component/custom_boolalert.dart';
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
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
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
  double updateValue = 0;
  int? pno = 0;
  Map<String,dynamic> company = {};

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
      final response = await dio.get("${serverPath}/api/project-join/findall?page=${page}&size=${size}");
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

  // 입력 컨트롤러
  TextEditingController titleController = TextEditingController();
  TextEditingController contentController = TextEditingController();

  // 평가 모달을 띄우는 메서드
  void showRatingDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return CustomAlertDialog(
          width: MediaQuery.of(context).size.width * 0.9,
          title: "평가 등록",
          btnTitle: "등록",
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                margin: EdgeInsets.only(bottom: 20),
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Color(0xfff1f1f1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                 child: Row(
                   children: [
                     SizedBox(width: 10),
                     Expanded(
                       child: Text(
                         "기업명: ${company["cname"] ?? "정보 없음"}",
                         style: TextStyle(
                           fontSize: 16,
                           fontWeight: FontWeight.w600,
                           color: Colors.black87,
                         ),
                       ),
                     ),
                   ],
                 ),
              ),
              Text("제목"),
              SizedBox(height: 10),
              CustomTextField(controller: titleController),
              SizedBox(height: 30),
              Text("내용"),
              SizedBox(height: 10),
              CustomTextField(controller: contentController, maxLines: 5),
              SizedBox(height: 20),
              Center(
                child: RatingBar(
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
          onPressed: () {
            Navigator.of(context).pop();
            ratingWrite();
          },
        );
      },
    );
  } // showRatingDialog end


  // 프로젝트 번호로 기업 정보 찾기 // Future = 비동기
  Future<void> getCno( pno ) async {
    try{
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("token");
      dio.options.headers["Authorization"] = token;
      final response = await dio.get("${serverPath}/api/project-join/getcno?pno=${pno}");
      if( response.data != null ){
        setState(() {
          company = response.data;
        });
      }
    }catch(e) { print( e ); }
  } // getCno end

  // 평가 등록 05-11 이민진 추가
  void ratingWrite() async {
    try{
      final sendData = {
        "ctitle": titleController.text,
        "ccontent": contentController.text,
        "crscore" : updateValue,
        "pno": pno,
        "dno": developer["dno"],
      };
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("token");
      dio.options.headers['Authorization'] = token;
      final response = await dio.post("${serverPath}/api/crating" , data: sendData );
      final data = response.data;
      if( data == true ) {
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
    }catch(e) { print( e ); }
  } // ratingWrite end

  @override
  Widget build(BuildContext context) {
    if (developer.isEmpty) {
      return Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Color(0xfffbfbfb),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            CustomMenuTabs(
              changePage: widget.changePage,
              selectedIndex: 9,
            ),
            SizedBox(height: 15),
            Text("참여한 프로젝트", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                itemCount: project.length + (isLoading ? 1 : 0),
                itemBuilder: (BuildContext context, int index) {
                  if (index < project.length) {
                    final data = project[index];
                    String pstart = data["pstart"].split("T")[0];
                    String pend = data["pend"].split("T")[0];
                    String rpstart = data["recruit_pstart"].split("T")[0];
                    String rpend = data["recruit_pend"].split("T")[0];
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => DetailProject(pno: data["pno"])),
                        );
                      },
                      onLongPress: () {
                        showModalBottomSheet(
                          context: context,
                          backgroundColor: Colors.transparent,
                          builder: (context) {
                            return SafeArea(
                              child: Container(
                                margin: EdgeInsets.all(16),
                                height: 125,
                                width: MediaQuery.of(context).size.width,
                                decoration: BoxDecoration(
                                  color: AppColors.bgColor,
                                  borderRadius: BorderRadius.all(Radius.circular(16)),
                                ),
                                child: Padding(
                                  padding: EdgeInsets.symmetric(vertical: 16),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                                    children: [
                                      Container(
                                        padding: EdgeInsets.symmetric(horizontal: 16),
                                        width: double.infinity,
                                        child: ElevatedButton(
                                          onPressed: () async {
                                            Navigator.pop(context);
                                            setState(() {
                                              pno = project[index]["pno"];
                                            });
                                            if (pno != null) {
                                              await getCno(pno);
                                            }
                                            showRatingDialog();
                                          },
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: AppColors.ratingbtnColor,
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(12),
                                            ),
                                          ),
                                          child: Text("평가하기",
                                              style: TextStyle(
                                                  color: AppColors.buttonTextColor,
                                                  fontSize: 20)),
                                        ),
                                      ),
                                      Container(
                                        padding: EdgeInsets.symmetric(horizontal: 16),
                                        width: double.infinity,
                                        child: ElevatedButton(
                                          onPressed: () {
                                            Navigator.pop(context);
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      DetailProject(pno: data["pno"])),
                                            );
                                          },
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: AppColors.buttonColor,
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(12),
                                            ),
                                          ),
                                          child: Text("상세보기",
                                              style: TextStyle(
                                                  color: AppColors.buttonTextColor,
                                                  fontSize: 20)),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        );
                      },
                      child: Padding(
                        padding: EdgeInsets.only(left: 16, top: 16, right: 16),
                        child: Card(
                          color: AppColors.bgColor,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                            side: BorderSide(color: Color(0xFFD9D9D9), width: 1),
                          ),
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 10),
                            child: ListTile(
                              title: Text(
                                "${data["pname"]}",
                                style: TextStyle(
                                  fontFamily: "NanumGothic",
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(height: 10),
                                  Text("소개 : ${data["pintro"]}"),
                                  SizedBox(height: 5),
                                  Text("모집 인원 : ${data["pcount"]}"),
                                  SizedBox(height: 5),
                                  Text("프로젝트 기간 : $pstart ~ $pend"),
                                  SizedBox(height: 5),
                                  Text("모집 기간 : $rpstart ~ $rpend"),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  } else {
                    return Padding(
                      padding: EdgeInsets.all(16),
                      child: Center(
                        child: CircularProgressIndicator(),
                      ),
                    );
                  }
                },
              ),
            ),
            SizedBox(height: 30),
            SizedBox(height: 50 + MediaQuery.of(context).padding.bottom),
          ],
        ),
      ),
    );
  }
}