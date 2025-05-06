
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CompanyProject extends StatefulWidget{
  final Function(int) changePage;
  
  const CompanyProject({
    required this.changePage,
});
  
  @override
  State<StatefulWidget> createState() {
    return _CompanyProject();
  }
  
}


//프로젝트 기본틀
class _CompanyProject extends State<CompanyProject>{
  Dio dio = Dio();

  @override
  Widget build(BuildContext context) {
    return Text("projectPage");
  }
}