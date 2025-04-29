import 'package:devconnect_app/app/component/custombottombar.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Rating extends StatefulWidget{
  @override
  State<StatefulWidget> createState() {
    return _RatingState();
  }
} // c end

class _RatingState extends State<Rating>{
  int page = 1;
  List<dynamic> cRatingList = [];
  final dio = Dio();
  int loginDno = 1;
  String baseUrl = "http://localhost:8080";

  final ScrollController scrollController = ScrollController();

  @override
  void initState() {
    onCratingAll( page , loginDno );
    scrollController.addListener( cOnScroll );
  } // iniState end

  // 자료요청
  void onCratingAll( int cPage , int loginDno ) async {
    try{
      final response = await dio.get("${baseUrl}/api/crating?page=${cPage}&loginDno=${loginDno}" );
      setState(() {
        page = cPage;
        if( page == 1 ){
          cRatingList = response.data['content'];
        }else if( page > response.data['totalPages'] ){
          page = response.data['totalPages'];
        }else{
          cRatingList.addAll( response.data['content'] );
        } // if end
        print( cRatingList );
        print( response.data );
      });
    }catch(e) { print( e ); }
  } // onCratingAll end

  // 스크롤 추가
  void cOnScroll(){
    if( scrollController.position.pixels >= scrollController.position.maxScrollExtent - 150 ){
      onCratingAll( page +1 , loginDno );
    } // if end
  } // cOnScroll end

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("평가 페이지"),
      ),
    );
  } // build end
} // c end