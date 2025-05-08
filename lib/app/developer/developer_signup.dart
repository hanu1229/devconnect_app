


import 'dart:io';
import 'dart:math';

import 'package:devconnect_app/app/component/custom_card.dart';
import 'package:devconnect_app/app/component/custom_imgpicker.dart';
import 'package:devconnect_app/app/component/custom_outlinebutton.dart';
import 'package:devconnect_app/app/component/custom_scrollview.dart';
import 'package:devconnect_app/app/component/custom_textbutton.dart';
import 'package:devconnect_app/app/component/custom_textfield.dart';
import 'package:devconnect_app/app/util/services.dart';
import 'package:devconnect_app/style/server_path.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class DeveloperSignUp extends StatefulWidget{
  final Function(int) changePage;

  const DeveloperSignUp({
    required this.changePage,
  });

  @override
  _DeveloperSignUp createState() {
    return _DeveloperSignUp();
  }
}

class _DeveloperSignUp extends State< DeveloperSignUp >{
  Dio dio = Dio();
  final _formKey = GlobalKey<FormState>();

  // 입력 컨트롤러
  TextEditingController didController = TextEditingController();
  TextEditingController dpwdController = TextEditingController();
  TextEditingController dnameController = TextEditingController();
  TextEditingController dphoneController= TextEditingController();
  TextEditingController demailController = TextEditingController();
  TextEditingController daddressController = TextEditingController();
  TextEditingController dfileController = TextEditingController();

  // 이미지 변수
  XFile? profileImage;

  //회원가입 함수
  void onSignup() async {
    try{
      FormData formData = FormData();
      formData.fields.add( MapEntry( "did", didController.text ));
      formData.fields.add( MapEntry( "dpwd", dpwdController.text ));
      formData.fields.add( MapEntry( "dname", dnameController.text ));
      formData.fields.add( MapEntry( "dphone", dphoneController.text ));
      formData.fields.add( MapEntry( "demail", demailController.text ));
      formData.fields.add( MapEntry( "daddress", daddressController.text ));

      final file = await MultipartFile.fromFile( profileImage!.path, filename: profileImage!.name );
      if( file != null ){ formData.files.add( MapEntry( "dfile", file )); }

      final response = await dio.post("${serverPath}/api/developer/signup", data: formData);
      if( response.statusCode == 201 && response.data == true ){
        Navigator.pop(context);
        widget.changePage(6);
      }else{ print("회원가입 실패"); }
    }catch( e ){ print( e ); }
  } // f end

  // 정규식 유효성 검사
  // 아아디
  String? idValidator(String? value) {
    final idReg = RegExp(r'^(?=.*[a-zA-Z])(?=.*\d)[a-zA-Z0-9]{6,20}$');
    if ( value == null || value.isEmpty ) {
      return '아이디를 입력해주세요';
    } else if ( !idReg.hasMatch(value) ) {
      return '아이디는 영어, 숫자를 모두 포함한 6~20자여야 합니다.';
    }
    return null;
  }

  // 비밀번호
  String? pwdValidator(String? value) {
    final passwordReg = RegExp(r'^(?=.*[A-Za-z])(?=.*\d)(?=.*[!@#$%^&*()_+=-]).{8,20}$');
    if (value == null || value.isEmpty) {
      return '비밀번호를 입력해주세요';
    } else if (!passwordReg.hasMatch(value)) {
      return '비밀번호는 영문, 숫자, 특수문자를 모두 포함한 6~20자여야 합니다';
    }
    return null;
  }

  // 전화번호
  String? phoneValidator(String? value) {
    final phoneReg = RegExp(r'^01[0|1|6-9]-\d{3,4}-\d{4}$');
    if (value == null || value.isEmpty) {
      return '전화번호를 입력해주세요';
    } else if (!phoneReg.hasMatch(value)) {
      return '유효한 전화번호 형식이 아닙니다. (예: 010-1234-5678)';
    }
    return null;
  }

  // 이름
  String? nameValidator(String? value) {
    final nameRegex = RegExp(r'^[가-힣]{2,5}$');
    if (value == null || value.isEmpty) {
      return '이름을 입력해주세요';
    } else if (!nameRegex.hasMatch(value)) {
      return '이름은 한글 2~5자로 입력해주세요';
    }
    return null;
  }

  // 이메일
  String? emailValidator(String? value) {
    final emailReg = RegExp(r'^[\w\.-]+@[\w\.-]+\.\w{2,}$');
    if (value == null || value.isEmpty) {
      return '이메일을 입력해주세요';
    } else if (!emailReg.hasMatch(value)) {
      return '유효한 이메일 형식이 아닙니다';
    }
    return null;
  }

  // 주소
  String? addressValidator(String? value) {
    final addressReg = RegExp(r'^[가-힣]{2,10}\s[가-힣]{2,10}\s[가-힣]{2,10}동$');
    if (value == null || value.trim().isEmpty) {
      return '주소를 입력해주세요';
    } else if (!addressReg.hasMatch(value.trim())) {
      return '주소는 "시/도 구/군 동" 형식으로 입력해주세요 (예: 서울특별시 강남구 역삼동)';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return CustomSingleChildScrollview(
      minHeight: 1,
      padding: EdgeInsets.fromLTRB( 30, 60, 30, 70 ),
      color: Colors.blueAccent,
      children: [ CustomCard(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              Center(
                child: Text("개발자 회원가입",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox( height: 15, ),

              Text("아이디", style: TextStyle( fontWeight: FontWeight.bold ),),
              SizedBox( height: 7, ),
              CustomTextField(
                  controller: didController,
                  validator: (value) => idValidator(value)
              ),
              SizedBox( height: 12, ),

              Text("비밀번호", style: TextStyle( fontWeight: FontWeight.bold ),),
              SizedBox( height: 7, ),
              CustomTextField( 
                controller: dpwdController,
                obscureText: true,
                validator: (value) => pwdValidator(value),
              ),
              SizedBox( height: 12, ),

              Text("이름", style: TextStyle( fontWeight: FontWeight.bold ),),
              SizedBox( height: 7, ),
              CustomTextField( 
                controller: dnameController,
                validator: (value) => nameValidator(value),
              ),
              SizedBox( height: 12, ),

              Text("전화번호", style: TextStyle( fontWeight: FontWeight.bold ),),
              SizedBox( height: 7, ),
              CustomTextField( 
                controller: dphoneController,
                keyboardType: TextInputType.phone,
                inputFormatters: [ PhoneNumberFormatter() ],
                validator: (value) => phoneValidator(value),
              ),
              SizedBox( height: 12, ),

              Text("이메일", style: TextStyle( fontWeight: FontWeight.bold ),),
              SizedBox( height: 7, ),
              CustomTextField( 
                controller: demailController,
                validator: (value) => emailValidator(value),
              ),
              SizedBox( height: 12, ),

              Text("주소", style: TextStyle( fontWeight: FontWeight.bold ),),
              SizedBox( height: 7, ),
              CustomTextField(
                controller: daddressController,
                validator: (value) => addressValidator(value),
              ),
              SizedBox( height: 12, ),

              // 이미지 선택
              Center(
                child: CustomImagePicker(
                  onImageSelected: ( XFile image ) {
                    setState(() {
                      profileImage = image;
                    });
                  },
                ),
              ),
              SizedBox(height: 15),

              CustomTextButton(
                onPressed: () {
                  if( _formKey.currentState!.validate() ){
                    onSignup();
                  }
                },
                title: "회원가입",
                width: double.infinity,
              ),
              SizedBox(height: 10),

              CustomOutlineButton(
                onPressed: () => {
                  Navigator.pop(context),
                  widget.changePage(6),
                },
                title: "취소",
                width: double.infinity,
              ),
            ],
          )
        )
      )],
    );
  }
}