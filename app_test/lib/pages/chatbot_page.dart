 
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/chat_controller.dart';
import 'package:app_test/style/style.dart';

class ChatBotPage extends StatelessWidget {
  final chatController = Get.find<ChatController>();
  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // 배경색
      appBar: AppBar(
        title: const Text('챗봇', style: TextStyle(color: Colors.yellow)),
        backgroundColor: Colors.black,
      ),
      body: Column(
        children: [
          // 채팅 메시지 리스트
          Expanded(
            child: Obx(
              () => ListView.builder(
                padding: const EdgeInsets.all(10),
                itemCount: chatController.messages.length,
                itemBuilder: (context, index) {
                  final message = chatController.messages[index];
                  final isUserMessage = message.startsWith('You:');
                  return Align(
                    alignment: isUserMessage
                        ? Alignment.centerLeft // 사용자 메시지 왼쪽 정렬
                        : Alignment.centerRight, // 챗봇 메시지 오른쪽 정렬
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 5),
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: isUserMessage
                            ? Colors.yellow[100] // 사용자 메시지 배경
                            : Colors.yellow[700], // 챗봇 메시지 배경
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(isUserMessage ? 0 : 10),
                          topRight: Radius.circular(isUserMessage ? 10 : 0),
                          bottomLeft: const Radius.circular(10),
                          bottomRight: const Radius.circular(10),
                        ),
                      ),
                      child: Text(
                        message.replaceFirst('You: ', ''), // "You: " 제거
                        style: const TextStyle(fontSize: 16, color: Colors.black),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          const Divider(height: 1, color: Colors.yellow),
          // 메시지 입력창
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      hintText: '메시지를 입력하세요...',
                      border: OutlineInputBorder(),
                      hintStyle: TextStyle(color: Colors.yellow),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.yellow),
                      ),
                    ),
                    style: const TextStyle(color: Colors.yellow),
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () {
                    final message = _controller.text.trim();
                    if (message.isNotEmpty) {
                      _controller.clear();
                      chatController.handleMessage(message);
                    } else {
                      Get.snackbar('Error', '메시지를 입력해주세요.');
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.yellow, // 버튼 배경색
                    foregroundColor: Colors.black, // 버튼 텍스트 색상
                  ),
                  child: const Text('전송'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
