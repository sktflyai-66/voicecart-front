import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/chat_controller.dart';
import '../services/api_service.dart';
// import '../dto/selection_dto.dart';
import 'chatbot_page.dart';
import 'voice_chatbot_page.dart';
import 'package:app_test/style/style.dart';

// 선택 화면 위젯
class SelectionPage extends StatelessWidget {
  final chatController = Get.put(ChatController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // 배경색
      appBar: AppBar(
        title: const Text('선택 화면', style: TextStyle(color: Colors.yellow)),
        backgroundColor: Colors.black,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 텍스트 챗봇 버튼
            ElevatedButton(
              onPressed: () {
                Get.to(() => ChatBotPage());
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.yellow,
                foregroundColor: Colors.black,
                minimumSize: const Size(200, 60),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                textStyle: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              child: const Text('텍스트 챗봇'),
            ),
            const SizedBox(height: 20), // 버튼 간격
            // 음성 챗봇 버튼
            ElevatedButton(
              onPressed: () {
                Get.to(() => VoiceBotPage());
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.yellow,
                foregroundColor: Colors.black,
                minimumSize: const Size(200, 60),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                textStyle: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              child: const Text('음성 챗봇'),
            ),
          ],
        ),
      ),
    );
  }
}
