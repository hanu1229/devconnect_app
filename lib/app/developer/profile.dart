
import 'package:devconnect_app/app/component/custom_alert.dart';
import 'package:devconnect_app/app/component/custom_card.dart';
import 'package:devconnect_app/app/component/custom_imgpicker.dart';
import 'package:devconnect_app/app/component/custom_menutabs.dart';
import 'package:devconnect_app/app/component/custom_outlinebutton.dart';
import 'package:devconnect_app/app/component/custom_scrollview.dart';
import 'package:devconnect_app/app/component/custom_boolalert.dart';
import 'package:devconnect_app/app/component/custom_textbutton.dart';
import 'package:devconnect_app/app/component/custom_textfield.dart';
import 'package:devconnect_app/app/layout/main_app.dart';
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
  String errorMsg = '';
  // 수정 상태 확인
  bool isUpdate = false;

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
    onTechStack();
    tsFindAll();
    careerFindAll();
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
  void CustomUpdateDialog(BuildContext context) {
    final _formKey = GlobalKey<FormState>();
    String errorMsg = '';

    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            Future<void> onUpdate( ) async {
              FormData formData = FormData();

              formData.fields.add( MapEntry("dpwd", dpwdController.text) );
              formData.fields.add( MapEntry("dname", dnameController.text) );
              formData.fields.add( MapEntry("dphone", dphoneController.text) );
              formData.fields.add( MapEntry("demail", demailController.text) );
              formData.fields.add( MapEntry("daddress", daddressController.text) );

              if( profileImage != null ){
                final file = await MultipartFile.fromFile( profileImage!.path, filename: profileImage!.name );
                formData.files.add( MapEntry( "dfile", file ));
              }

              final prefs = await SharedPreferences.getInstance();
              final token = prefs.getString('token');

              try{
                dio.options.headers['Authorization'] = token;
                final response = await dio.put("${serverPath}/api/developer/update", data: formData);
                final data = response.data;
                if( data ){
                  showDialog(
                    context: context,
                    builder: (context) => CustomBoolAlertDialog( 
                      title: "수정이 완료되었습니다.", 
                      onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => MainApp( selectedIndex: 2,) )),
                    )
                  );
                }
              }catch( e ){
                print( e );
                setState(() { errorMsg = '비밀번호를 확인해주세요.'; });
              }
              dpwdController = TextEditingController(text: "");
            } // f end

            return CustomAlertDialog(
              title: "회원정보를 수정하시겠습니까?",
              width: 350,
              content: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("비밀번호 입력"),
                    SizedBox(height: 10),
                    CustomTextField(
                      controller: dpwdController,
                      obscureText: true,
                      validator: (value) =>
                      value == null || value.isEmpty
                          ? '비밀번호를 입력해주세요.'
                          : null,
                    ),
                    if (errorMsg.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(left: 15),
                        child: Text(
                          errorMsg,
                          style: TextStyle(
                              color: Color(0xffbc443d),
                              fontSize: 12
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              onPressed: () async {
                setState(() { errorMsg = ''; });
                if( _formKey.currentState!.validate() ){
                  await onUpdate();
                }
              }
            );
          },
        );
      },
    );
  }

  // 비밀번호 수정 다이얼로그
  void CustomPwdDialog(BuildContext context) {
    final _formKey = GlobalKey<FormState>();
    final TextEditingController _prevPwdController = TextEditingController();
    final TextEditingController _pwdController = TextEditingController();
    final TextEditingController _confirmPwdController = TextEditingController();

    String errorMsg = '';

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
                  'newPwd': _pwdController.text,
                  'matchPwd': _prevPwdController.text,
                };

                final response = await dio.put("$serverPath/api/developer/update/pwd", data: sendData );

                final pwdResp = response.data;
                if ( pwdResp['success'] ) {
                  Navigator.pop(context); // 다이얼로그 닫기
                  onInfo(token);
                  showDialog(
                    context: context,
                    builder: (context) => CustomBoolAlertDialog(
                      title: pwdResp['message'],
                    ),
                  );
                }
              } on DioException catch(e){
                setState(() {
                  errorMsg = e.response?.data['message'] ?? '비밀번호 변경 실패';
                });
              } catch(e){
                setState(() {
                  errorMsg = '서버 오류 발생';
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
                      controller: _prevPwdController,
                      obscureText: true,
                      validator: (value) =>
                        value == null || value.isEmpty
                            ? '현재 비밀번호를 입력해주세요.'
                            : null,
                    ),
                    if (errorMsg.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(left: 15),
                        child: Text(
                          errorMsg,
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
                      controller: _pwdController,
                      obscureText: true,
                      validator: (value) => pwdValidator(value),
                    ),
                    SizedBox(height: 15),
                    Text("비밀번호 확인"),
                    SizedBox(height: 10),
                    CustomTextField(
                      controller: _confirmPwdController,
                      obscureText: true,
                      validator: (value) =>
                      _pwdController.text != _confirmPwdController.text
                          ? '비밀번호가 일치하지 않습니다.'
                          : _prevPwdController.text == _pwdController.text ?
                          '기존 비밀번호와 다른 번호를 입력해주세요.'
                          : null,
                    ),
                  ],
                ),
              ),
              onPressed: () async {
                setState(() { errorMsg = ''; });
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

  // 기술스택 상태변수
  List<dynamic> allTechStacks = [];
  List<int> selectedStackIds = [];
  List<dynamic> getTechStacks = [];
  int? tslno;

  // 기술 스택 목록
  void onTechStack() async {
    try{
      final response = await dio.get("${serverPath}/api/techstack/findall");
      final data = response.data;
      if( data != null || data != [] ){
        setState(() {
          allTechStacks = data;
        });
      }
    }catch(e){ print(e); }
  } // f end

  // 기술 스택 등록
  void techStackRegister() async {
    try{
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      dio.options.headers['Authorization'] = token;

      final sendData = { "techStackList" : selectedStackIds, "tslno" : tslno };
      final response = await dio.post("${serverPath}/api/techstack/list/write", data: sendData );
      final data = response.data;
      if( data ){
        setState(() {
          tsFindAll();
        });
      }
    }catch(e){ print(e); }
  } // f end

  // 등록된 기술스택 조회
  void tsFindAll() async {
    try{
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      dio.options.headers['Authorization'] = token;

      final response = await dio.get("${serverPath}/api/techstack/list/findall");
      final data = response.data;
        setState(() {
          getTechStacks = data;
          tslno = data[0]['tslno'];
          print( getTechStacks );
          print( tslno );
        });
    }catch(e){ print(e); }
  } // f end

  // 기술스택 등록 다이얼로그
  void showTechStackDialog() {
    List<int> tempSelected = getTechStacks
        .map<int?>((stack) => stack['tsno'] is int ? stack['tsno'] as int : null)
        .whereType<int>()
        .toList();

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return CustomAlertDialog(
              width: 350,
              title: "기술스택 선택",
              content: SingleChildScrollView(
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: allTechStacks.map<Widget>((tech) {
                    final tsno = tech['tsno'];
                    final tsname = tech['tsname'];
                    final isSelected = tempSelected.contains(tsno);

                    return GestureDetector(
                      onTap: () {
                        setDialogState(() {
                          isSelected ? tempSelected.remove(tsno) : tempSelected.add(tsno);
                        });
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: isSelected ? Colors.blueAccent : AppColors.bgColor,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: isSelected ? Colors.blue : Colors.grey,
                            width: 1,
                          ),
                        ),
                        child: Text(
                          tsname,
                          style: TextStyle(
                            color: isSelected ? Colors.white : Colors.black87,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              onPressed: () {
                Navigator.pop(context);
                setState(() {
                  selectedStackIds = tempSelected;
                });
                techStackRegister(); // 서버 전송
              },
            );
          },
        );
      },
    );
  }

  // 경력 상태변수
  List<dynamic> careerList = [];
  TextEditingController cacompanyController = TextEditingController();
  TextEditingController caStartDateController = TextEditingController();
  TextEditingController caEndDateController = TextEditingController();

  // 경력 입력
  void careerRegister() async {
    try{
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      dio.options.headers['Authorization'] = token;

      final sendData = {
        "cacompany" : cacompanyController.text,
        "caStartDate" : caStartDateController.text,
        "caEndDate" : caEndDateController.text
      };

      final response = await dio.post("${serverPath}/api/career", data: sendData );
      final data = response.data;
      setState(() {
        careerFindAll();
      });
    }catch(e){ print(e); }
  } // f end

  // 경력 조회
  void careerFindAll() async {
    try{
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      dio.options.headers['Authorization'] = token;

      final response = await dio.get("${serverPath}/api/career/findall");
      final data = response.data;
      setState(() {
        careerList = data;
      });
    }catch(e){ print(e); }
  } // f end

  // 기술스택 등록 다이얼로그
  void careerDialog() {
    final formKey = GlobalKey<FormState>();
    String errorMsg = '';

    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return CustomAlertDialog(
              width: 350,
              title: "경력 등록",
              content: SingleChildScrollView(
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("기업명"),
                      SizedBox(height: 10),
                      CustomTextField(
                        controller: cacompanyController,
                        validator: (value) => value == null || value.isEmpty
                            ? '기업명을 입력해주세요.'
                            : null,
                      ),
                      SizedBox(height: 15),

                      Text("시작 날짜"),
                      SizedBox(height: 10),
                      GestureDetector(
                        onTap: () async {
                          DateTime? picked = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime(1980),
                            lastDate: DateTime(2100),
                          );
                          if (picked != null) {
                            setDialogState(() {
                              caStartDateController.text =
                              "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
                            });
                          }
                        },
                        child: AbsorbPointer(
                          child: CustomTextField(
                            controller: caStartDateController,
                            obscureText: false,
                            validator: (value) => value == null || value.isEmpty
                                ? '시작 날짜를 선택해주세요.'
                                : null,
                          ),
                        ),
                      ),
                      if (errorMsg.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(left: 15),
                          child: Text(
                            errorMsg,
                            style: TextStyle(
                                color: Color(0xffbc443d),
                                fontSize: 12
                            ),
                          ),
                        ),
                      SizedBox(height: 15),

                      Text("종료 날짜"),
                      SizedBox(height: 10),
                      GestureDetector(
                        onTap: () async {
                          DateTime? picked = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime(1980),
                            lastDate: DateTime(2100),
                          );
                          if (picked != null) {
                            setDialogState(() {
                              caEndDateController.text =
                              "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
                            });
                          }
                        },
                        child: AbsorbPointer(
                          child: CustomTextField(
                            controller: caEndDateController,
                            obscureText: false,
                            validator: (value) => value == null || value.isEmpty
                                ? '종료 날짜를 선택해주세요.'
                                : null,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              onPressed: () {
                if (!formKey.currentState!.validate()) return;

                DateTime? startDate = DateTime.tryParse(caStartDateController.text);
                DateTime? endDate = DateTime.tryParse(caEndDateController.text);

                if (startDate != null && endDate != null && endDate.isBefore(startDate)) {
                  setState(() {
                    errorMsg = '종료 날짜는 시작 날짜 이후여야 합니다.';
                  });
                  return;
                }

                Navigator.pop(context);
                careerRegister(); // 서버 전송
              },
            );
          },
        );
      },
    );
  }

  // 탈퇴하기
  void CustomDeleteDialog(BuildContext context) {
    final _formKey = GlobalKey<FormState>();
    TextEditingController _deletePwdController = TextEditingController();

    void onDelete() async {
      try {
        final String dpwd = _deletePwdController.text;
        final prefs = await SharedPreferences.getInstance();
        final token = prefs.getString('token');

        dio.options.headers['Authorization'] = token;
        final response = await dio.put("${serverPath}/api/developer/delete",
          options: Options(
              headers: { 'Authorization': token, 'Content-Type': 'text/plain',},
              responseType: ResponseType.plain),
          data: dpwd,
        );
        final data = response.data;
        print(data);
        if ( data.toString().toLowerCase() == "true" ) {
          await prefs.remove('token');
          Navigator.pop(context);

          showDialog(
            barrierDismissible: false,
            context: context,
            builder: (context) => CustomBoolAlertDialog(
              title: "탈퇴 완료",
              content: Text("이용해주셔서 감사합니다."),
              onPressed: () {
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => MainApp() ) );
              },
            )
          );
        }
      } catch (e) {
        print(e);
      }
    }

    showDialog(
      barrierDismissible: false, // 바깥 영역 터치시 창닫기 x
      context: context,
      builder: (context) => CustomAlertDialog(
        title: "정말 탈퇴하시겠습니까?",
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("비밀번호를 입력해주세요."),
            SizedBox( height: 7,),
            CustomTextField(
              controller: _deletePwdController,
              obscureText: true,
            ),
          ],
        ),
        onPressed: onDelete
      )
    );
  }
  
  @override
  Widget build(BuildContext context) {

    if( developer.isEmpty ){ return Center( child: CircularProgressIndicator(), ); }

    final image = developer['dprofile'];
    String imgUrl = "${serverPath}/upload/${image}";

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
                          profileImage = null;
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
                CustomTextField( controller: didController, readOnly: true, ),
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

                    CustomTextButton(
                      title: "저장",
                      onPressed: () => CustomUpdateDialog(context)
                    ),

                  ],
                )
              ]

          ),
        ),
        SizedBox( height: 30,),

        // 두번째 Card
        Text("비밀번호", style: TextStyle( fontSize: 18, fontWeight: FontWeight.bold, ), ),
        SizedBox( height: 15 ,),
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
                    onPressed: () => CustomPwdDialog(context),
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
              SizedBox( height: 8,),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: getTechStacks.isEmpty ? [ Text("기술스택을 등록해주세요.") ]
                  : getTechStacks.map<Widget>((data) {
                  return Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.blue[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      data['tsname'],
                      style: TextStyle(color: Colors.black54),
                    ),
                  );
                }).toList(),
              ),
              SizedBox( height: 8,),

              // 버튼
              Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    CustomOutlineButton(
                      onPressed: () => { showTechStackDialog() },
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
              SizedBox( height: 8,),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: careerList.isEmpty ? [ Text("경력을 등록해주세요.") ]
                  : careerList.map<Widget>((data) {
                  return Container(
                    margin: EdgeInsets.symmetric(vertical: 4), // Optional: 항목 간 간격
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.blue[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(data["cacompany"], style: TextStyle( fontWeight: FontWeight.bold, fontSize: 20 ),),
                            Text("${data["caStartDate"]} ~ ${data["caEndDate"]}"),
                          ],
                        ),
                        IconButton(onPressed: () => {}, icon: Icon( Icons.update ) ),
                        IconButton(onPressed: () => {}, icon: Icon( Icons.delete_forever_outlined )),
                      ],
                    )
                  );
                }).toList(),
              ),
              SizedBox( height: 8,),

              // 버튼
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  CustomOutlineButton(
                    onPressed: () => {
                      setState(() {
                        cacompanyController = TextEditingController( text: "" );
                        caStartDateController = TextEditingController( text: "" );
                        caEndDateController = TextEditingController( text: "" );
                      }),
                      careerDialog()
                    },
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
                      onPressed: () => CustomDeleteDialog(context),
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