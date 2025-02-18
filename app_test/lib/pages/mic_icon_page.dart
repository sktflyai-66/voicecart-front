import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:app_test/services/speech_service.dart';
import 'package:app_test/services/api_service.dart';
// import 'package:app_test/pages/chatbot_page.dart';
import 'package:app_test/style/style.dart';

class MicIconPage extends StatefulWidget {
  @override
  _MicIconPageState createState() => _MicIconPageState();
}

class _MicIconPageState extends State<MicIconPage> {
  final SpeechService _speechService = Get.find<SpeechService>(); // GetX로 SpeechService 가져오기
  // String _serverText = "";

  @override
  void initState() {
    super.initState();
    _fetchInitialMessage(); // 서버에서 초기 메시지를 가져와서 TTS로 실행
    _speechService.startSTT();
  }

  // 서버에서 초기 메시지를 받아와서 TTS로 읽기
  Future<void> _fetchInitialMessage() async {
    try {
      final responseText = await ApiService.getServerText(); // 서버에서 첫 메시지 요청
      await _speechService.ttsspeak(responseText); // 첫 메시지를 음성으로 출력
      _speechService.serverResponse.value = responseText; 
      
      debugPrint("============");
      debugPrint("_fetchInitalMessage 끝!!!");
      debugPrint("============");
    } catch (e) {
      print("서버 텍스트 가져오기 실패: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor, 
      appBar: AppBar(
        title: const Text(
          '음성 챗봇',
          style: AppTextStyles.mainTitle, 
        ),
        backgroundColor: AppColors.backgroundColor,
        centerTitle: true, 
        elevation: 0, 
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Obx(() => Text(
                  _speechService.serverResponse.value.isNotEmpty
                      ? _speechService.serverResponse.value
                      : "서버에서 받은 문장이 없습니다.",
                  style: AppTextStyles.secondaryText, 
                  textAlign: TextAlign.center,
                )),
            const SizedBox(height: 20),

            // Obx(() => AnimatedContainer(
            //         duration: const Duration(milliseconds: 300), // 부드러운 색상 전환
            //         child: Icon(
            //           Icons.mic,
            //           size: 80, 
            //           color: _speechService.isListening
            //               ? Colors.red // 말하고 있을 때 색상
            //               : AppColors.accentColor, // 기본 색상
            //         ),
            //       )),
            //   const SizedBox(height: 30),
            Icon(
              Icons.mic,
              size: 80,
              color: AppColors.textColor
              ), 

            Obx(() => Text(
                  _speechService.recognizedText.value.isNotEmpty
                      ? _speechService.recognizedText.value
                      : "음성을 인식 중입니다...",
                  style: AppTextStyles.secondaryText, 
                  textAlign: TextAlign.center,
                )),
          ],
        ),
      ),
    );
  }
}