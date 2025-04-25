
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

String path = "http://localhost:8080/api/developer";

class Profile extends StatefulWidget{
  @override
  _ProfileState createState() {
    return _ProfileState();
  }
}

class _ProfileState extends State< Profile >{

  @override
  void initState() {

  } // f end

  Dio dio = Dio();

  // List< Map<String, Object> > = dList;

  void findByBno() async {
    final response = await dio.get( path + "/info" );
    final data = response.data;
    if( data != null ){

    }
  } // f end

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: MediaQuery.of( context ).size.height,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: EdgeInsets.all( 20 ),
                color: Color(0xfffbfbfb),
                width: double.infinity,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("계정 관리",
                      style: TextStyle(
                        fontFamily: "NanumGothic",
                        fontSize: 23,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    SizedBox( height: 20 ,),

                    Text("기본 정보",
                      style: TextStyle(
                        fontFamily: "NanumGothic",
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    SizedBox( height: 20 ,),

                    SizedBox(
                      height: 200,
                      width: double.infinity,
                      child: Card(
                        shape: RoundedRectangleBorder(
                          borderRadius:
                          BorderRadius.circular(12),
                          side: BorderSide(
                            width: 1,
                            color: Color(0xffccdbe3),
                          ),
                        ),
                        elevation: 0,
                        color: Colors.white,
                      ),
                    ),

                    SizedBox( height: 20,),

                    SizedBox(
                      height: 200,
                      width: double.infinity,
                      child: Card(
                        shape: RoundedRectangleBorder(
                          borderRadius:
                          BorderRadius.circular(12),
                          side: BorderSide(
                            width: 1,
                            color: Color(0xffccdbe3),
                          ),
                        ),
                        elevation: 0,
                        color: Colors.white,
                      ),
                    ),

                    SizedBox( height: 20,),

                    SizedBox(
                      height: 200,
                      width: double.infinity,
                      child: Card(
                        shape: RoundedRectangleBorder(
                          borderRadius:
                          BorderRadius.circular(12),
                          side: BorderSide(
                            width: 1,
                            color: Color(0xffccdbe3),
                          ),
                        ),
                        elevation: 0,
                        color: Colors.white,
                      ),
                    ),

                    SizedBox( height: 90 ,),

                  ],
                )
              ),
            ],
          ),
        ),
      )
    );
  }
}
