

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CustomTextButton extends StatelessWidget {
  final double width;
  final VoidCallback onPressed;
  final Color color;
  final String title;

  const CustomTextButton({
    this.width = 80,
    this.color = Colors.blueAccent,
    required this.onPressed,
    required this.title,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width, height: 45,
      child: TextButton(
        onPressed: onPressed,
        style: TextButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular( 5 ),
          ),
        ),
        child: Text(title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: Colors.white
          ),
        ),
      ),
    );
  }
}