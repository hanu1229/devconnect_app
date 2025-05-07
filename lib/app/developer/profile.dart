
import 'package:devconnect_app/app/component/custom_card.dart';
import 'package:devconnect_app/app/component/custom_imgpicker.dart';
import 'package:devconnect_app/app/component/custom_menutabs.dart';
import 'package:devconnect_app/app/component/custom_outlinebutton.dart';
import 'package:devconnect_app/app/component/custom_scrollview.dart';
import 'package:devconnect_app/app/component/custom_textbutton.dart';
import 'package:devconnect_app/app/component/custom_textfield.dart';
import 'package:devconnect_app/style/app_colors.dart';
import 'package:devconnect_app/style/server_path.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Profile extends StatefulWidget{
  final Function(int) changePage;

  const Profile({
    required this.changePage,
  });

  @override
  _ProfileState createState() {
    return _ProfileState();
  }
}

class _ProfileState extends State< Profile >{
  Dio dio = Dio();

  // 상태변수
  int mno = 0;
  XFile? profileImage;
  String? profileImageUrl;
  // 수정 상태 확인
  bool isUpdate = false;

  @override
  void initState() {
    loginCheck();
  } // f end

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

  TextEditingController didController = TextEditingController();
  TextEditingController dpwdController = TextEditingController();
  TextEditingController dnameController = TextEditingController();
  TextEditingController dphoneController = TextEditingController();
  TextEditingController demailController = TextEditingController();
  TextEditingController daddressController = TextEditingController();

  // 상세정보 수정
  void onUpdate( ) async {
    FormData formData = FormData();

    formData.fields.add( MapEntry("dpwd", dpwdController.text) );
    formData.fields.add( MapEntry("dname", dnameController.text) );
    formData.fields.add( MapEntry("dphone", dphoneController.text) );
    formData.fields.add( MapEntry("demail", demailController.text) );
    formData.fields.add( MapEntry("daddress", daddressController.text) );

    final file = await MultipartFile.fromFile( profileImage!.path, filename: profileImage!.name );
    formData.files.add( MapEntry( "dfile", file ));

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    try{
      dio.options.headers['Authorization'] = token;
      final response = await dio.put("${serverPath}/api/developer/update", data: formData);
      final data = response.data;
      if( data ){
        setState(() {
          onInfo( token );
          isUpdate = false;
          if (data != null && data['dprofile'] != null) {
            profileImage = null; // XFile 제거
            profileImageUrl = data['dprofile']; // 서버 URL 사용
          }

        });
      }
    }catch( e ){ print( e ); }
    dpwdController = TextEditingController(text: "");
  } // f end

  // 탈퇴하기
  void onDelete() async {
    try{
      final dpwd = dpwdController.text;

      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      dio.options.headers['Authorization'] = token;
      final response = await dio.put("${serverPath}/api/developer/delete",
          options: Options( headers: { 'Authorization' : token, 'Content-Type' : 'text/plain', },
          responseType: ResponseType.plain ),
          data: dpwd,
      );
      final data = response.data;
      if( data ){
        await prefs.remove('token');
        widget.changePage(0);
      }
    }catch( e ){ print( e ); }
  }


  @override
  Widget build(BuildContext context) {

    if( developer.isEmpty ){ return Center( child: CircularProgressIndicator(), ); }

    final image = developer['dprofile'];
    String imgUrl = "${serverPath}/upload/${image}";

    // if( !isLogIn ){ Navigator.pushNamed( context, MainApp() ) }

    return CustomSingleChildScrollview(
      children: [
        CustomMenuTabs(
          changePage: widget.changePage,
          selectedIndex: 2,
        ),

        SizedBox( height: 15 ,),
        Text("기본 정보", style: TextStyle( fontSize: 18, fontWeight: FontWeight.bold, ), ),
        SizedBox( height: 10 ,),

        // 첫번째 Card
        CustomCard(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: !isUpdate ? CrossAxisAlignment.center : CrossAxisAlignment.start,
            children: !isUpdate
                ? // 수정버튼 클릭 전
              [
                ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: Container(
                    width: 100, height: 100,
                    child: Image.network( imgUrl, fit: BoxFit.cover, ),
                  ),
                ),
                SizedBox( height: 20, ),

                Text( developer['dname'],
                    style: TextStyle( fontSize: 20, fontWeight: FontWeight.bold, ) ),
                SizedBox( height: 12, ),

                Text( developer['demail'],
                    style: TextStyle( fontSize: 15, ) ),
                SizedBox( height: 12, ),

                // 버튼
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    CustomTextButton(
                      onPressed: () => {
                        setState(() {
                          isUpdate = true;
                          didController.text = developer['did'];
                          dnameController.text = developer['dname'];
                          dphoneController.text = developer['dphone'];
                          demailController.text = developer['demail'];
                          daddressController.text = developer['daddress'];
                        }),
                      },
                      title: "수정",
                    ),
                  ],
                ),
              ]
                : // 수정버튼 클릭 후
              [
                Center(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(999),
                    child: Container(
                      width: 100, height: 100,
                      child: Image.network( imgUrl, fit: BoxFit.cover, ),
                    ),
                  ),
                ),
                SizedBox( height: 20, ),

                Text("아이디"),
                SizedBox( height: 12, ),
                CustomTextField( controller: didController, readOnly: true, ),
                SizedBox( height: 12, ),

                Text("비밀번호"),
                SizedBox( height: 12, ),
                CustomTextField( controller: dpwdController, ),
                SizedBox( height: 12, ),

                Text("전화번호"),
                SizedBox( height: 12, ),
                CustomTextField( controller: dphoneController, ),
                SizedBox( height: 12, ),

                Text("이메일"),
                SizedBox( height: 12, ),
                CustomTextField( controller: demailController, ),
                SizedBox( height: 12, ),

                Text("주소"),
                SizedBox( height: 12, ),
                CustomTextField( controller: daddressController, ),
                SizedBox( height: 15, ),

                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [

                    CustomOutlineButton(
                      onPressed: () => { setState(() => {
                        isUpdate = false, dpwdController = TextEditingController( text: "" ), }) },
                      title: "취소",
                    ),
                    SizedBox( width: 15,),

                    CustomTextButton( onPressed: onUpdate, title: "저장" ),

                  ],
                )
              ]

          ),
        ),
        SizedBox( height: 30,),

        // 두번째 Card
        Text("비밀번호", style: TextStyle( fontSize: 18, fontWeight: FontWeight.bold, ), ),
        SizedBox( height: 15 ,),

        // 두번째 Card
        CustomCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("최근 업데이트 : ${developer['updateAt'].split('T')[0]}",
                style: TextStyle( fontSize: 15, fontWeight: FontWeight.bold, color: Colors.grey ),
              ),
              SizedBox( height: 5 ,),

              Text("비밀번호", style: TextStyle( fontSize: 16, fontWeight: FontWeight.bold ), ),
              SizedBox( height: 15 ,),

              // 버튼
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  CustomOutlineButton(
                    onPressed: () => { setState(() => { isUpdate = false }) },
                    title: "비밀번호 변경",
                    width: 150,
                  ),
                ]
              ),

            ],
          ),
        ),
        SizedBox( height: 30,),

        // 세번째 Card
        Text("기술 스택 및 경력", style: TextStyle( fontSize: 18, fontWeight: FontWeight.bold, ), ),
        SizedBox( height: 15 ,),
        CustomCard(
          child : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("기술 스택",
                style: TextStyle( fontSize: 15, fontWeight: FontWeight.bold, color: Colors.grey ),
              ),
              SizedBox( height: 5 ,),

              Padding(
                padding: EdgeInsets.fromLTRB( 0, 0, 110, 0),
                child: Text("기술 목록",
                  style: TextStyle( fontSize: 15, fontWeight: FontWeight.bold ), ),
              ),
              SizedBox( height: 15 ,),

              // 버튼
              Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    CustomOutlineButton(
                      onPressed: () => { setState(() => { isUpdate = false }) },
                      title: "등록",
                    ),
                  ]
              ),
              SizedBox( height: 15 ,),

              Divider( thickness: 0.5, ),

              Text("경력",
                style: TextStyle( fontSize: 15, fontWeight: FontWeight.bold, color: Colors.grey ),
              ),
              SizedBox( height: 5 ,),

              Padding(
                padding: EdgeInsets.fromLTRB( 0, 0, 110, 0),
                child: Text("경력 목록",
                  style: TextStyle( fontSize: 15, fontWeight: FontWeight.bold ), ),
              ),
              SizedBox( height: 15 ,),

              // 버튼
              Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    CustomOutlineButton(
                      onPressed: () => { setState(() => { isUpdate = false }) },
                      title: "등록",
                    ),
                  ]
              ),
              SizedBox( height: 15 ,),

            ],
          ),
        ),
        SizedBox( height: 30,),

        // 네번째 Card
        Text("계정 탈퇴", style: TextStyle( fontSize: 18, fontWeight: FontWeight.bold, ), ),
        SizedBox( height: 15 ,),
        CustomCard(
          child : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("아이디 생성일 : ${developer['createAt'].split('T')[0]}",
                style: TextStyle( fontSize: 15, fontWeight: FontWeight.bold, color: Colors.grey ),
              ),
              SizedBox( height: 5 ,),

              Padding(
                padding: EdgeInsets.fromLTRB( 0, 0, 110, 0),
                child: Text("계정 탈퇴시 프로필 및 프로젝트 관련 정보가 삭제됩니다.",
                  style: TextStyle( fontSize: 15, fontWeight: FontWeight.bold ), ),
              ),
              SizedBox( height: 15 ,),

              // 버튼
              Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    CustomTextButton(
                      onPressed: onDelete,
                      title: "회원 탈퇴",
                      width: 90,
                      color: Colors.red,
                    ),
                  ]
              ),
            ],
          ),
        ),

        SizedBox(height: 50 + MediaQuery.of(context).padding.bottom),

      ],
    );
  }
}