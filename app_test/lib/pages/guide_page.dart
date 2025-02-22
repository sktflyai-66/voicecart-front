import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:app_test/services/speech_service.dart';
import 'package:app_test/pages/chatbot_page.dart';
import 'package:app_test/widgets/gesture_feedback.dart';
import 'package:app_test/style/style.dart';

class GuidePage extends StatefulWidget {
  const GuidePage({Key? key}) : super(key: key);

  @override
  _GuidePageState createState() => _GuidePageState();
}

class _GuidePageState extends State<GuidePage> {
  final SpeechService speechService = Get.find<SpeechService>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      speechService.ttsspeak("""안녕하세요. 음성 쇼핑 도우미 사용 안내를 시작하겠습니다. 
      화면을 한 번 터치하면 마이크를 켜서 말씀하실 수 있습니다. 
      챗봇이 말하고 있을 때 화면을 눌러 마이크를 켜서 말씀하시면 챗봇의 말을 끊을 수 있습니다.

      """);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        title: const Text("안내 페이지", style: AppTextStyles.mainTitle),
        backgroundColor: AppColors.secondaryColor,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const Text(
                '여기에 음성 사용법, 제스처 설명 등을 안내하는 내용을 적어주세요.',
                textAlign: TextAlign.center,
                style: AppTextStyles.secondaryText,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                style: AppButtonStyles.elevatedButtonStyle,
                onPressed: () {
                  Get.off(() => GestureControlWidget(child: ChatBotPage()));
                },
                child: const Text("시작하기"),
              )
            ],
          ),
        ),
      ),
    );
  }
}
