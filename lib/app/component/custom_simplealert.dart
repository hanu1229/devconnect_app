import 'package:devconnect_app/app/component/custom_outlinebutton.dart';
import 'package:devconnect_app/app/component/custom_textbutton.dart';
import 'package:flutter/material.dart';

class CustomBoolAlertDialog extends StatelessWidget {
  final double width;
  final String title;
  final Widget? content;
  final VoidCallback? onPressed;

  const CustomBoolAlertDialog({
    this.width = 200,
    this.content,
    this.onPressed,
    required this.title,
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
      actions: onPressed != null
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
        CustomOutlineButton(
          onPressed: () => Navigator.pop(context),
        title: "확인",
        ),
        ],
    );
  }
}
