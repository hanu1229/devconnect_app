// project_update.dart : 프로젝트 수정 페이지

import "package:flutter/material.dart";

class UpdateProject extends StatefulWidget {
  Map<String, dynamic> project = {};

  UpdateProject({super.key, required this.project});

  @override
  State<UpdateProject> createState() => _UpdateProjectState();

}

class _UpdateProjectState extends State<UpdateProject> {

  @override
  void initState() {
    super.initState();
    print(widget.project);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar : AppBar(
        title : Text("프로젝트 수정"),
      ),
      body : SingleChildScrollView(
        child : Container(
          width : MediaQuery.of(context).size.width,
          child : Column(
            children : [
              Text("테스트1"),
              Text("테스트2"),
              Text("테스트3"),
              Text("테스트4"),
            ],
          ),
        ),
      ),
    );
  }

}
