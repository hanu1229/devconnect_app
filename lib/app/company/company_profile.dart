
import 'package:devconnect_app/app/company/company_menutabs.dart';
import 'package:devconnect_app/app/component/custom_card.dart';
import 'package:devconnect_app/app/component/custom_outlinebutton.dart';
import 'package:devconnect_app/app/component/custom_scrollview.dart';
import 'package:devconnect_app/app/component/custom_textbutton.dart';
import 'package:devconnect_app/app/component/custom_textfield.dart';
import 'package:devconnect_app/app/layout/company_main_app.dart';
import 'package:devconnect_app/app/layout/home.dart';
import 'package:devconnect_app/style/server_path.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../component/custom_boolalert.dart';
import '../component/custom_imgpicker.dart';
import '../component/custom_menutabs.dart';
import '../layout/main_app.dart';

class Companyprofile extends StatefulWidget{

  final Function(int) changePage; // 페이지 변경 index 변수

  const Companyprofile({
    required this.changePage, //Companyprofile에서 인덱스 받음
    });


  @override
  _CompanyProfileState createState() {
    return _CompanyProfileState();
  }
}

class _CompanyProfileState extends State< Companyprofile >{
  Dio dio = Dio();

  //오류메시지 변수
  String errorMessage = '';

  // 상태변수
  XFile? profileImage;        // 이미지 파일 받기
  String? profileImageUrl;    // 이미지 url 받기
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
      widget.changePage(0);
    }
  } // f end

  // 회원정보 가져오기
  Map<String, dynamic> info = {};

  void onInfo( token ) async {
    try{
      dio.options.headers['Authorization'] = token;
      final response = await dio.get("${serverPath}/api/company/info");
      print("response : $response");
      final data = response.data;
      print("data : $data");

      if( data != '' ){
        setState(() {
          info = data;
          profileImageUrl = data['cprofile']; /// 프로파일 이미지 받음
          print(">> $profileImageUrl");
        });
      }
    }catch( e ){ print( e ); }
  } // f end

  final TextEditingController cidController = TextEditingController();
  final TextEditingController cpwdController = TextEditingController();
  final TextEditingController cnameController = TextEditingController();
  final TextEditingController cphoneController= TextEditingController();
  final TextEditingController cadressController = TextEditingController();
  final TextEditingController cemailController = TextEditingController();


  // 상세정보 수정
  void onUpdate( ) async {

    FormData formData = FormData();

    formData.fields.add(MapEntry("cpwd", cpwdController.text) );
    formData.fields.add(MapEntry("cname", cnameController.text,) );
    formData.fields.add(MapEntry("cphone", cphoneController.text,) );
    formData.fields.add(MapEntry("cemail", cemailController.text,) );
    formData.fields.add(MapEntry("cadress", cadressController.text) );

    final file = await MultipartFile.fromFile(profileImage!.path, filename: profileImage!.name); //경로 이름
    formData.files.add(MapEntry("file" , file)); // 파일로 보냄
    //print(formData);

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    try{
      dio.options.headers['Authorization'] = token;
      final response = await dio.put("${serverPath}/api/company/update", data: formData);
      final data = response.data;
      if( data ){
        setState(() {
          onInfo( token );
          isUpdate = false;
          if(data != null && data['cprofile'] != null){
            profileImage = null; // 파일제거
            profileImageUrl = data['cprofile']; // 서버 URL 사용
          }
        });
      }
    }catch( e ){ print( e ); }
  } // f end


  // 로그아웃 로그아웃부분 token 검사후 배열에 넣은 info data 받아옴 //이거 안만들어도 됨  await prefs.remove('token'); 으로 로그아웃 됨
  void logOut() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if( token == null ){ return; }
    dio.options.headers['Authorization'] = token;
    final response = await dio.get("${serverPath}/api/company/logout");
    await prefs.remove('token');
    final data = response.data;
    isLogIn = false;
    setState(() {
      info = {};
      Navigator.pushReplacement( context, MaterialPageRoute(builder: (context) => MainApp() ) );
    });
  } // f end




  // 비밀번호 수정 다이얼로그
  void updateCpw(BuildContext context) {
    final TextEditingController currnetPwdController = TextEditingController();
    final TextEditingController newPwdController = TextEditingController();
    final TextEditingController confirmNewPwdController = TextEditingController();

    if(newPwdController.text != confirmNewPwdController.text){return;}

    //비밀번호 수정함수
    void onUpdateCpw() async {
      final sendData = {
        'cpwd' : currnetPwdController.text,
        'upcpwd' : newPwdController.text,
      };

      print("비밀번호 수정함수 부분 : $sendData");

      try{
        final prefs = await SharedPreferences.getInstance();
        final token = prefs.getString('token');

        dio.options.headers['Authorization'] = token;
        final response = await dio.put("${serverPath}/api/company/pwupdate" , data: sendData);

        if(response.data == true){
          Navigator.pop(context);
          logOut();
          Navigator.push(context, MaterialPageRoute(builder: (context) => MainApp()));
        }
      }catch(e){print(e);}
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("비밀번호 변경"),
              SizedBox( height: 7,),
              Divider(),
            ],
          ),
          content: SizedBox(
            width: 350,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("현재 비밀번호"),
                SizedBox( height: 10,),
                CustomTextField(
                  controller: currnetPwdController,
                  obscureText: true,
                ),
                SizedBox( height: 15,),

                Text("변경할 비밀번호"),
                SizedBox( height: 10,),
                CustomTextField(
                  controller:  newPwdController,
                  obscureText: true,
                ),
                SizedBox( height: 15,),

                Text("비밀번호 확인"),
                SizedBox( height: 10,),
                CustomTextField(
                  controller: confirmNewPwdController,
                  obscureText: true,
                ),

              ],
            ),
          ),
          actions: [
            CustomOutlineButton(
                onPressed: () => { Navigator.pop( context ) },
                title: "취소"
            ),
            CustomTextButton(
                onPressed: onUpdateCpw,
                title: "저장"
            ),
          ],
        );
      },
    );
  }


  //회원삭제  //상태변경으로 변경
void CustomDialog(BuildContext context) {
    final TextEditingController customPwdController = TextEditingController();

  void onDelete() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    print("삭제함수 토큰 확인 : $token");

    final sendData = {
      'cid': info['cid'],
      'cpwd': customPwdController.text
    };
    print("sendData확인:$sendData");

    try {
      dio.options.headers['Authorization'] = token;
      final response = await dio.put(
          "${serverPath}/api/company/state", data: sendData);
      bool result = response.data;
        print(result);

      if (!result) {
        print("변경실패");


      } else {
        print("변경성공");
        Navigator.pop(context);
        //logOut();
        await prefs.remove('token');
        Navigator.push(context, MaterialPageRoute(builder: (context) => CompanyMainApp()));
      }
    } catch (e) {
      print(e);
    }
  }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("정말 탈퇴하시겠습니까?"),
              SizedBox( height: 7,),
              Divider(),
            ],
          ),

          content: SizedBox(
            width: 350,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                Text("기존 비밀번호"),
                SizedBox( height: 10,),
                CustomTextField(
                  controller: customPwdController,
                  obscureText: true,
                ),

                SizedBox( height: 15,),

              ],
            ),
          ),
          actions: [
            CustomOutlineButton(
                onPressed: () => { Navigator.pop( context ) },
                title: "취소"
            ),
            CustomTextButton(
                onPressed: onDelete,
                title: "저장"
            ),
          ],
        );
      },
    );
}





  @override
  Widget build(BuildContext context) {

    if( info.isEmpty ){ return Center( child: CircularProgressIndicator(), ); }

    final image = info['cprofile']; // 이미지 문제 있었음
    String imgUrl = image;

    // if( !isLogIn ){ Navigator.pushNamed( context, MainApp() ) }

    return CustomSingleChildScrollview(
      children: [
        CompanyMenuTabs(
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

                Text( info['cname'],   // 이부분 수정함
                    style: TextStyle( fontSize: 20, fontWeight: FontWeight.bold, ) ),
                SizedBox( height: 12, ),

                Text( info['cemail'], // 이부분 수정함
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
                          cidController.text = info['cid'];
                          cnameController.text = info['cname'];
                          cphoneController.text = info['cphone'];
                          cemailController.text = info['cemail'];
                          cadressController.text = info['cadress'];
                          // cbusinessController.text = info['cbusiness'];
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
                  child: CustomImagePicker(
                    dprofile: profileImageUrl,
                    onImageSelected: ( XFile image ) {
                      setState(() {
                        profileImage = image;
                      });
                    },
                  ),
                ),
                SizedBox( height: 20, ),

                Text("아이디"),
                SizedBox( height: 12, ),
                CustomTextField( controller: cidController, readOnly: true, ),
                SizedBox( height: 12, ),

                Text("비밀번호"),
                SizedBox( height: 12, ),
                CustomTextField( controller: cpwdController, ),
                SizedBox( height: 12, ),

                Text("기업명"),
                SizedBox( height: 12, ),
                CustomTextField( controller: cnameController, ),
                SizedBox( height: 12, ),


                Text("휴대번호"),
                SizedBox( height: 12, ),
                CustomTextField( controller: cphoneController, ),
                SizedBox( height: 12, ),

                Text("이메일"),
                SizedBox( height: 12, ),
                CustomTextField( controller: cemailController, ),
                SizedBox( height: 12, ),

                Text("주소"),
                SizedBox( height: 12, ),
                CustomTextField( controller: cadressController, ),
                SizedBox( height: 15, ),

                // Text("사업자 등록번호"),
                // SizedBox( height: 12, ),
                // CustomTextField( controller: cbusinessController, ),
                // SizedBox( height: 15, ),

                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [

                    CustomOutlineButton(
                      onPressed: () => { setState(() => { isUpdate = false }) },
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

        Text("비밀번호", style: TextStyle( fontSize: 18, fontWeight: FontWeight.bold, ), ),
        SizedBox( height: 15 ,),


        // 두번째 Card // 비밀번호 변경 card
        CustomCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("최근 업데이트 : ${info['updateAt'].split('T')[0]}", // 스플라이스 개념 헷갈리는듯 다시하기
                style: TextStyle( fontSize: 15, fontWeight: FontWeight.bold, color: Colors.grey),
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
                    onPressed: () => { setState(() => { updateCpw(context) }) },
                    title: "비밀번호 변경",
                    width: 150,
                  ),
                ]
              ),

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
              Text("아이디 생성일 : ${info['createAt'].split('T')[0]}",
                style: TextStyle( fontSize: 15, fontWeight: FontWeight.bold, color: Colors.grey ),
              ),
              SizedBox( height: 5 ,),

              Padding(
                padding: EdgeInsets.fromLTRB( 0, 0, 110, 0),
                child: Text("계정 탈퇴시 프로젝트 관련 정보가 삭제됩니다.",
                  style: TextStyle( fontSize: 15, fontWeight: FontWeight.bold ), ),
              ),
              SizedBox( height: 15 ,),

              // 버튼
              Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    CustomTextButton(
                      onPressed: () => { CustomDialog(context) }, // 삭제 실행후 이동경로
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