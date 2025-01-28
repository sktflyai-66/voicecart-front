import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'voice_chatbot_page.dart';

class PermissionRequestPage extends StatefulWidget {
  @override
  _PermissionRequestPageState createState() => _PermissionRequestPageState();
}

class _PermissionRequestPageState extends State<PermissionRequestPage> {
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _hasSpeechPermission = false;

  @override
  void initState() {
    super.initState();
    _requestSpeechPermission(); // 앱 실행 시 권한 요청
  }

  Future<void> _requestSpeechPermission() async {
    bool available = await _speech.initialize(
      onError: (val) => print("Speech recognition error: $val"), // 초기화 에러 로그 출력
      onStatus: (val) => print("Speech recognition status: $val"), // 초기화 상태 로그 출력
    );

    if (available) {
      // 권한이 승인된 경우
      setState(() {
        _hasSpeechPermission = true;
      });
      _navigateToVoiceBotPage();
    } else {
      // 권한이 거부된 경우
      setState(() {
        _hasSpeechPermission = false;
      });
      _showPermissionError();
    }
  }

  void _navigateToVoiceBotPage() {
    Get.off(() => VoiceBotPage());
  }

  void _showPermissionError() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('권한 필요'),
        content: const Text('음성 인식을 사용하려면 마이크 권한이 필요합니다.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('닫기'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: _hasSpeechPermission
            ? const CircularProgressIndicator(color: Colors.yellow)
            : const Text(
                '권한 요청 중...',
                style: TextStyle(color: Colors.yellow, fontSize: 16),
              ),
      ),
    );
  }
}
