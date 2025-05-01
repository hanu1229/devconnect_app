import 'package:devconnect_app/app/layout/main_app.dart';
import 'package:devconnect_app/style/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() {
  runApp(DevConnect());
}

class DevConnect extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      locale : Locale("ko"),
      supportedLocales : [
        Locale("ko", "KR"),
        Locale("en", "US")
      ],
      localizationsDelegates : [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      theme : ThemeData(
        scaffoldBackgroundColor : Colors.white,
        fontFamily : "NanumGothic",
        appBarTheme : AppBarTheme(
          backgroundColor : AppColors.bgColor,
          scrolledUnderElevation : 0,
          shape : Border(bottom : BorderSide(color : AppColors.appBarColor, width : 1)),
        ),
      ),
      // 앱 탭 이름.
      title: "DevConnect",
      home : MainApp(),
    );
  }

}

