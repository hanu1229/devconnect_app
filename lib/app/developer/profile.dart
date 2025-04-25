import 'package:devconnect_app/style/app_colors.dart';
import 'package:flutter/material.dart';

class Profile extends StatefulWidget{
  @override
  _ProfileState createState() {
    return _ProfileState();
  }
}

class _ProfileState extends State< Profile >{
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
                padding: EdgeInsets.all( 10 ),
                color: Color(0xfff2f2f2),
                width: double.infinity,
                child: Column(
                  children: [
                    Text("계정 관리",style: TextStyle(
                      fontSize: 23,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.left,
                    ),
                    Text("기본 정보",style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),),
                    SizedBox(
                      height: 200,
                      width: double.infinity,
                      child: Card(
                        shape: RoundedRectangleBorder(
                          borderRadius:
                            BorderRadius.circular(12),
                          side: BorderSide( width: 1, color: Colors.grey ),
                        ),
                        elevation: 4,
                        color: Colors.white,
                      ),
                    ),
                    Card(
                      color: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular( 12 ),
                      ),
                      child: Container(
                        height: 200,
                        width: double.infinity,
                        child: Column(
                          children: [
                            Text('아이디'),
                            SizedBox( height: 10, ),
                            Text('내정보 변경'),
                          ],
                        ),
                      ),
                    ),

                    SizedBox( height: 5,),

                    Card(
                      color: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular( 12 ),
                      ),
                      child: Container(
                        height: 200,
                        width: double.infinity,
                        child: Column(
                          children: [
                            Text('아이디'),
                            SizedBox( height: 10, ),
                            Text('내정보 변경'),
                          ],
                        ),
                      ),
                    ),

                    SizedBox( height: 5,),

                    Card(
                      color: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular( 12 ),
                      ),
                      child: Container(
                        height: 200,
                        width: double.infinity,
                        child: Column(
                          children: [
                            Text('아이디'),
                            SizedBox( height: 10, ),
                            Text('내정보 변경'),
                          ],
                        ),
                      ),
                    ),

                    SizedBox(height : 90),

                  ],
                )
            ),
          ],
        ),
      )
    );
  }
}
