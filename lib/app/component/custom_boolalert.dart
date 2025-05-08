import 'package:devconnect_app/app/component/custom_outlinebutton.dart';
import 'package:devconnect_app/app/component/custom_textbutton.dart';
import 'package:flutter/material.dart';

class CustomBoolAlertDialog extends StatelessWidget {
  final double width;
  final String title;
  final bool onCancleBtn;
  final Widget? content;
  final VoidCallback? onPressed;

  const CustomBoolAlertDialog({
    this.width = 200,
    this.content,
    this.onPressed,
    this.onCancleBtn = false,
    required this.title,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder( borderRadius: BorderRadius.circular(10) ),
      title: Text(title,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 16
        ),
      ),
      content: SizedBox(
        width: width,
        child: content,
      ),
      actions: onCancleBtn
        ? [
          CustomOutlineButton(
            onPressed: () => Navigator.pop(context),
            title: "취소",
          ),
          CustomTextButton(
            onPressed: onPressed!,
            title: "확인",
          ),
        ]
      : [
        CustomTextButton(
          onPressed: () => onPressed,
        title: "확인",
        ),
        ],
    );
  }
}
