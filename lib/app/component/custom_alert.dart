import 'package:devconnect_app/app/component/custom_outlinebutton.dart';
import 'package:devconnect_app/app/component/custom_textbutton.dart';
import 'package:flutter/material.dart';

class CustomAlertDialog extends StatelessWidget {
  final double width;
  final String btnTitle;
  final String title;
  final Widget content;
  final VoidCallback onPressed;

  const CustomAlertDialog({
    this.width = 200,
    this.btnTitle = "확인",
    required this.title,
    required this.content,
    required this.onPressed,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder( borderRadius: BorderRadius.circular(10) ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
          SizedBox(height: 7),
          Divider(),
        ],
      ),
      content: SizedBox(
        width: width,
        child: content,
      ),
      actions: [
        CustomOutlineButton(
          onPressed: () => Navigator.pop(context),
          title: "취소",
        ),
        CustomTextButton(
          onPressed: onPressed,
          title: btnTitle,
        ),
      ],
    );
  }
}
