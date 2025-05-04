

import 'package:devconnect_app/app/rating/rating_detail.dart';
import 'package:devconnect_app/style/app_colors.dart';
import 'package:devconnect_app/style/server_path.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class RatingView extends StatefulWidget{
  @override
  State<StatefulWidget> createState() {
    return _RatingViewState();
  } // createState end
} // c end

class _RatingViewState extends State<RatingView>{

  int page = 1;
  String? token; // 토큰 상태필드
  String? tokenrole; // role 이름
  List<dynamic> ratingList = []; // 기업평가 리스트
  List<dynamic> projectList = []; // 프로젝트 리스트
  List<dynamic> companyList = []; // 기업 리스트
  List<dynamic> developerList = []; // 개발자 리스트
  int dno = 1; // 나중에 개발자Info 페이지 에서 dno를 추출받기 / 여긴 임시로 1
  final dio = Dio();

  final ScrollController scrollController = ScrollController();

  // 1회 실행
  @override
  void initState() {
    whyToken();
    scrollController.addListener( cOnScroll );
  } // iniState end

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
    // 토큰에 따른 데이터 요청
    if( role == "Company" ){
      onDratingMy(page,dno);
    }else if( role == "Developer" ){
      onCratingMy(page,dno);
    } // if end
    tokenrole = role;
  } // whyToken end

  // 자료요청( 로그인한 개발자가 쓴 평가들 )
  void onCratingMy( int cPage , int dno ) async {
    try{
      dio.options.headers['Authorization'] = token;
      // 평가 조회
      final response1 = await dio.get("${serverPath}/api/crating?page=${cPage}&dno=${dno}");
      // 프로젝트 조회
      final response2 = await dio.get("${serverPath}/api/project");
      // 기업 조회
      final response3 = await dio.get("${serverPath}/api/company/findall");
      // 페이지 변화
      setState(() {
        page = cPage;
        if( page == 1){
          ratingList = response1.data['content'];
          projectList = response2.data;
          companyList = response3.data;
        }else if( page > response1.data['totalPages'] ){
          page = response1.data['totalPages'];
        }else{
          ratingList.addAll( response1.data['content'] );
          projectList = response2.data;
          companyList = response3.data;
        } // if end
        print( ratingList );
        print( projectList );
        print( companyList );
      });
    }catch(e) { print( e ); }
  } // onCratingMy end

  // 자료요청( 로그인한 기업가 쓴 평가들 )
  void onDratingMy( int dPage , int dno ) async {
    try{
      dio.options.headers['Authorization'] = token;
      // 개발자 평가 조회
      final response1 = await dio.get("${serverPath}/api/drating?page=${dPage}&dno=${dno}");
      // 프로젝트 조회
      final response2 = await dio.get("${serverPath}/api/project");
      // 기업 조회
      final response3 = await dio.get("${serverPath}/api/company/findall");
      // 개발자 조회
      final response4 = await dio.get("${serverPath}/api/developer/findall");

      // 페이지 변화
      setState(() {
        page = dPage;
        if( page == 1 ) {
          ratingList = response1.data['content'];
          projectList = response2.data;
          companyList = response3.data;
          developerList = response4.data;
        }else if ( page > response1.data['totalPages'] ){
          page = response1.data['totalPages'];
        }else{
          ratingList.addAll( response1.data['content'] );
          projectList = response2.data;
          companyList = response3.data;
          developerList = response4.data;
        } // if end
        print( ratingList );
        print( projectList );
        print( companyList );
        print( developerList );
      });
    }catch(e) { print( e ); }
  } // onDratingAll end

  void cOnScroll(){ // 스크롤이 정해둔 값에 도달하면 page 1 추가 = 새로운 데이터 부르기
    if( scrollController.position.pixels >= scrollController.position.maxScrollExtent - 150 ){
      if( tokenrole == "Developer"){
        onCratingMy( page+1, dno );
      }else if( tokenrole == "Company"){
        onDratingMy( page +1  , dno );
      } // if end
    } // if end
  } // cOnScroll end

  // 요청 ==========================================================================================================================
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      controller: scrollController,
      itemCount: ratingList.length,
      itemBuilder: (context , i ){
        final rating = ratingList[i];
        // pno를 기업평가리스트에서 꺼내고 그걸로 pno 프로젝트 구별
        final pno = rating['pno'];
        final dno = rating['dno'];

        // pno로 프로젝트 찾기
        final project = projectList.firstWhere(
          (p) => p['pno'] == pno,
          orElse: () => null,
        );

        // pno로 구별한 project에서 cno 찾아서 기업 리스트 에서 구별
        final company = project != null ? companyList.firstWhere(
          (cno) => cno['cno'] == project['cno'],
          orElse:  () => null,
        ) : null;

        // dno로 개발자 찾기
        final developer = developerList.firstWhere(
              (d) => d['dno'] == dno,
          orElse: () => null,
        );

        String? imageUrl;
        // 이미지
        if( tokenrole == "Developer" ) {
          // if( project == null || company == null || developer == null ){
          //   return SizedBox(); // 빈공간 출력
          // } // if end
          final images = company?['cprofile'];
          // 이미지 유무 확인 후 없으면 기본이미지 있으면 첫번째 이미지
          if (images == null || images.isEmpty) {
            imageUrl = "${serverPath}/upload/default.jpg";
          } else {
            imageUrl = "${serverPath}/upload/${ images[0] }";
          } // if end
          return InkWell( // 클릭시 이동
            onTap: () => {
              Navigator.push(context,
                  MaterialPageRoute(
                      builder: (context) => RatingDetail(
                        crno: rating['crno'],
                        pno : project['pno'],
                        cname: company['cname'],
                        profile: company['cprofile'],
                        dname: developer['dname'],
                      ) // builder end
                  ) // MaterialPageRoute end
              ) // Navigator end
            }, // onTap end
            child: Card(
              elevation: 7, // 그림자 깊이
              color: AppColors.bgColor, // background-color
              shadowColor: AppColors.textColor, // 그림자 색상
              shape: RoundedRectangleBorder( // border-radius
                borderRadius: BorderRadius.circular(8),
              ),
              margin: EdgeInsets.all( 15 ),
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: AppColors.borderColor2,
                  ), // Border.all end
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Padding(
                  padding: EdgeInsets.only( left: 15 , right: 15 , top: 20, bottom: 20 ),
                  child: Row( // 가로배치
                    crossAxisAlignment: CrossAxisAlignment.start, // 이미지 위로 올림
                    children: [ // 가로배치할 위젯
                      Container(
                        width: 65, height: 65, // 사이즈,
                        child: Image.network( // 웹 이미지 출력
                          imageUrl,
                          fit: BoxFit.cover, // 이미지 비율 유지
                        ),
                      ),
                      SizedBox( width: 15,), // 여백
                      Expanded(child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text( rating['ctitle'] , style: TextStyle( fontSize: 20 , fontWeight: FontWeight.bold ), ),
                          // 별로 점수 나타내는 위젯
                          RatingBarIndicator(
                            rating: (rating['crscore'] ?? 0).toDouble(),
                            direction: Axis.horizontal,
                            itemCount: 5,
                            itemSize: 20, // 별 크기
                            // itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
                            itemBuilder: (context, _) => Icon(
                              Icons.star,
                              color: AppColors.ratingTextColor,
                            ),
                          ), // RatingBar.builder end
                          SizedBox( height: 12,),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Flexible(
                                child: Text(
                                  "기업명 : ${company['cname'] }" ,
                                  style: TextStyle(fontSize:  14 ),
                                  softWrap: true,
                                  overflow: TextOverflow.visible,
                                ), // Text end
                              ), // Flexible end
                            ],
                          ), // Row end
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Flexible(
                                child: Text(
                                  "프로젝트명 : ${project['pname'] }" ,
                                  style: TextStyle(fontSize:  14 ),
                                  softWrap: true,
                                  overflow: TextOverflow.visible,
                                ), // Text end
                              ), // Flexible end
                            ],
                          ), // Row end
                        ],
                      )) , // card 내부 추가할거면 이곳 이후
                    ],
                  ), // Row end
                ), // Padding end// BoxDecorating end
              ), // Container end
            ), // Card end
          );
        }else if( tokenrole == "Company" ){
          // if( project == null || company == null || developer == null ){
          //   return SizedBox(); // 빈공간 출력
          // } // if end
          final images = developer?['dprofile'];
          // 이미지 유무 확인 후 없으면 기본이미지 있으면 첫번째 이미지
          if (images == null || images.isEmpty) {
            imageUrl = "${serverPath}/upload/default.jpg";
          } else {
            imageUrl = "${serverPath}/upload/${ images[0] }";
          } // if end
          return InkWell( // 클릭시 이동
            onTap: () => {
              Navigator.push(context,
                  MaterialPageRoute(
                      builder: (context) => RatingDetail(
                        crno: rating['crno'],
                        pno : project['pno'],
                        cname: company['cname'],
                        profile: developer['dprofile'],
                      ) // builder end
                  ) // MaterialPageRoute end
              ) // Navigator end
            }, // onTap end
            child: Card(
              elevation: 7, // 그림자 깊이
              color: AppColors.bgColor, // background-color
              shadowColor: AppColors.textColor, // 그림자 색상
              shape: RoundedRectangleBorder( // border-radius
                borderRadius: BorderRadius.circular(8),
              ),
              margin: EdgeInsets.all( 15 ),
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: AppColors.borderColor2,
                  ), // Border.all end
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Padding(
                  padding: EdgeInsets.only( left: 15 , right: 15 , top: 20, bottom: 20 ),
                  child: Row( // 가로배치
                    crossAxisAlignment: CrossAxisAlignment.start, // 이미지 위로 올림
                    children: [ // 가로배치할 위젯
                      Container(
                        width: 65, height: 65, // 사이즈,
                        child: Image.network( // 웹 이미지 출력
                          imageUrl,
                          fit: BoxFit.cover, // 이미지 비율 유지
                        ),
                      ),
                      SizedBox( width: 15,), // 여백
                      Expanded(child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text( rating['dtitle'] , style: TextStyle( fontSize: 20 , fontWeight: FontWeight.bold ), ),
                          // 별로 점수 나타내는 위젯
                          RatingBarIndicator(
                            rating: (rating['drscore'] ?? 0).toDouble(),
                            direction: Axis.horizontal,
                            itemCount: 5,
                            itemSize: 20, // 별 크기
                            // itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
                            itemBuilder: (context, _) => Icon(
                              Icons.star,
                              color: AppColors.ratingTextColor,
                            ),
                          ), // RatingBar.builder end
                          SizedBox( height: 12,),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Flexible(
                                child: Text(
                                  "개발자명 : ${developer['dname'] }" ,
                                  style: TextStyle(fontSize:  14 ),
                                  softWrap: true,
                                  overflow: TextOverflow.visible,
                                ), // Text end
                              ), // Flexible end
                            ],
                          ), // Row end
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Flexible(
                                child: Text(
                                  "프로젝트명 : ${project['pname'] }" ,
                                  style: TextStyle(fontSize:  14 ),
                                  softWrap: true,
                                  overflow: TextOverflow.visible,
                                ), // Text end
                              ), // Flexible end
                            ],
                          ), // Row end
                        ],
                      )) , // card 내부 추가할거면 이곳 이후
                    ],
                  ), // Row end
                ), // Padding end// BoxDecorating end
              ), // Container end
            ), // Card end
          );
        }
      } // itemBuilder end
    ); // ListView end
  } // build end
} // c end