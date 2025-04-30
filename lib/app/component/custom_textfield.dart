
import 'package:devconnect_app/style/app_colors.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final bool readOnly;

  const CustomTextField({
    required this.controller,
    this.readOnly = false,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double? focusWidth = readOnly ? 1.5 : 3;
    Color? focusColor = readOnly ? AppColors.textFieldColor : AppColors.focusColor;

    return TextField(
      controller: controller,
      readOnly: readOnly,
      decoration: InputDecoration(
        filled: true,
        fillColor: AppColors.textFieldBGColor,
        contentPadding: EdgeInsets.symmetric( vertical: 12, horizontal: 16 ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular( 8 ),
          borderSide: BorderSide(
            width: 1.5,
            color: AppColors.textFieldColor,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular( 8 ),
          borderSide: BorderSide(
            width: focusWidth,
            color: focusColor,
          ),
        ),
      ),
    );
  }
}