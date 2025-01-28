import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:app_test/pages/selection_page.dart';
import 'package:app_test/style/style.dart';

class SplashScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // 3초 후에 SelectionPage로 이동
    Future.delayed(const Duration(seconds: 3), () {
      Get.off(() => SelectionPage());
    });

    return Scaffold(
      backgroundColor: Colors.black, // 배경색
      body: Center(
        child: Text(
          'VoiceCart',
          style: AppStyles.titleTextStyle, // 스타일 클래스에서 텍스트 스타일 적용
        ),
      ),
    );
  }
}
