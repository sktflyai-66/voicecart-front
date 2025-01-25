 
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/chat_controller.dart';
import '../services/api_service.dart';
import '../dto/selection_dto.dart';
import 'chatbot_page.dart';
import 'voice_chatbot_page.dart';

// 선택 화면 위젯
class SelectionPage extends StatelessWidget {
  final chatController = Get.put(ChatController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Choose an Option')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () async {
                try {
                  await ApiService.sendMessageToServer('텍스트 챗봇');
                  Get.to(() => ChatBotPage());
                } catch (e) {
                  Get.snackbar('Error', 'Failed to send option: $e');
                }
              },
              child: Text('텍스트 챗봇'),
            ),
            ElevatedButton(
              onPressed: () async {
                try {
                  await ApiService.sendMessageToServer('음성 챗봇');
                  Get.to(() => VoiceBotPage());
                } catch (e) {
                  Get.snackbar('Error', 'Failed to send option: $e');
                }
              },
              child: Text('음성 챗봇'),
            ),
          ],
        ),
      ),
    );
  }
}
