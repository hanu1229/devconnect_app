



import 'dart:core';
import 'dart:io';

import 'package:devconnect_app/app/layout/company_main_app.dart';
import 'package:devconnect_app/app/layout/home.dart';
import 'package:devconnect_app/app/layout/main_app.dart';
import 'package:devconnect_app/style/server_path.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../component/custom_card.dart';
import '../component/custom_imgpicker.dart';
import '../component/custom_outlinebutton.dart';
import '../component/custom_scrollview.dart';
import '../component/custom_textbutton.dart';
import '../component/custom_textfield.dart';
import '../util/services.dart';

class Signup extends StatefulWidget{
  @override
  State<StatefulWidget> createState() {
    return _SignupState();
  }
}

class _SignupState extends State<Signup>{

  final _formKey = GlobalKey<FormState>();

  // 입력 컨트롤러
   final TextEditingController cidController = TextEditingController();
   final TextEditingController cpwdController = TextEditingController();
   final TextEditingController cnameController = TextEditingController();
   final TextEditingController cphoneController= TextEditingController();
   final TextEditingController cadressController = TextEditingController();
   final TextEditingController cemailController = TextEditingController();
   final TextEditingController cbusinessController = TextEditingController();
   Dio dio = Dio();

   //이미지 변수
   XFile? selectedimage;


   // 등록함수
   void onSignup() async {
     try{
       //폼데이터 구성
       FormData formData = FormData();
       formData.fields.add(MapEntry("cid", cidController.text));
       formData.fields.add(MapEntry("cpwd", cpwdController.text));
       formData.fields.add(MapEntry("cname", cnameController.text));
       formData.fields.add(MapEntry("cphone", cphoneController.text));
       formData.fields.add(MapEntry("cadress", cadressController.text));
       formData.fields.add(MapEntry("cemail", cemailController.text));
       formData.fields.add(MapEntry("cbusiness", cbusinessController.text));

       //이미지 담기

         final file = await MultipartFile.fromFile(selectedimage!.path , filename: selectedimage!.name);
         if(file != null){formData.files.add(MapEntry("file", file));}

         //Dio 요청
         final response = await dio.post("${serverPath}/api/company/signup" , data: formData);

         if(response.statusCode == 201 && response.data == true){print("회원가입완료"); Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => CompanyMainApp()));
         } else{
           print("회원가입 실패 또는 응답 오류: ${response.statusCode}");
         }

     }catch(e){print(e);}
   }

   //아이디
   String? idfact(String? value){
     final idcheck = RegExp(r'^(?=.*[a-zA-Z])(?=.*\d)[a-zA-Z0-9]{6,20}$');
     if ( value == null || value.isEmpty ) {
       return '아이디를 입력해주세요';
     } else if ( !idcheck.hasMatch(value) ) {
       return '아이디는 영어, 숫자를 모두 포함한 6~20자여야 합니다.';
     }
     return null;
   }

  // 비밀번호
  String? pwdfact(String? value) {
    final passworcheck = RegExp(r'^(?=.*[A-Za-z])(?=.*\d)(?=.*[!@#$%^&*()_+=-]).{8,20}$');
    if (value == null || value.isEmpty) {
      return '비밀번호를 입력해주세요';
    } else if (!passworcheck.hasMatch(value)) {
      return '비밀번호는 영문, 숫자, 특수문자를 모두 포함한 6~20자여야 합니다';
    }
    return null;
  }


// 전화번호 유효성 검사 함수 (모바일 및 지역 번호 포함, 하이픈 주변 공백 허용)
  String? phonefact(String? value) {

    if (value == null || value.isEmpty) {
      return '전화번호를 입력해주세요';
    }
    final phonecheck = RegExp(r'^(01[0|1|6-9]|0\d{1,2})\s*-\s*\d{3,4}\s*-\s*\d{4}$');

    if (!phonecheck.hasMatch(value)) {
      return '유효한 전화번호 형식이 아닙니다. (예: 010-1234-5678, 032-123-4567, 010- 1234- 5678)';
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

// 주소 유효성 검사 함수
  String? addressfact(String? value) {

    if (value == null || value.trim().isEmpty) {
      return '주소를 입력해주세요'; // 비어있다면 오류 메시지 반환
    }
    final addresscheck = RegExp(r'^[가-힣0-9-]+(?:\s[가-힣0-9-]+)+$'); // ?: 는 그룹을 만들지만 캡처하지 않음 (성능 미미한 향상)
    if (!addresscheck.hasMatch(value.trim())) {
      return '유효한 주소 형식이 아닙니다. (예: 서울 금천구 가산디지털1로 171)';
    }
    return null;
  }

  String? businessNumberValidator(String? value) {
    if (value == null || value.isEmpty) {
      return '사업자 등록번호를 입력해주세요.'; // 비어있다면 오류 메시지 반환
    }
    final businessNumberRegex = RegExp(r'^\d{3}-\d{2}-\d{5}$');
    if (!businessNumberRegex.hasMatch(value)) {
      return '유효한 사업자 등록번호 형식이 아닙니다.\n(예: 123-45-67890)';
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
                    child: Text("기업 회원가입",
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
                      controller: cidController,
                      validator: (value) => idfact(value)
                  ),
                  SizedBox( height: 12, ),

                  Text("비밀번호", style: TextStyle( fontWeight: FontWeight.bold ),),
                  SizedBox( height: 7, ),
                  CustomTextField(
                    controller: cpwdController,
                    obscureText: true,
                    validator: (value) => pwdfact(value),
                  ),
                  SizedBox( height: 12, ),

                  Text("회사명", style: TextStyle( fontWeight: FontWeight.bold ),),
                  SizedBox( height: 7, ),
                  CustomTextField(
                    controller: cnameController,
                  ),
                  SizedBox( height: 12, ),

                  Text("회사 전화번호", style: TextStyle( fontWeight: FontWeight.bold ),),
                  SizedBox( height: 7, ),
                  CustomTextField(
                    controller: cphoneController,
                    keyboardType: TextInputType.phone,
                    validator: (value) => phonefact(value),
                  ),
                  SizedBox( height: 12, ),

                  Text("이메일", style: TextStyle( fontWeight: FontWeight.bold ),),
                  SizedBox( height: 7, ),
                  CustomTextField(
                    controller: cemailController,
                    validator: (value) => emailValidator(value),
                    hintText : "OOOO@example.com",
                  ),
                  SizedBox( height: 12, ),

                  Text("주소", style: TextStyle( fontWeight: FontWeight.bold ),),
                  SizedBox( height: 7, ),
                  CustomTextField(
                    controller: cadressController,
                    validator: (value) => addressfact(value),
                    hintText : "인천시 부평구 갈산동 ...",
                  ),
                  SizedBox( height: 12, ),

                  Text("사업자번호", style: TextStyle( fontWeight: FontWeight.bold ),),
                  SizedBox( height: 7, ),
                  CustomTextField(
                    controller: cbusinessController,
                    validator: (value) => businessNumberValidator(value),
                    hintText : "000-00-00000",
                  ),
                  SizedBox( height: 12, ),

                  // 이미지 선택
                  Center(
                    child: CustomImagePicker(
                      onImageSelected: ( XFile image ) {
                        setState(() {
                          selectedimage = image;
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
                      Navigator.push(context, MaterialPageRoute(builder: (context) => MainApp())),
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