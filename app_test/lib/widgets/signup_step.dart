import 'package:flutter/material.dart';
import 'package:app_test/style/style.dart';

class SignUpStep extends StatelessWidget {
  final int stepNumber;
  final int totalSteps;
  final String title;
  final String content;
  final Function(String) onNext;
  final TextEditingController _controller = TextEditingController();

  SignUpStep({
    required this.stepNumber,
    required this.totalSteps,
    required this.title,
    required this.content,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // 현재 단계와 총 단계 수를 오른쪽 상단에 표시
          Align(
            alignment: Alignment.topRight,
            child: Text(
              "$stepNumber/$totalSteps",
              style: AppTextStyles.highlightText,
            ),
          ),
          SizedBox(height: 40),

          // 제목
          Text(title, style: AppTextStyles.mainTitle, textAlign: TextAlign.center),
          SizedBox(height: 10),

          // 설명 문구
          Text(content, style: AppTextStyles.subtitle, textAlign: TextAlign.center),
          SizedBox(height: 30),

          // 마이크 아이콘 
          Icon(Icons.mic, size: 80, color: AppColors.textColor),
          SizedBox(height: 30),

          // 입력 필드(음성으로만 하면 지워야 됨?)
          if (stepNumber >= 3)
            TextField(
              controller: _controller,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: Colors.white, width: 2.0),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: Colors.white, width: 2.0),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: Colors.white, width: 2.5),
                ),
                hintText: "입력하세요",
                hintStyle: TextStyle(color: Colors.white70),
                filled: true,
                fillColor: AppColors.backgroundColor,
                contentPadding: EdgeInsets.symmetric(horizontal: 15, vertical: 12),
              ),
              style: TextStyle(fontSize: 18, color: Colors.white),
            ),

          SizedBox(height: 20),

          // 다음 단계로 이동하는 버튼
          ElevatedButton(
            onPressed: () => onNext(_controller.text),
            style: AppButtonStyles.elevatedButtonStyle,
            child: Text("다음", style: AppTextStyles.buttonText),
          ),
        ],
      ),
    );
  }
}
