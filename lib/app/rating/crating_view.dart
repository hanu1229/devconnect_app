

import 'package:devconnect_app/app/rating/crating_detail.dart';
import 'package:devconnect_app/style/app_colors.dart';
import 'package:devconnect_app/style/server_path.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CratingView extends StatefulWidget{
  @override
  State<StatefulWidget> createState() {
    return _CratingViewState();
  } // createState end
} // c end

class _CratingViewState extends State<CratingView>{

  int page = 1;
  List<dynamic> cRatingList = []; // 기업평가 리스트
  List<dynamic> projectList = []; // 프로젝트 리스트
  List<dynamic> companyList = []; // 기업 리스트
  int dno = 1; // 나중에 개발자Info 페이지 에서 dno를 추출받기 / 여긴 임시로 1
  final dio = Dio();

  final ScrollController scrollController = ScrollController();

  // 1회 실행
  @override
  void initState() {
    onCratingMy( page , dno ); // 조회
    scrollController.addListener( cOnScroll );
  } // iniState end

  // 조회
  void onCratingMy( int cPage , int dno ) async {
    try{
      // 토큰 확인
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      // 토큰 유무 조건문
      if( token == null ) { print("권한이 없습니다."); return; }
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
          cRatingList = response1.data['content'];
          projectList = response2.data;
          companyList = response3.data;
        }else if( page > response1.data['totalPages'] ){
          page = response1.data['totalPages'];
        }else{
          cRatingList.addAll( response1.data['content'] );
          projectList = response2.data;
          companyList = response3.data;
        } // if end
        print( cRatingList );
        print( projectList );
        print( companyList );
      });
    }catch(e) { print( e ); }
  } // onCratingMy end

  void cOnScroll(){ // 스크롤이 정해둔 값에 도달하면 page 1 추가 = 새로운 데이터 부르기
    if( scrollController.position.pixels >= scrollController.position.maxScrollExtent - 150 ){
      onCratingMy( page +1  , dno );
    } // if end
  } // cOnScroll end

  // 요청 ==========================================================================================================================
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      controller: scrollController,
      itemCount: cRatingList.length,
      itemBuilder: (context , i ){
        final rating = cRatingList[i];
        // pno를 기업평가리스트에서 꺼내고 그걸로 pno 프로젝트 구별
        final pno = rating['pno'];

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

        // 이미지
        final images = company?['cprofile'];
        String? imageUrl;
        // 이미지 유무 확인 후 없으면 기본이미지 있으면 첫번째 이미지
        if( images == null || images.isEmpty ){
          imageUrl = "${serverPath}/upload/default.jpg";
        }else{
          imageUrl = "${serverPath}/upload/${ images[0] }";
        } // if end
        
        return InkWell( // 클릭시 이동
          onTap: () => {
            Navigator.push(context,
              MaterialPageRoute(
                builder: (context) => CratingDetail(
                  crno: rating['crno'],
                  pno : project['pno'],
                  cname: company['cname'],
                  cprofile: company['cprofile'],
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
        ); // InkWell end
      } // itemBuilder end
    ); // ListView end
  } // build end
} // c end