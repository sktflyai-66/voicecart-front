import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:app_test/controllers/chat_controller.dart';
import 'package:app_test/services/api_service.dart';
import 'package:app_test/services/speech_service.dart';
import 'package:app_test/style/style.dart';

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
    _speechService.startSTT(); 
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor, 
      appBar: AppBar(
        title: const Text(
          '맨 위에 텍스트',
          style: AppTextStyles.mainTitle, 
        ),
        backgroundColor: AppColors.backgroundColor, 
        centerTitle: true, // 제목 중앙 정렬
        elevation: 0, // 그림자 제거
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
                  final isUserMessage = message.startsWith("You:");
                  return Align(
                    alignment: isUserMessage
                        ? Alignment.centerRight
                        : Alignment.centerLeft,
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                      padding: const EdgeInsets.all(12),
                      decoration: isUserMessage
                          ? ChatBubbleStyles.chatUserBubbleStyle
                          : ChatBubbleStyles.chatBotBubbleStyle,
                      child: Text(
                        message.replaceFirst("You: ", ""),
                        style: AppTextStyles.messageStyle,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          const Divider(height: 1, color: AppColors.textColor),

          // 실시간 음성 인식 결과 표시
          Container(
            padding: const EdgeInsets.all(12),
            child: Obx(() {
              return Text(
                _speechService.recognizedText.value.isNotEmpty
                    ? _speechService.recognizedText.value
                    : "음성을 인식 중입니다...", // STT 인식 중 메시지 추가
                style: AppTextStyles.secondaryText, 
                textAlign: TextAlign.center,
              );
            }),
          ),
        ],
      ),
    );
  }
}