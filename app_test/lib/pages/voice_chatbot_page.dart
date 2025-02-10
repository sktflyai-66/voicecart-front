import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import '../services/api_service.dart';

class VoiceBotPage extends StatefulWidget {
  @override
  _VoiceBotPageState createState() => _VoiceBotPageState();
}

class _VoiceBotPageState extends State<VoiceBotPage> {

  final FlutterTts _flutterTts = FlutterTts();
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isListening = false; // 음성 인식 활성 상태
  String _recognizedText = ""; // 인식된 음성 텍스트
  String _responseText = "필요한 물건이 있으신가요testse?"; // 서버 응답 텍스트

  @override
  void initState() {
    super.initState();
    _initializeTTS();
    _initializeSpeechRecognition();
    _connectToServerAndStartListening(); // 페이지 시작과 동시에 연결 및 음성 인식 시작
  }

  void _initializeTTS() async {
    await _flutterTts.setLanguage("ko-KR"); // 한국어 설정
    await _flutterTts.setPitch(1.0); // 음성 톤 설정
    await _flutterTts.setSpeechRate(1.5); // 말하는 속도 설정
  }

  Future<void> _speak(String text) async {
    if (text.isNotEmpty) {
      await _flutterTts.speak(text); // 텍스트를 음성으로 출력
    }
  }

  void _initializeSpeechRecognition() async {
    bool available = await _speech.initialize(
      onError: (val) => print("Speech recognition error: $val"),
      onStatus: (val) {
        print("Speech recognition status: $val");
        if (val == "notListening" && _recognizedText.isNotEmpty) {
          _sendToServer(_recognizedText); // 음성 인식이 멈추면 서버로 전송
        }
      },
    );

    if (!available) {
      Get.snackbar("Error", "Speech recognition not available");
    }
  }

  void _connectToServerAndStartListening() async {
    setState(() {
      _isListening = true;
    });

    // 서버와 연결 메시지를 출력
    _speak(_responseText);

    // 음성 인식을 시작
    _startListening();
  }

  void _startListening() async {
    setState(() {
      _recognizedText = ""; // 기존 인식된 텍스트 초기화
    });

    await _speech.listen(
      onResult: (val) {
        setState(() {
          _recognizedText = val.recognizedWords; // 음성 인식된 텍스트 업데이트
        });
      },
      listenFor: const Duration(seconds: 10), // 10초 동안 인식
      pauseFor: const Duration(seconds: 2), // 2초 동안 입력 없으면 멈춤
      partialResults: true, // 부분 결과 활성화
    );
  }

// 멈춤
  // void _stopListening() async {
  //   await _speech.stop();
  //   setState(() {
  //     _isListening = false;
  //   });
  // }

  Future<void> _sendToServer(String userMessage) async {
    print("사용자가 입력한 텍스트: $userMessage"); // 사용자가 말한 내용 로그 출력

    try {
      final serverMessages = await ApiService.sendMessageToServer(userMessage);


      if (serverMessages.isNotEmpty) {
        setState(() {
          _responseText = serverMessages; // 이전에는 serverMessages.last 였음
        });
        print("서버 응답: $_responseText"); // 서버 응답 로그 출력
        _speak(_responseText); // 응답 메시지를 음성으로 출력
      }
    } catch (e) {
      Get.snackbar("Error", "Failed to fetch response: $e");
      print("서버 요청 실패: $e"); // 에러 로그 출력
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
            // 서버 응답 텍스트
            Text(
              "서버 응답: $_responseText",
              style: const TextStyle(
                color: Colors.yellow,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),

            // 인식된 텍스트
            Text(
              "인식된 텍스트: $_recognizedText",
              style: const TextStyle(
                color: Colors.yellow,
                fontSize: 16,
                fontStyle: FontStyle.italic,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 50),

            // 마이크 아이콘 (동적 상태 표시)
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: _isListening ? 170 : 150,
              height: _isListening ? 170 : 150,
              decoration: BoxDecoration(
                color: _isListening ? Colors.red : Colors.yellow,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.mic,
                size: 80,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 20),

            // 상태 텍스트
            Text(
              _isListening ? "듣고 있습니다..." : "음성 챗봇 대기 중",
              style: const TextStyle(color: Colors.yellow, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
