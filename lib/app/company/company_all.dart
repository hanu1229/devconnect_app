



import 'package:devconnect_app/app/component/custom_card.dart';
import 'package:devconnect_app/style/server_path.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CompanyAll extends StatefulWidget{

  State<CompanyAll> createState() => _CompanyState();

}

class _CompanyState extends State<CompanyAll> {

  Dio dio = Dio();
  List<dynamic> companyList = [];

  // 기업 목록 전체 가져오기
  Future<void> findAllCompany() async {
    try {


      final response = await dio.get("${serverPath}/api/company/findall");
      final data = response.data;
      print(data);
      if (data == null) {
        print("확인불가 : $data");
        setState(() {
          companyList = [];
        });
        return;
      }
      setState(() {
        companyList = data;
      });
      print("회사 목록 조회 성공. ${companyList.length} 개 항목 로드됨.");
    } catch (e) {
      print(e);
    }
  }

  @override
  void initState() {
    super.initState(); // super 설정하는 이유 필수 호출
    findAllCompany();
  }


  @override
  Widget build(BuildContext context) {
    if (companyList.isEmpty) { // 데이터 로드시 companyList가 비어있을경우를 대비
      return Scaffold(
        appBar: AppBar(title: Text("회사 목록"),),
        body: Center( //화면 중앙 로딩 인디 케이터 표시
          child: CircularProgressIndicator(),
        ),
      );
    }

    // 로딩 완료후 목록표시
    return Scaffold(
      appBar: AppBar(title: Text("회사목록")),
      body: ListView.builder( // 리스트 뷰를 빌드 목록표시
          itemCount: companyList.length,
          itemBuilder: (context, index) {
            final companyData = companyList[index]; //인덱스 회사데이터 가져오기

            return Center(
              child: SizedBox(
                width: 380.0,

                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                CustomCard(
                child: Column( // 내부에 회사 정보 표시
                crossAxisAlignment: CrossAxisAlignment.start, //  내용 왼쪽 정렬
                  children: [
                    Text(
                      companyData['cname'] ?? '회사 이름 정보 없음',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    SizedBox(height: 8,),

                    Text(
                      companyData['cadress'] ?? ' 주소 정보 없음',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                    // 필요한거 있을때 추가

                  ],
                ),
              ),
             SizedBox(height: 3.0),
                  ],
                ),
              ),
            );
          }
      ),
    );
  }
}