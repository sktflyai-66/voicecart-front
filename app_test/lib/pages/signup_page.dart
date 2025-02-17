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
    {"title": "성별을 알려주세요", "content": "성별에 맞는 맞춤형 추천이 가능합니다.", "step": "step5"},
    {"title": "자주 구매하는 품목을 선택해주세요", "content": "맞춤형 상품을 추천해드립니다.", "step": "step6"},
  ];

  Map<String, String> userData = {
    "step1": "",
    "step2": "",
    "step3": "",
    "step4": "",
    "step5": "",
    "step6": "",
  };

  // 단계별 사용자 입력값 처리
  void _nextPage(String step, String value) async {
    // 유효성 검사 추가
    if (value.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("입력값을 확인해 주세요.")));
      return;
    }

    userData[step] = value;

    // 서버로 데이터 전송
    await ApiService.sendSingupToServer(userData);

    if (_currentPage < singup_step.length - 1) {
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
                        onPressed: () async {
                          // "완료" 버튼 클릭 시
                          await ApiService.sendSingupToServer(userData);
                          Navigator.pushReplacementNamed(context, '/home'); // 홈 화면으로 이동
                        },
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
