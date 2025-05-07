
import 'package:flutter/material.dart';

class CompanyAppraise extends StatefulWidget{
  final Function(int) changePage;

  const CompanyAppraise({
    required this.changePage,
});

  @override
  _CompanyAppraise createState() {
    return _CompanyAppraise();
  }

}

class _CompanyAppraise extends State<CompanyAppraise>{
  @override
  Widget build(BuildContext context) {
    return Text("appraise");
  }
}