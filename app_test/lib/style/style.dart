import 'package:flutter/material.dart';

// 스타일 관리 클래스
class AppStyles {
  static const TextStyle titleTextStyle = TextStyle(
    color: Colors.yellow, // 글자 색상
    fontSize: 30,         // 글자 크기
    fontWeight: FontWeight.bold, // 글자 굵기
    fontFamily: 'Cursive',       // 커스텀 글꼴
  );

  static final ButtonStyle primaryButtonStyle = ElevatedButton.styleFrom(
    backgroundColor: Colors.yellow,
    foregroundColor: Colors.black,
    minimumSize: const Size(200, 60),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(10),
    ),
    textStyle: const TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.bold,
    ),
  );

  static final ButtonStyle secondaryButtonStyle = ElevatedButton.styleFrom(
    backgroundColor: Colors.yellow,
    foregroundColor: Colors.black,
    minimumSize: const Size(150, 50),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(30),
    ),
    textStyle: const TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.bold,
    ),
  );
}
