
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

  Map<String, Object> dList = {};

  void onInfo( token ) async {
    try{
      dio.options.headers['Authorization'] = token;
      final response = await dio.get( path + "/info" );
      final data = response.data;
      if( data != '' ){
        setState(() {

        });
      }
    }catch( e ){ print( e ); }
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

                    Text("기본 정보",
                      style: TextStyle(
                        fontFamily: "NanumGothic",
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    SizedBox( height: 20 ,),

                    SizedBox(
                      height: 300,
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
                        child: Padding(
                          padding: EdgeInsets.all( 20 ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("아이디"),

                              SizedBox( height: 12,),

                              TextField(
                                decoration: InputDecoration(
                                  filled: true,
                                  fillColor: Color(0xfffbfbfb),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular( 12 ),
                                    borderSide: BorderSide(
                                      width: 1.5,
                                      color: Color(0xffd5dae1),
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular( 12 ),
                                    borderSide: BorderSide(
                                      width: 2.5,
                                      color: Color(0xffa5adba),
                                    )
                                  ),
                                ),
                              ),

                              SizedBox( height: 12,),

                              Text("이메일"),

                              SizedBox( height: 12,),

                              TextField(
                                decoration: InputDecoration(
                                  filled: true,
                                  fillColor: Color(0xfffbfbfb),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular( 12 ),
                                    borderSide: BorderSide(
                                      width: 1.5,
                                      color: Color(0xffd5dae1),
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular( 12 ),
                                      borderSide: BorderSide(
                                        width: 2.5,
                                        color: Color(0xffa5adba),
                                      )
                                  ),
                                ),
                              ),

                            ],
                          ),
                        )
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
