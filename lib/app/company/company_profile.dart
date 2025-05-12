
import 'package:devconnect_app/app/company/company_menutabs.dart';
import 'package:devconnect_app/app/component/custom_card.dart';
import 'package:devconnect_app/app/component/custom_outlinebutton.dart';
import 'package:devconnect_app/app/component/custom_scrollview.dart';
import 'package:devconnect_app/app/component/custom_textbutton.dart';
import 'package:devconnect_app/app/component/custom_textfield.dart';
import 'package:devconnect_app/style/server_path.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../component/custom_alert.dart';
import '../component/custom_boolalert.dart';
import '../component/custom_imgpicker.dart';
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

  final _formKey = GlobalKey<FormState>();

  // 비밀번호
  String? pwdValidator(String? value) {
    final passwordReg = RegExp(r'^(?=.*[A-Za-z])(?=.*\d)(?=.*[!@#$%^&*()_+=-]).{8,20}$');
    if (value == null || value.isEmpty) {
      return '비밀번호를 입력해주세요';
    } else if (!passwordReg.hasMatch(value)) {
      return '영문, 숫자, 특수문자를 포함한 8~20자여야 합니다';
    }
    return null;
  }

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

    if (profileImage != null) {
      try {
        final file = await MultipartFile.fromFile(profileImage!.path, filename: profileImage!.name);
        formData.files.add(MapEntry("file" , file));
      } catch (e) {
        print("프로필 이미지 파일 처리 중 오류 발생: $e");
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('프로필 이미지 파일을 처리하는 중 오류가 발생했습니다.')),
        );
        return;
      }
    }

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
            profileImage = null; // 파일제거 cbcb
            profileImageUrl = "$serverPath/upload/company_logo/${data['cprofile']}"; // 서버 URL 사용
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
    final _formKey = GlobalKey<FormState>();
    final TextEditingController currnetPwdController = TextEditingController();
    final TextEditingController newPwdController = TextEditingController();
    final TextEditingController confirmNewPwdController = TextEditingController();

    String errorMessage = '';

    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            Future<void> onPwdChange() async {
              try {
                final prefs = await SharedPreferences.getInstance();
                final token = prefs.getString('token');
                final sendData = {
                  'cpwd' : currnetPwdController.text,
                  'upcpwd' : newPwdController.text,
                };

                final response = await dio.put("${serverPath}/api/company/pwupdate", data: sendData );

                final responpwd = response.data;
                if ( responpwd == true ) {
                  Navigator.pop(context); // 다이얼로그 닫기
                  onInfo(token);
                  showDialog(
                    context: context,
                    builder: (context) => CustomBoolAlertDialog(
                        title : "비밀번호가 변경되었습니다."
                    ),
                  );
                }
              } on DioException catch(e){
                setState(() {
                  errorMessage = e.response?.data ?? '비밀번호 변경 실패';
                });
              } catch(e){
                setState(() {
                  errorMessage = '서버 오류 발생';
                });
              }
            }

            return CustomAlertDialog(
                title: "비밀번호 변경",
                width: 350,
                content: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("현재 비밀번호"),
                      SizedBox(height: 10),
                      CustomTextField(
                        controller: currnetPwdController,
                        obscureText: true,
                        validator: (value) =>
                        value == null || value.isEmpty
                            ? '현재 비밀번호를 입력해주세요.'
                            : null,
                      ),
                      if (errorMessage.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(left: 15),
                          child: Text(
                            errorMessage,
                            style: TextStyle(
                                color: Color(0xffbc443d),
                                fontSize: 12
                            ),
                          ),
                        ),
                      SizedBox(height: 15),
                      Text("비밀번호"),
                      SizedBox(height: 10),
                      CustomTextField(
                        controller: newPwdController,
                        obscureText: true,
                        validator: (value) => pwdValidator(value),
                      ),
                      SizedBox(height: 15),
                      Text("비밀번호 확인"),
                      SizedBox(height: 10),
                      CustomTextField(
                        controller: confirmNewPwdController,
                        obscureText: true,
                        validator: (value) =>
                        newPwdController.text != confirmNewPwdController.text
                            ? '비밀번호가 일치하지 않습니다.'
                            : currnetPwdController.text == newPwdController.text ?
                        '기존 비밀번호와 다른 번호를 입력해주세요.'
                            : null,
                      ),
                    ],
                  ),
                ),
                onPressed: () async {
                  setState(() { errorMessage = ''; });
                  if( _formKey.currentState!.validate() ){
                    await onPwdChange();
                  }
                }
            );
          },
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
          Navigator.push(context, MaterialPageRoute(builder: (context) => MainApp()));
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
    // String imgUrl = "${serverPath}/upload/company_logo/${image}";
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


        // 비밀번호 변경 card
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