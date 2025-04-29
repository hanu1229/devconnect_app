// project_update.dart : 프로젝트 수정 페이지

import "package:flutter/material.dart";

class UpdateProject extends StatefulWidget {

  @override
  State<UpdateProject> createState() => _UpdateProjectState();

}

class _UpdateProjectState extends State<UpdateProject> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar : AppBar(
        title : Text("프로젝트 수정"),
      ),
    );
  }

}
