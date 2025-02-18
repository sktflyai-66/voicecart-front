import 'package:flutter/material.dart';
import 'package:app_test/services/api_service.dart';
import 'package:app_test/widgets/signup_step.dart';
import 'package:app_test/style/style.dart';
import 'package:get/get.dart';
import 'package:app_test/controllers/chat_controller.dart';
import 'package:app_test/services/speech_service.dart';

class SignUpPage extends StatefulWidget {
  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  PageController _pageController = PageController();
  int _currentPage = 0;
  final ChatController chatController = Get.put(ChatController());
  final SpeechService _speechService = Get.find<SpeechService>();

  @override
  void initState() {
    super.initState();
    debugPrint("회원가입 페이지 입니다.");
    _speechService.startSTT();
    _speakInstruction(); 
  }

  final List<Map<String, String>> signupSteps = [
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

  /// 📌 **현재 단계의 안내 음성을 출력**
  void _speakInstruction() {
    String instruction = "${signupSteps[_currentPage]["title"]}, ${signupSteps[_currentPage]["content"]}. 음성으로 대답해 주세요.";
    _speechService.ttsspeak(instruction); 
  }

  /// 📌 **STT 결과 처리 (사용자가 음성 입력하면 실행)**
  void _handleSpeechResult(String result) {
    if (result.isEmpty) {
      _speechService.ttsspeak("입력값을 확인할 수 없습니다. 다시 말씀해주세요.");
    }

    userData[signupSteps[_currentPage]["step"]!] = result;
    debugPrint("STT 결과 저장: ${signupSteps[_currentPage]["step"]!} = $result");

    // 서버로 데이터 전송
    ApiService.sendSignupData(userData);

    if (_currentPage < signupSteps.length - 1) {
      _pageController.nextPage(duration: Duration(milliseconds: 300), curve: Curves.easeInOut);
      setState(() {
        _currentPage += 1;
      });
      _speakInstruction(); // 다음 단계 안내 음성 실행
    } else {
      _speechService.ttsspeak("회원가입이 완료되었습니다. 홈 화면으로 이동합니다.");
      Navigator.pushReplacementNamed(context, '/home');
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
              itemCount: signupSteps.length,
              onPageChanged: (index) {
                setState(() {
                  _currentPage = index;
                });
              },
              itemBuilder: (context, index) {
                return SignUpStep(
                  stepNumber: index + 1,
                  totalSteps: signupSteps.length,
                  title: signupSteps[index]["title"]!,
                  content: signupSteps[index]["content"]!,
                  onNext: (value) => _handleSpeechResult(value), // ✅ 음성 입력 후 처리
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
