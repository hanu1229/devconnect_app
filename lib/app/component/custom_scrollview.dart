import 'package:flutter/material.dart';

class CustomSingleChildScrollview extends StatelessWidget {
  final double minHeight;
  final EdgeInsets padding;
  final Color color;
  final List<Widget> children;
  final AppBar? appBar;

  const CustomSingleChildScrollview({
    this.appBar,
    this.minHeight = 0.7,
    this.padding = const EdgeInsets.all( 20 ),
    this.color = const Color( 0xfffbfbfb ),
    required this.children,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar,
      resizeToAvoidBottomInset : false,
      body: SingleChildScrollView(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: minHeight,
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