// 비밀번호 변경 다이얼로그
import 'package:devconnect_app/app/component/custom_textfield.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

void CustomPwdDialog(BuildContext context) {
  final TextEditingController _prevPwdController = TextEditingController();
  final TextEditingController _pwdController = TextEditingController();
  final TextEditingController _confirmPwdController = TextEditingController();

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        backgroundColor: Colors.white,
        title: Text("비밀번호 변경"),
        content: SizedBox(
          width: 200,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("비밀번호 확인"),
              SizedBox( height: 7,),
              CustomTextField(
                controller: _prevPwdController,
                obscureText: true,
              ),
              SizedBox( height: 10,),

              Text("비밀번호 확인"),
              SizedBox( height: 7,),
              CustomTextField(
                controller: _pwdController,
                obscureText: true,
              ),
              SizedBox( height: 10,),

              Text("비밀번호 확인"),
              SizedBox( height: 7,),
              CustomTextField(
                controller: _confirmPwdController,
                obscureText: true,
              ),
              SizedBox( height: 10,),

            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // 닫기
            },
            child: Text("취소"),
          ),
          ElevatedButton(
            onPressed: () {
              // 비밀번호 검증 및 처리 로직
            },
            child: Text("확인"),
          ),
        ],
      );
    },
  );
}
