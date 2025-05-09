import 'package:devconnect_app/style/app_colors.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final int maxLines;
  final bool readOnly;
  final bool obscureText;
  final String? Function(String?)? validator;
  final String? errorText;

  const CustomTextField({
    required this.controller,
    this.maxLines = 1,
    this.readOnly = false,
    this.obscureText = false,
    this.validator,
    this.errorText,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double? focusWidth = readOnly ? 1.5 : 3;
    Color? focusColor = readOnly ? AppColors.textFieldColor : AppColors.focusColor;

    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      readOnly: readOnly,
      obscureText: obscureText,
      validator: validator,
      decoration: InputDecoration(
        errorText: errorText,
        errorBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: Colors.red,
            width: 3
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderSide: BorderSide(
              color: AppColors.focusColor,
              width: 3
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        filled: true,
        fillColor: AppColors.textFieldBGColor,
        contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            width: 1.5,
            color: AppColors.textFieldColor,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            width: focusWidth,
            color: focusColor,
          ),
        ),
      ),
    );
  }
}
