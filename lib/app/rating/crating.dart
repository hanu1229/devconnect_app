import 'package:devconnect_app/app/rating/crating_detail.dart';
import 'package:devconnect_app/style/app_colors.dart';
import 'package:devconnect_app/style/server_path.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Crating extends StatefulWidget{
  @override
  State<StatefulWidget> createState() {
    return _CratingState();
  }
} // c end

class _CratingState extends State<Crating>{
  int page = 1;
  List<dynamic> cRatingList = []; // 기업평가 리스트
  List<dynamic> projectList = []; // 프로젝트 리스트
  List<dynamic> companyList = []; // 기업 리스트
  final dio = Dio();

  final ScrollController scrollController = ScrollController();

  @override
  void initState() {
    onCratingAll( page  );
    scrollController.addListener( cOnScroll );
  } // iniState end

  // 자료요청
  void onCratingAll( int cPage  ) async {
    try{
      // 토큰 확인
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("token");
      if( token == null ){ print("권한이없습니다."); return; }
      dio.options.headers['Authorization'] = token;
      // 평가 조회
      final response1 = await dio.get("${serverPath}/api/crating?page=${cPage}" );
      // print(response1.data);

      // 프로젝트 조회
      final response2 = await dio.get("${serverPath}/api/project");
      // print( response2.data );

      // 기업 조회
      final response3 = await dio.get("${serverPath}/api/company/findall");
      // print( response3.data );

      // 페이지 변화
      setState(() {
        page = cPage;
        if( page == 1 ){
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
  } // onCratingAll end

  // 스크롤 추가
  void cOnScroll(){
    if( scrollController.position.pixels >= scrollController.position.maxScrollExtent - 150 ){
      onCratingAll( page +1 );
    } // if end
  } // cOnScroll end

  // 요청 ==========================================================================================================================
  @override
  Widget build(BuildContext context) {
    return ListView.builder(

        controller: scrollController,
        itemCount: cRatingList.length,
        itemBuilder: (context,index){
          // 각 index 번째 꺼내기
          final rating = cRatingList[index];
          final pno = rating['pno'];

          // pno로 프로젝트 찾기
          final project = projectList.firstWhere(
            (p) => p['pno'] == pno,
            orElse: () => null ,
          );

          // 프로젝트에서 cno 가져와서 기업 찾기
          final company = project != null ? companyList.firstWhere(
            (c) => c['cno'] == project['cno'],
            orElse: () => null ,
          ) : null;

          final images = company?['cprofile'];
          // 만약에 이미지가 존재하면 대표이미지 , 없으면 기본이미지 (default)
          String? imageUrl;
          if( images == null || images.isEmpty ){
            imageUrl = "${serverPath}/upload/default.jpg";
          }else{
            imageUrl = "${serverPath}/upload/${ images[0] }";
          }

          return InkWell(
            onTap: () => {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => CratingDetail(
                    crno: rating['crno'],
                    pno : project['pno'],
                    cname : company['cname'],
                    cprofile : company['cprofile']
                  ))
              )
            },
            child: Card(
              elevation: 7, // 그림자 깊이
              color: AppColors.bgColor,
              shadowColor: AppColors.textColor,
              shape: RoundedRectangleBorder( // borderRadius 보더 라운드
                borderRadius: BorderRadius.circular(8),
              ),
              margin: EdgeInsets.all( 15 ),
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: AppColors.borderColor2,),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Padding(
                  padding: EdgeInsets.only( left: 15 , right: 15 , top: 20, bottom: 20 ),
                  child: Row( // 가로배치
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [ // 가로배치위젯
                      Container(
                        width: 65, height: 65, // 사이즈
                        child: Image.network( // 웹 이미지 출력
                          imageUrl ,
                          fit: BoxFit.cover, // 이미지 비율 유지
                        ),
                      ),
                      SizedBox( width: 15 ,) , // 여백
                      Expanded(child: Column(
                        // mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text( rating['ctitle'] , style: TextStyle( fontSize: 20, fontWeight: FontWeight.bold), ),
                          // 별로 점수 나타내는 위젯
                          RatingBarIndicator(
                            rating: (rating['crscore'] ?? 0).toDouble(),
                            direction: Axis.horizontal,
                            itemCount: 5,
                            itemSize: 20, // 별 크기
                            // itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
                            itemBuilder: (context, _) => Icon(
                              Icons.star,
                              color: AppColors.buttonTextColor,
                            ),
                          ), // RatingBar.builder end
                          SizedBox( height: 12,),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Flexible(
                                child: Text(
                                  "기업명 : ${company['cname'] } " ,
                                  style: TextStyle(fontSize: 14,),
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
                                  "프로젝트명 : ${project['pname'] } " ,
                                  style: TextStyle(fontSize: 14,),
                                  softWrap: true,
                                  overflow: TextOverflow.visible,
                                ), // Text end
                              ), // Flexible end
                            ],
                          ), // Row end// Row end
                        ],
                      )) , // card 내부 추가할거면 여기
                    ],
                  ),
                ),
              ),
            ),
          );
        }
    );
  } // build end
} // c end