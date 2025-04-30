import 'package:devconnect_app/style/app_colors.dart';
import 'package:flutter/material.dart';

class CustomCard extends StatelessWidget {
  final double elevation;
  final Widget child;

  const CustomCard({
    required this.child,
    this.elevation = 0,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(
            width: 1,
            color: AppColors.cardBorderColor,
          ),
        ),
        elevation: elevation,
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: child,
        ),
      ),
    );
  }
}
