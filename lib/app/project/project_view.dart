// project_view.dart : 자신의 프로젝트 목록을 출력하는 페이지

import "package:devconnect_app/style/server_path.dart";
import "package:dio/dio.dart";
import "package:flutter/material.dart";
import "package:shared_preferences/shared_preferences.dart";

class ViewProject extends StatefulWidget {

  @override
  State<ViewProject> createState() => _ViewProjectState();

}

class _ViewProjectState extends State<ViewProject> {

  Dio dio = Dio();
  List<dynamic> projectList = [];

  /// 내 프로젝트 목록 전체 가져오기
  Future<void> findAllMyProject() async {
    try {
      final pref = await SharedPreferences.getInstance();
      final token = pref.getString("token");
      final response = await dio.get("$serverPath/api/project/company", options : Options(headers : {"Authorization" : token}));
      final data = response.data;
      if(data == null) { return; }
      print(data);
      setState(() { projectList = data; });
    } catch(e) {
      print(e);
    }
  }

  @override
  void initState() {
    super.initState();
    findAllMyProject();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar : AppBar(title : Text("내 프로젝트")),
      body : Container(
        padding : EdgeInsets.all(16),
        child : Column(
          children : [
            Expanded(child : ListView.builder(
              controller : null,
              itemCount : projectList.length,
              itemBuilder: (context, index) {
                return Card(
                  child : ListTile(
                    title : Text("${projectList[index]["pname"]}"),
                  ),
                );
              },
            ),),
          ],
        ),
      ),
    );
  }

}
