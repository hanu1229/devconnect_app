


import 'dart:io';

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
  TextEditingController cidController = TextEditingController();
  TextEditingController cpwdController = TextEditingController();
  TextEditingController cnameController = TextEditingController();
  TextEditingController cphoneController= TextEditingController();
  TextEditingController cadressController = TextEditingController();
  TextEditingController cemailController = TextEditingController();
  TextEditingController cbusinessController = TextEditingController();

  File? profileImage;   // 이미지 변수
  final ImagePicker _picker = ImagePicker(); //이미지 피커

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery); // 갤러리에서 이미지 선택
    if (image != null) {
      setState(() {
        profileImage = File(image.path);
      });
    }
  }

  // //회원가입 함수
  // Future<void> onSignup() async {
  //     if
  //   });
  //
  //   try{
  //     Dio dio = Dio();
  //
  //   }catch(e){print(e);}
  //
  //
  // }



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
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: "비밀번호",
                      border: OutlineInputBorder(),
                    ),
                  ),

                  SizedBox(height: 20),

                  TextField(
                    controller: cphoneController, // 회사번호 입력 컨트롤러
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: "회사번호",
                      border: OutlineInputBorder(),
                    ),
                  ),

                  SizedBox(height: 20),

                  TextField(
                    controller: cadressController, // 회사주소 입력 컨트롤러 API 연결 확인 필요
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: "회사주소",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(height: 20),

                  TextField(
                    controller: cemailController,  // 이메일 입력 컨트롤러
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: "회사이메일",
                      border: OutlineInputBorder(),
                    ),
                  ),

                  SizedBox(height: 20),

                  TextField(
                    controller: cbusinessController,  // 사업자 등록 입력 컨트롤러 API 사용 고려하기
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: '사업자 등록번호',
                      border: OutlineInputBorder(),
                    ),
                  ),

                  SizedBox(height: 20),

                  // 이미지 선택 UI
                  GestureDetector(
                    onTap: _pickImage,   //이미지 입력
                    child: Container(
                      height: 100,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: _profileImage != null
                          ? Image.file(
                        _profileImage!,
                        width: double.infinity,
                        height: double.infinity,
                        fit: BoxFit.cover,
                      )
                          : Center(
                        child: Text("프로필 이미지 선택"),
                      ),
                    ),
                  ),

                  SizedBox(height: 20),

                  ElevatedButton(
                    onPressed: () {},
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
                    child: Text(
                      "회원가입",
                      style: TextStyle(color: Colors.black),
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