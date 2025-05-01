



import 'dart:core';
import 'dart:io';

import 'package:devconnect_app/app/layout/home.dart';
import 'package:devconnect_app/style/server_path.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class Signup extends StatefulWidget{
  @override
  State<StatefulWidget> createState() {
    return _SignupState();
  }
}

class _SignupState extends State<Signup>{

  // 입력 컨트롤러
   final TextEditingController cidController = TextEditingController();
   final TextEditingController cpwdController = TextEditingController();
   final TextEditingController cnameController = TextEditingController();
   final TextEditingController cphoneController= TextEditingController();
   final TextEditingController cadressController = TextEditingController();
   final TextEditingController cemailController = TextEditingController();
   final TextEditingController cbusinessController = TextEditingController();
   Dio dio = Dio();
   XFile? selectedimage;

   // 이미지 피커 사용자의 파일을 플러터로 가져오기
   
   void onSelectimage() async {
     try{
       ImagePicker picker =ImagePicker();
       final XFile? pickedFile = await picker.pickImage(source: ImageSource.gallery);//이미지 피커 객체 생성 , 이미지 여러개
       if(pickedFile != null){
         setState(() {
           selectedimage = pickedFile;
         });
       }

     }catch(e){print(e);}
   }

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
       if(selectedimage != null){
         final file = await MultipartFile.fromFile(selectedimage!.path , filename: selectedimage!.name);
         formData.files.add(MapEntry("cprofile", file));

         //Dio 요청
         final response = await dio.post("${serverPath}/api/company/signup" , data: formData);

         if(response.statusCode == 201 && response.data == true){print("회원가입완료"); Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => Home()));
         } else{
           print("회원가입 실패 또는 응답 오류: ${response.statusCode}");
         }
       }
     }catch(e){print(e);}
   }

   //이미지 미리보기 함수
   Widget ImagePreview(){
     if(selectedimage == null){return SizedBox.shrink();}
     return Container(
       child: Image.file(
           File(selectedimage!.path), // 선택된 이미지 파일의 경로를 사용하여 이미지 표시
         fit: BoxFit.contain, // 컨테이너 안에서 이미지가 어떻게 보일지 설정 (꽉 채우거나 비율 유지 등)
         width: 130,
         height: 130,
       ),
     );
   }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue,
      body: Padding( // Container 대신 Padding을 사용하여 전체 여백 적용
        padding: EdgeInsets.fromLTRB(30, 50, 30, 120),
        child: ListView( // Column 대신 ListView 사용
          padding: EdgeInsets.only(top: 20, bottom: 20), // ListView 내부 여백 조절 (선택 사항)
          children: [
            Container( // 흰색 배경의 컨테이너
              margin: EdgeInsets.fromLTRB(0, 20, 0, 20), // 내부 여백 조정
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              padding: EdgeInsets.all(30), // 내부 패딩
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch, // 자식들을 가로축으로 늘림
                children: [
                  TextField(
                    controller: cidController, // 아이디 입력 컨트롤러
                    decoration: InputDecoration(
                      labelText: "id",
                      border: OutlineInputBorder(),
                    ),
                  ),

                  SizedBox(height: 20),

                  TextField(
                    controller: cpwdController, // 비밀번호 입력 컨트롤러
                    obscureText: true, // 번호 숨기기
                    decoration: InputDecoration(
                      labelText: "비밀번호",
                      border: OutlineInputBorder(),
                    ),
                  ),

                  SizedBox(height: 20),

                  TextField(
                    controller: cphoneController, // 회사번호 입력 컨트롤러
                    decoration: InputDecoration(
                      labelText: "회사번호",
                      border: OutlineInputBorder(),
                    ),
                  ),

                  SizedBox(height: 20),

                  TextField(
                    controller: cadressController, // 회사주소 입력 컨트롤러 API 연결 확인 필요
                    decoration: InputDecoration(
                      labelText: "회사주소",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(height: 20),

                  TextField(
                    controller: cemailController,  // 이메일 입력 컨트롤러
                    decoration: InputDecoration(
                      labelText: "회사이메일",
                      border: OutlineInputBorder(),
                    ),
                  ),

                  SizedBox(height: 20),

                  TextField(
                    controller: cbusinessController,  // 사업자 등록 입력 컨트롤러 API 사용 고려하기
                    decoration: InputDecoration(
                      labelText: '사업자 등록번호',
                      border: OutlineInputBorder(),
                    ),
                  ),

                  SizedBox(height: 20),

                  // 이미지 선택 UI
                  TextButton.icon(
                      icon: Icon(Icons.add_a_photo),
                      label: Text("이미지선택"),
                      onPressed: onSelectimage),
                      ImagePreview(),

                  SizedBox(height: 20),

                  ElevatedButton(
                    onPressed: onSignup, // 회원가입 연결 함수
                    style: ButtonStyle(
                      backgroundColor: WidgetStateProperty.resolveWith<Color>(
                            (Set<WidgetState> states) {
                          if (states.contains(WidgetState.pressed)) {
                            return Colors.blue.shade700;
                          }
                          return Colors.blue;
                        },
                      ),
                      shape: WidgetStateProperty.all<OutlinedBorder>(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
                    ),
                    child: Text("회원가입",style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}