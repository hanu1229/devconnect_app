

import 'dart:convert';

import 'package:devconnect_app/app/component/custom_outlinebutton.dart';
import 'package:devconnect_app/app/component/custom_textbutton.dart';
import 'package:devconnect_app/style/app_colors.dart';
import 'package:devconnect_app/style/server_path.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RatingDetail extends StatefulWidget{

  // 평가리스트에서 클릭한 Card의 crno , pno , cno 가져오기
  String? profile;
  final Map<String,dynamic>? rating;
  final Map<String,dynamic>? project;
  final Map<String,dynamic>? company;
  final Map<String,dynamic>? developer;
  RatingDetail( { this.rating , this.project , this.company , this.developer , this.profile } );

  @override
  State<StatefulWidget> createState() {
    return _RatingDtailState();
  } // createState end
} // c end

class _RatingDtailState extends State<RatingDetail>{

  // 요청 값을 저장하는 상태 변수
  Map< String , dynamic > rating = {};
  Map< String , dynamic > project = {};
  Map< String , dynamic > developer = {};
  Map< String , dynamic > company = {};

  // 상태변수
  final dio = Dio();
  bool update = false;
  bool delete = false;
  String? token;
  String? tokenrole;
  String? tokenid;
  double? updateValue;

  // 입력 컨트롤러
  TextEditingController titleController = TextEditingController();
  TextEditingController contentController = TextEditingController();

  @override
  void initState() {
    whyToken();

    rating = widget.rating ??{};
    project = widget.project ??{};
    developer = widget.developer ??{};
    company = widget.company ??{};
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
    setState(() {
      tokenid = id;
      tokenrole = role;
    });
  } // whyToken end

  // 기업 평가 수정
  void cUpdate() async{
    try{
      final sendData = {
        "crno" : rating['crno'],
        "ctitle" : titleController.text,
        "ccontent" : contentController.text,
        "crscore" : updateValue ?? rating['crscore'],
        "crstate" : rating['crstate'],
      };
      dio.options.headers['Authorization'] = token;
      final response = await dio.put("${serverPath}/api/crating" , data: sendData );
      print("Response data: ${response.data}");
      final data = response.data;
      print( "data : ${data}" );
      if( data == true ){
        success("수정 성공");
        // 값 화면 반영
        final updateRating = await dio.get("${serverPath}/api/crating/view?crno=${rating['crno']}");
        setState(() {
          rating = updateRating.data;
        });
      }
    }catch(e) { print( e ); }
  } // onUpdate end

  // 기업 평가 삭제
  void cDelete() async{
    try{
      dio.options.headers['Authorization'] = token;
      final response = await dio.delete("${serverPath}/api/crating?crno=${rating['crno']}");
      if( response.data == true ){
        success("삭제 성공");
      }
    }catch(e) { print( e ); }
  } // cDelete end

  // 개발자 평가 수정
  void dUpdate() async{
    try{
      final sendData = {
        "drno" : rating['drno'],
        "dtitle" : titleController.text,
        "dcontent" : contentController.text,
        "drscore" : updateValue ?? rating['drscore'],
        "drstate" : rating['drstate'],
      };
      dio.options.headers['Authorization'] = token;
      final response = await dio.put("${serverPath}/api/drating" , data: sendData );
      final data = response.data;
      if( data == true ){
        success("수정 성공");
        final updataRating = await dio.get("${serverPath}/api/drating/view?drno=${rating['drno']}");
        setState(() {
          rating = updataRating.data;
        });
      }
    }catch(e) { print( e ); }
  } // dUpdate end

  // 개발자 평가 삭제
  void dDelete() async{
    try{
      dio.options.headers['Authorization'] = token;
      final response = await dio.delete("${serverPath}/api/drating?drno=${rating['drno']}");
      if( response.data == true ){
        success("삭제 성공");
      }
    }catch(e) { print( e ); }
  } // cDelete end
  
  // 성공 알림창
  void success( String message ){
    Navigator.pop(context,true);
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: Colors.white,
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("성공"),
              SizedBox( height: 7,),
              Divider(),
            ],
          ),
          content: Text(message),
          actions: [
            CustomTextButton(
              title: "확인",
              color: Colors.grey,
              onPressed: () => Navigator.of(context).pop(),
            )
          ],
        )
    );
  } // success end

  // 요청 ==========================================================================================================================
  @override
  Widget build(BuildContext context) {
    print("developer map: $developer");
    print("developer name: ${developer['dname']}");
    // 공고 정보가 없으면 로딩
    if (rating.isEmpty || project.isEmpty) {
      return Center(child: CircularProgressIndicator());
    }
    if( tokenrole == "Developer" ){
      return Scaffold(
        appBar: AppBar(
          title: Text("평가 상세보기"),
        ),
        body: SingleChildScrollView(
          padding: EdgeInsets.all(15),
          child: Card(
            elevation: 7,
            color: AppColors.bgColor,
            shadowColor: AppColors.textColor,
            shape: RoundedRectangleBorder( // borderRadius 보더 라운드
              borderRadius: BorderRadius.circular(8),
            ),
            margin: EdgeInsets.all(5),
            child: Container(
              height: 500, // CARD 높이 고정으로
              decoration: BoxDecoration(
                border: Border.all(
                  color: AppColors.borderColor2,
                ),
                borderRadius: BorderRadius.circular(8),
              ), //
              child: Padding(
                padding: EdgeInsets.only( left: 20, right: 20, top: 15, bottom: 15, ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 50 , height: 50,
                          child: Image.network(
                            widget.profile ?? "${serverPath}/upload/default.jpg",
                            fit: BoxFit.cover,
                          ),
                        ),
                        SizedBox( width: 15,),
                        Expanded(
                          child: Container(
                            height: 55,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  company['cname'] ?? "",
                                  style: TextStyle(
                                    fontWeight:  FontWeight.bold,
                                    color: AppColors.textSubColor,
                                    fontSize: 12,
                                  ),
                                ),
                                Text(
                                  company['cphone'] ?? "",
                                  style: TextStyle(
                                    fontWeight:  FontWeight.bold,
                                    color: AppColors.textSubColor,
                                    fontSize: 12,
                                  ),
                                ),
                                Text(
                                  company['cadress'] ?? "",
                                  style: TextStyle(
                                    fontWeight:  FontWeight.bold,
                                    color: AppColors.textSubColor,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            )
                          ),
                        ),
                      ],
                    ),
                    Divider(color: Colors.grey, thickness: 1, height: 30),
                    Column(
                      children: [
                        Text(
                          rating['ctitle'] ?? "",
                          style: TextStyle(
                            fontWeight: FontWeight.w900,
                            color: AppColors.textColor,
                            fontSize: 18,
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "개발자명 : ${ developer['dname'] ?? '' } ",
                              style: TextStyle(
                                fontSize: 12 ,
                                fontWeight:  FontWeight.bold,
                                color: AppColors.textSubColor,
                              ),
                            ),
                            RatingBarIndicator(
                              rating: (rating['crscore'] ?? 0).toDouble(),
                              direction: Axis.horizontal,
                              itemCount: 5,
                              itemSize: 30, // 별 크기
                              // itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
                              itemBuilder: (context, _) => Icon(
                                Icons.star,
                                color: AppColors.ratingTextColor,
                              ),
                            ),
                          ]
                        ),
                        SizedBox(height: 20,),
                        Container(
                          width: double.infinity,
                          padding: EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: AppColors.borderColor2),
                          ),
                          child:
                          Text(
                            rating['ccontent'] ?? "내용이 없습니다.",
                            style: TextStyle(
                              fontSize: 14,
                              color: AppColors.textColor,
                            ),
                          ),
                        )
                      ],
                    ),
                    Spacer (),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          "최종수정일 : ${ rating['updateAt'] ?? '' } ",
                          style: TextStyle(
                            fontSize: 12 ,
                            fontWeight:  FontWeight.bold,
                            color: AppColors.textSubColor,
                          ),
                        ),
                      ]
                    ),
                    Divider(color: Colors.grey, thickness: 1, height: 30),
                    if( developer['did'] == tokenid )
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        CustomOutlineButton(
                          onPressed: () {
                            titleController.text = rating['ctitle'] ?? '';
                            contentController.text = rating['ccontent'] ?? '';
                            showDialog(
                              context: context,
                              barrierDismissible: false, // 바깥 클릭 막기
                              builder: (context) {
                                return AlertDialog(
                                  backgroundColor: Colors.white,
                                  title: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "평가 수정",
                                        style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      SizedBox(height: 7),
                                      Divider(),
                                    ],
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  content: Container(
                                    width: MediaQuery.of(context).size.width * 0.8, // 가로폭 제한
                                    padding: const EdgeInsets.all(10),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        TextField(
                                          style: TextStyle( fontSize: 14 ),
                                          controller: titleController,
                                          decoration: InputDecoration(
                                            labelText: "제목",
                                            labelStyle: TextStyle( fontSize: 20 ),
                                            border: OutlineInputBorder(),
                                          ),
                                        ),
                                        SizedBox(height: 30),
                                        TextField(
                                          style: TextStyle( fontSize: 14 ),
                                          controller: contentController,
                                          maxLines: 4,
                                          decoration: InputDecoration(
                                            labelText: "내용",
                                            labelStyle: TextStyle( fontSize: 20 ),
                                            border: OutlineInputBorder(),
                                          ),
                                        ),
                                        SizedBox(height: 20),
                                        // 별점으로 수정
                                        Center(
                                            child: RatingBar(
                                              initialRating: (rating['crscore'] ?? 0).toDouble(),
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
                                                full: Icon(Icons.star, color: AppColors.ratingTextColor,),
                                                half: Icon(Icons.star_half, color: AppColors.ratingTextColor,),
                                                empty: Icon(Icons.star_border, color: AppColors.ratingTextColor,),
                                              ),
                                            ),
                                        ),
                                        SizedBox(height: 20,),
                                      ],
                                    ),
                                  ),
                                  actions: [
                                    CustomTextButton(
                                      title: "취소",
                                      color: Colors.grey,
                                      onPressed: () => Navigator.of(context).pop(),
                                    ),
                                    CustomTextButton(
                                      title: "수정",
                                      color: Colors.blue,
                                      onPressed: () {
                                        Navigator.of(context).pop(); // 다이얼로그 닫기
                                        cUpdate(); // 수정 함수 실행
                                      },
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                          title: "수정",
                        ),
                        CustomOutlineButton(
                          onPressed: () { 
                            showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  backgroundColor: Colors.white,
                                  title: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text( "삭제 확인", ),
                                      SizedBox( height:  7 ,),
                                      Divider(),
                                    ],
                                  ),
                                  content: Text("정말로 이 평가를 삭제하시겠습니까?"),
                                  actions: [
                                    CustomTextButton(
                                      title: "취소",
                                      color: Colors.grey,
                                      onPressed: () => Navigator.of(context).pop(),
                                    ),
                                    CustomTextButton(
                                      title: "삭제",
                                      color: Colors.blue,
                                      onPressed: () {
                                        Navigator.of(context).pop(); // 다이얼로그 닫기
                                        cDelete();                   // 삭제 함수 실행
                                      },
                                    ),
                                  ],
                                )
                            );
                          },
                          title: "삭제",
                        )
                      ],
                    ),
                  ]
                ),
              ),
            ),
          ),
        ),
      );
    }else if( tokenrole == "Company" ){
      return Scaffold(
        appBar: AppBar(
          title: Text("평가 상세보기"),
        ),
        body: SingleChildScrollView(
          padding: EdgeInsets.all(15),
          child: Card(
            elevation: 7,
            color: AppColors.bgColor,
            shadowColor: AppColors.textColor,
            shape: RoundedRectangleBorder( // borderRadius 보더 라운드
              borderRadius: BorderRadius.circular(8),
            ),
            margin: EdgeInsets.all(5),
            child: Container(
              height: 500, // CARD 높이 고정으로
              decoration: BoxDecoration(
                border: Border.all(
                  color: AppColors.borderColor2,
                ),
                borderRadius: BorderRadius.circular(8),
              ), //
              child: Padding(
                padding: EdgeInsets.only( left: 20, right: 20, top: 15, bottom: 15, ),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 50 , height: 50,
                            child: Image.network(
                              widget.profile ?? "${serverPath}/upload/default.jpg",
                              fit: BoxFit.cover,
                            ),
                          ),
                          SizedBox( width: 15,),
                          Expanded(
                            child: Container(
                                height: 55,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      developer['dname'] ?? "",
                                      style: TextStyle(
                                        fontWeight:  FontWeight.bold,
                                        color: AppColors.textSubColor,
                                        fontSize: 12,
                                      ),
                                    ),
                                    Text(
                                      developer['dphone'] ?? "",
                                      style: TextStyle(
                                        fontWeight:  FontWeight.bold,
                                        color: AppColors.textSubColor,
                                        fontSize: 12,
                                      ),
                                    ),
                                    Text(
                                      developer['demail'] ?? "",
                                      style: TextStyle(
                                        fontWeight:  FontWeight.bold,
                                        color: AppColors.textSubColor,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                )
                            ),
                          ),
                        ],
                      ),
                      Divider(color: Colors.grey, thickness: 1, height: 30),
                      Column(
                        children: [
                          Text(
                            rating['dtitle'] ?? "",
                            style: TextStyle(
                              fontWeight: FontWeight.w900,
                              color: AppColors.textColor,
                              fontSize: 18,
                            ),
                          ),
                          Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "기업명 : ${ company['cname'] ?? '' } ",
                                  style: TextStyle(
                                    fontSize: 12 ,
                                    fontWeight:  FontWeight.bold,
                                    color: AppColors.textSubColor,
                                  ),
                                ),
                                RatingBarIndicator(
                                  rating: (rating['drscore'] ?? 0).toDouble(),
                                  direction: Axis.horizontal,
                                  itemCount: 5,
                                  itemSize: 30, // 별 크기
                                  // itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
                                  itemBuilder: (context, _) => Icon(
                                    Icons.star,
                                    color: AppColors.ratingTextColor,
                                  ),
                                ),
                              ]
                          ),
                          SizedBox(height: 20,),
                          Container(
                            width: double.infinity,
                            padding: EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: AppColors.borderColor2),
                            ),
                            child:
                            Text(
                              rating['dcontent'] ?? "내용이 없습니다.",
                              style: TextStyle(
                                fontSize: 14,
                                color: AppColors.textColor,
                              ),
                            ),
                          )
                        ],
                      ),
                      Spacer (),
                      Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text(
                              "최종수정일 : ${ rating['updateAt'] ?? '' } ",
                              style: TextStyle(
                                fontSize: 12 ,
                                fontWeight:  FontWeight.bold,
                                color: AppColors.textSubColor,
                              ),
                            ),
                          ]
                      ),
                      Divider(color: Colors.grey, thickness: 1, height: 30),
                      if( company['cid'] == tokenid )
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            CustomOutlineButton(
                              onPressed: () {
                                titleController.text = rating['dtitle'] ?? '';
                                contentController.text = rating['dcontent'] ?? '';
                                showDialog(
                                  context: context,
                                  barrierDismissible: false, // 바깥 클릭 막기
                                  builder: (context) {
                                    return AlertDialog(
                                      backgroundColor: Colors.white,
                                      title: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            "평가 수정",
                                            style: TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          SizedBox(height: 7),
                                          Divider(),
                                        ],
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      content: Container(
                                        width: MediaQuery.of(context).size.width * 0.8, // 가로폭 제한
                                        padding: const EdgeInsets.all(10),
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            TextField(
                                              style: TextStyle( fontSize: 14 ),
                                              controller: titleController,
                                              decoration: InputDecoration(
                                                labelText: "제목",
                                                labelStyle: TextStyle( fontSize: 20),
                                                border: OutlineInputBorder(),
                                              ),
                                            ),
                                            SizedBox(height: 30),
                                            TextField(
                                              style: TextStyle( fontSize: 14 ),
                                              controller: contentController,
                                              maxLines: 4,
                                              decoration: InputDecoration(
                                                labelText: "내용",
                                                labelStyle: TextStyle( fontSize: 20),
                                                border: OutlineInputBorder(),
                                              ),
                                            ),
                                            SizedBox(height: 20),
                                            // 별점으로 수정
                                            Center(
                                              child: RatingBar(
                                                initialRating: (rating['drscore'] ?? 0).toDouble(),
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
                                                  full: Icon(Icons.star, color: AppColors.ratingTextColor,),
                                                  half: Icon(Icons.star_half, color: AppColors.ratingTextColor,),
                                                  empty: Icon(Icons.star_border, color: AppColors.ratingTextColor,),
                                                ),
                                              ),
                                            ),
                                            SizedBox(height: 20,),
                                          ],
                                        ),
                                      ),
                                      actions: [
                                        CustomTextButton(
                                          title: "취소",
                                          color: Colors.grey,
                                          onPressed: () => Navigator.of(context).pop(),
                                        ),
                                        CustomTextButton(
                                          title: "수정",
                                          color: Colors.blue,
                                          onPressed: () {
                                            Navigator.of(context).pop(); // 다이얼로그 닫기
                                            dUpdate(); // 수정 함수 실행
                                          },
                                        ),
                                      ],
                                    );
                                  },
                                );
                              },
                              title: "수정",
                            ),
                            CustomOutlineButton(
                              onPressed: () {
                                showDialog(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      backgroundColor: Colors.white,
                                      title: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text( "삭제 확인", ),
                                          SizedBox( height:  7 ,),
                                          Divider(),
                                        ],
                                      ),
                                      content: Text("정말로 이 평가를 삭제하시겠습니까?"),
                                      actions: [
                                        CustomTextButton(
                                          title: "취소",
                                          color: Colors.grey,
                                          onPressed: () => Navigator.of(context).pop(),
                                        ),
                                        CustomTextButton(
                                          title: "삭제",
                                          color: Colors.blue,
                                          onPressed: () {
                                            Navigator.of(context).pop(); // 다이얼로그 닫기
                                            dDelete(); // 삭제 함수 실행
                                          },
                                        ),
                                      ],
                                    )
                                );
                              },
                              title: "삭제",
                            )
                          ],
                        ),

                    ]
                ),
              ),
            ),
          ),
        ),
      );
    }else{
      return Scaffold(
        appBar: AppBar(
          title: Text("권한이 없습니다."),
        ),
      );
    }

  }
} // c end