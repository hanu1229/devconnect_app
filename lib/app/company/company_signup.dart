


import 'package:flutter/material.dart';

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
  TextEditingController cprofileController = TextEditingController();





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
                    controller: cidController,
                    decoration: InputDecoration(
                      labelText: "id",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(height: 20),
                  TextField(
                    controller: cpwdController,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: "비밀번호",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(height: 20),
                  TextField(
                    controller: cphoneController,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: "회사번호",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(height: 20),
                  TextField(
                    controller: cadressController,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: "회사주소",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(height: 20),
                  TextField(
                    controller: cemailController,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: "회사이메일",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(height: 20),
                  TextField(
                    controller: cbusinessController,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: '사업자 등록번호',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(height: 20),
                  TextField(
                    controller: cprofileController,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: '프로필',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {},
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.resolveWith<Color>(
                            (Set<MaterialState> states) {
                          if (states.contains(MaterialState.pressed)) {
                            return Colors.blue.shade700;
                          }
                          return Colors.blue;
                        },
                      ),
                      shape: MaterialStateProperty.all<OutlinedBorder>(
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