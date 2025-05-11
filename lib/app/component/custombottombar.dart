import 'package:devconnect_app/style/server_path.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CustomBottomNavBar extends StatefulWidget {
  final int selectedIndex;
  final Function(int) onTap;

  const CustomBottomNavBar({
    required this.selectedIndex,
    required this.onTap,
  });

  @override
  _CustomBottomNavBarState createState() {
    return _CustomBottomNavBarState();
  }
}

class _CustomBottomNavBarState extends State<CustomBottomNavBar> {
  Dio dio = Dio();
  bool isLogIn = false;
  Map<String, dynamic> developer = {};

  @override
  void initState() {
    super.initState();
    loginCheck();
  }

  // 로그인 확인
  void loginCheck() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token != null && token.isNotEmpty) {
      setState(() {
        isLogIn = true;
      });
      onInfo(token);
    }
  }

  // 정보 가져오기
  void onInfo(String token) async {
    try {
      print( token );
      dio.options.headers['Authorization'] = token;
      final response = await dio.get("$serverPath/api/developer/info");
      final data = response.data;
      if (data != '') {
        setState(() {
          developer = data;
        });
      }
    } catch (e) { print(e); }
  }

  // 로그아웃
  void logOut() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if( token == null ){ return; }
    dio.options.headers['Authorization'] = token;
    final response = await dio.get("${serverPath}/api/developer/logout");
    await prefs.remove('token');
    final data = response.data;
    isLogIn = false;
    setState(() {
      developer = {};
      widget.onTap(0);
    });
  } // f end

  @override
  Widget build(BuildContext context) {
    final isProfileSelected = widget.selectedIndex == 2;

    // 상태변수
    int dcurrentexp = developer['dcurrentExp'] ?? 0;
    int dtotalexp = developer['dtotalExp'] ?? 1;
    double levelExp = (dtotalexp != 0) ? (dcurrentexp / dtotalexp).toDouble() : 0.0;

    String profileUrl = developer['dprofile'] != null && developer['dprofile'].toString().isNotEmpty
        ? "${serverPath}/upload/${developer['dprofile']}" : "${serverPath}/upload/logo_small.png";

    String? dname = isLogIn ? "${developer['did']} ${developer['dlevel']} Lv" : "로그인";

    double? menuHeight = isLogIn ? 0.55 : 0.62;

    return SafeArea(
      child : Container(
        height: 80,
        color: Colors.black87,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _navItem(Icons.folder, "프로젝트", 0),
                _navItem(Icons.article, "등록", 1),
                const SizedBox(width: 70), // 중앙 공간 확보
                _navItem(Icons.article_outlined, "기업 목록", 3),
                _navItem(Icons.article_outlined, "개발자 순위", 4),
              ],
            ),
            Positioned(
              top: -20,
              left: MediaQuery.of(context).size.width / 2 - 35,
              child: GestureDetector(
                onTap: () {
                  showGeneralDialog(
                    context: context,
                    barrierDismissible: true,
                    barrierLabel: '',
                    barrierColor: Colors.black.withOpacity(0.001),
                    transitionDuration: const Duration(milliseconds: 300),
                    pageBuilder: (context, animation, secondaryAnimation) {
                      return Align(
                        alignment: Alignment(0, menuHeight), // 위치 조정
                        child: ScaleTransition(
                          scale: CurvedAnimation(
                            parent: animation,
                            curve: Curves.easeOutBack,
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: Container(
                              width: 200,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black26,
                                    blurRadius: 10,
                                    offset: Offset(0, 4),
                                  ),
                                ],
                              ),
                              // 프로필 메뉴
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  if (isLogIn == true) ...[
                                    ListTile(
                                      leading: Icon(Icons.auto_graph),
                                      title: Text("Level : ${developer['dlevel']}"),
                                      onTap: () {
                                        Navigator.pop(context);
                                        // widget.onTap(2);
                                      },
                                    ),
                                    ListTile(
                                      leading: Icon(Icons.auto_graph),
                                      title: Text("Exp : ${dcurrentexp} / ${dtotalexp}"),
                                      onTap: () {
                                        Navigator.pop(context);
                                        // widget.onTap(2);
                                      },
                                    ),
                                    ListTile(
                                      leading: Icon(Icons.person),
                                      title: Text('프로필 보기'),
                                      onTap: () {
                                        Navigator.pop(context);
                                        widget.onTap(2);
                                      },
                                    ),
                                    ListTile(
                                      leading: Icon(Icons.logout),
                                      title: Text('로그아웃'),
                                      onTap: () {
                                        Navigator.pop(context);
                                        logOut();
                                      },
                                    ),
                                  ] else ...[
                                    ListTile(
                                      leading: Icon(Icons.login),
                                      title: Text('기업 로그인'),
                                      onTap: () {
                                        Navigator.pop(context);
                                        widget.onTap(7); // 기업 로그인 페이지로 이동
                                      },
                                    ),
                                    ListTile(
                                      leading: Icon(Icons.login),
                                      title: Text('개발자 로그인'),
                                      onTap: () {
                                        Navigator.pop(context);
                                        widget.onTap(6); // 개발자 로그인 페이지로 이동
                                      },
                                    ),
                                  ]
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
                child: Column(
                  children: [
                    CircularPercentIndicator(
                      radius: 35.0,
                      lineWidth: 5.0,
                      percent: levelExp.clamp(0.0, 1.0),
                      center: CircleAvatar(
                        radius: 30,
                        backgroundImage: NetworkImage(profileUrl),
                      ),
                      progressColor: Colors.blue,
                      backgroundColor: Colors.grey.shade300,
                      circularStrokeCap: CircularStrokeCap.round,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "${dname}",
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _navItem(IconData icon, String label, int index) {
    final isSelected = index == widget.selectedIndex;

    return Expanded(
      child: InkWell(
        onTap: () => widget.onTap(index),
        borderRadius: BorderRadius.circular(12),
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedScale(
                scale: isSelected ? 1.2 : 1.0,
                duration: Duration(milliseconds: 200),
                child: Icon(icon, color: isSelected ? Colors.white : Colors.grey),
              ),
              SizedBox(height: 4),
              AnimatedDefaultTextStyle(
                duration: Duration(milliseconds: 200),
                style: TextStyle(
                  fontSize: 12,
                  color: isSelected ? Colors.white : Colors.grey,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
                child: Text(label),
              ),
            ],
          ),
        ),
      ),
    );
  }
}