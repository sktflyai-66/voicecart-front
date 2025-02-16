import 'package:flutter/material.dart';
import 'package:app_test/services/api_service.dart';
import 'package:app_test/widgets/signup_step.dart';
import 'package:app_test/style/style.dart';

class SignUpPage extends StatefulWidget {
  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Map<String, String>> singup_step = [
    {"title": "아래 문장을 따라해주세요", "content": "안녕하세요.", "step": "step1"},
    {"title": "아래는 사용자 식별 질문입니다.", "content": "기억나는 첫사랑을 말해주세요.", "step": "step2"},
    {"title": "가입을 축하드립니다!", "content": "닉네임을 설정해주세요.", "step": "step3"},
    {"title": "생일을 알려주세요", "content": "적절한 상품을 추천하는데 도움이 됩니다.", "step": "step4"},
  ];

  Map<String, String> userData = {
    "user_data_1": "",
    "user_data_2": "",
    "user_data_3": "",
    "user_data_4": "",
  };

  void _nextPage(String step, String value) async {
    userData[step] = value;
    await ApiService.sendSingupToServer(value); // 서버에 상용자 입력 정보 전달 구현하기

    if (_currentPage < singup_step.length - 1) {    // 다음 페이지로 넘어가기
      _pageController.nextPage(
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _prevPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: Column(
        children: [
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              itemCount: singup_step.length,
              onPageChanged: (index) {
                setState(() {
                  _currentPage = index;
                });
              },
              itemBuilder: (context, index) {
                return SignUpStep(
                  stepNumber: index + 1,
                  totalSteps: singup_step.length,
                  title: singup_step[index]["title"]!,
                  content: singup_step[index]["content"]!,
                  onNext: (value) => _nextPage(singup_step[index]["step"]!, value),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _currentPage > 0
                    ? TextButton(
                        onPressed: _prevPage,
                        style: AppButtonStyles.elevatedButtonStyle,
                        child: Text("이전", style: AppTextStyles.buttonText),
                      )
                    : SizedBox(),
                _currentPage < singup_step.length - 1
                    ? SizedBox()
                    : ElevatedButton(
                        onPressed: () => print("회원가입 완료!"),
                        style: AppButtonStyles.elevatedButtonStyle,
                        child: Text("완료", style: AppTextStyles.buttonText),
                      ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
