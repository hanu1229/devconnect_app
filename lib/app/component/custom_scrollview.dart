import 'package:flutter/material.dart';

class CustomSingleChildScrollview extends StatelessWidget {
  final EdgeInsets padding;
  final Color color;
  final List<Widget> children;

  const CustomSingleChildScrollview({
    this.padding = const EdgeInsets.all( 20 ),
    this.color = const Color( 0xfffbfbfb ),
    required this.children,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: MediaQuery.of( context ).size.height * 0.7
          ),
          child: Column(
            children: [
              Container(
                padding: padding,
                color: color,
                width: double.infinity,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: children,
                )
              )
            ],
          ),
        ),
      ),
    );
  }
}