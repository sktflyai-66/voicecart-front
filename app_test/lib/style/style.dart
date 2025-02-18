import 'package:flutter/material.dart';

// 색상 테마 정의
class AppColors {
  static const Color backgroundColor = Color.fromARGB(255, 7, 83, 159); // 배경
  static const Color secondaryColor = Color(0xFF0078D7); // 사용자 메시지
  static const Color botMessageColor = Color(0xFF0055AA); // 봇 메시지 
  static const Color textColor = Colors.white; // 기본 텍스트 색상
  static const Color buttonColor = Colors.blueAccent; // 버튼 색상
}

class AppTextStyles {
  static const TextStyle mainTitle = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    color: AppColors.textColor,
  );

  static const TextStyle subtitle = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
    color: AppColors.textColor,
  );

  static const TextStyle highlightText = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
    color: AppColors.textColor,
  );

  static const TextStyle secondaryText = TextStyle(
    fontSize: 18,
    color: AppColors.textColor,
  );

  static const TextStyle buttonText = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
    color: Colors.white,
  );

  static const TextStyle messageStyle = TextStyle(
    fontSize: 16,
    color: AppColors.textColor,
  );
}

// 버튼 스타일 정의
class AppButtonStyles {
  static final ButtonStyle elevatedButtonStyle = ElevatedButton.styleFrom(
    backgroundColor: AppColors.backgroundColor, // 배경을 투명하게
    foregroundColor: AppColors.textColor,
    padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
    textStyle: AppTextStyles.buttonText,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(30), // 둥근 버튼 적용
      side: const BorderSide(color: Colors.white, width: 4.0), // 흰색 테두리 추가
    ),
  );
}
// 채팅 말풍선 스타일 (테두리 추가)
class ChatBubbleStyles {
  static BoxDecoration chatBotBubbleStyle = BoxDecoration(
    color: AppColors.botMessageColor, // 봇 메시지는 짙은 파란색 배경
    borderRadius: const BorderRadius.only(
      topLeft: Radius.circular(16),
      topRight: Radius.circular(16),
      bottomLeft: Radius.circular(4),
      bottomRight: Radius.circular(16),
    ),
    border: Border.all(color: Colors.white, width: 2.0), // 하얀색 테두리 추가
  );

  static BoxDecoration chatUserBubbleStyle = BoxDecoration(
    color: AppColors.secondaryColor, // 사용자 메시지는 밝은 파란색 배경
    borderRadius: const BorderRadius.only(
      topLeft: Radius.circular(16),
      topRight: Radius.circular(16),
      bottomLeft: Radius.circular(16),
      bottomRight: Radius.circular(4),
    ),
    border: Border.all(color: Colors.white, width: 2.0), // 🔥 하얀색 테두리 추가
  );
}
