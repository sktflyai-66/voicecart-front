import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:app_test/controllers/chat_controller.dart';
import 'package:app_test/services/api_service.dart';
import 'package:app_test/services/speech_service.dart';

class ChatBotPage extends StatefulWidget {
  @override
  _ChatBotPageState createState() => _ChatBotPageState();
}

class _ChatBotPageState extends State<ChatBotPage> {
  final ChatController chatController = Get.put(ChatController());
  final SpeechService _speechService = Get.find<SpeechService>();

  @override
  void initState() {
    super.initState();
    _speechService.startSTT(); // 🔥 페이지가 열리면 STT 자동 시작
  }

@override
Widget build(BuildContext context) {
  return Scaffold(
    backgroundColor: Colors.black,
    appBar: AppBar(
      title: const Text('쇼핑', style: TextStyle(color: Colors.yellow)),
      backgroundColor: Colors.black,
    ),
    body: Column(
      children: [
        // 🔹 채팅 메시지 리스트
        Expanded(
          child: Obx(
            () => ListView.builder(
              padding: const EdgeInsets.all(10),
              itemCount: chatController.messages.length,
              itemBuilder: (context, index) {
                final message = chatController.messages[index];
                final isUserMessage = message.startsWith("You:");
                return Align(
                  alignment: isUserMessage
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 5),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: isUserMessage
                          ? Colors.yellow[100]
                          : Colors.yellow[700],
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(isUserMessage ? 0 : 10),
                        topRight: Radius.circular(isUserMessage ? 10 : 0),
                        bottomLeft: const Radius.circular(10),
                        bottomRight: const Radius.circular(10),
                      ),
                    ),
                    child: Text(
                      message.replaceFirst("You: ", ""),
                      style: const TextStyle(fontSize: 16, color: Colors.black),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        const Divider(height: 1, color: Colors.yellow),

        // 🔹 실시간 음성 인식 결과 표시
        Container(
          padding: const EdgeInsets.all(10),
          child: Obx(() {
            return Text(
              _speechService.recognizedText.value, // STT로 실시간 변환된 텍스트 표시
              style: const TextStyle(color: Colors.yellow, fontSize: 16),
              textAlign: TextAlign.center,
            );
          }),
        ),
      ],
    ),
  );
}
}