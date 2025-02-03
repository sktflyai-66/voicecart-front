import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:app_test/pages/splash_page.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Accessibility App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      // 스플래시 화면을 초기 화면으로 설정
      home: SplashScreen(),
    );
  }
}
