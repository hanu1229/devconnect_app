


import 'dart:io';
import 'dart:math';

import 'package:devconnect_app/app/component/custom_card.dart';
import 'package:devconnect_app/app/component/custom_imgpicker.dart';
import 'package:devconnect_app/app/component/custom_outlinebutton.dart';
import 'package:devconnect_app/app/component/custom_scrollview.dart';
import 'package:devconnect_app/app/component/custom_textbutton.dart';
import 'package:devconnect_app/app/component/custom_textfield.dart';
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
      formData.files.add( MapEntry( "dfile", file ));

      final response = await dio.post("${serverPath}/api/developer/signup", data: formData);
      if( response.statusCode == 201 && response.data == true ){
        Navigator.pop(context);
        widget.changePage(6);
      }else{ print("회원가입 실패"); }
    }catch( e ){ print( e ); }
  } // f end

  @override
  Widget build(BuildContext context) {
    return CustomSingleChildScrollview(
      minHeight: 1,
      padding: EdgeInsets.fromLTRB( 30, 60, 30, 70 ),
      color: Colors.blueAccent,
      children: [ CustomCard(
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
            CustomTextField( controller: didController ),
            SizedBox( height: 12, ),

            Text("비밀번호", style: TextStyle( fontWeight: FontWeight.bold ),),
            SizedBox( height: 7, ),
            CustomTextField( controller: dpwdController ),
            SizedBox( height: 12, ),

            Text("이름", style: TextStyle( fontWeight: FontWeight.bold ),),
            SizedBox( height: 7, ),
            CustomTextField( controller: dnameController ),
            SizedBox( height: 12, ),

            Text("전화번호", style: TextStyle( fontWeight: FontWeight.bold ),),
            SizedBox( height: 7, ),
            CustomTextField( controller: dphoneController ),
            SizedBox( height: 12, ),

            Text("이메일", style: TextStyle( fontWeight: FontWeight.bold ),),
            SizedBox( height: 7, ),
            CustomTextField( controller: demailController ),
            SizedBox( height: 12, ),

            Text("주소", style: TextStyle( fontWeight: FontWeight.bold ),),
            SizedBox( height: 7, ),
            CustomTextField( controller: daddressController ),
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
              onPressed: onSignup,
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
      )],
    );
  }
}