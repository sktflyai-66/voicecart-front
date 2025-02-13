import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:app_test/services/speech_service.dart';
import 'package:app_test/services/api_service.dart';
// import 'package:app_test/pages/chatbot_page.dart';

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

  /// 서버에서 초기 메시지를 받아와서 TTS로 읽기
  Future<void> _fetchInitialMessage() async {
    try {
      final responseText = await ApiService.getServerText(); // 서버에서 첫 메시지 요청
      await _speechService.ttsspeak(responseText); // 첫 메시지를 음성으로 출력
      _speechService.serverResponse.value = responseText; // 🔥 초기 메시지도 반영  
      
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
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text(
          '음성 챗봇',
          style: TextStyle(color: Colors.yellow),
        ),
        backgroundColor: Colors.black,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 🔥 서버 응답을 실시간으로 표시하도록 Obx 사용
            Obx(() => Text(
                  "서버에서 받은 문장: ${_speechService.serverResponse.value}",
                  style: const TextStyle(
                    color: Colors.yellow,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                )),
            const SizedBox(height: 20),
            
            Obx(() => Text(
                  "인식된 텍스트: ${_speechService.recognizedText.value}",
                  style: const TextStyle(
                    color: Colors.yellow,
                    fontSize: 16,
                    fontStyle: FontStyle.italic,
                  ),
                  textAlign: TextAlign.center,
                )),
          ],
        ),
      ),
    );
  }
}