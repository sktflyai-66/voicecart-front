
import 'dart:convert';
import 'package:app_test/controllers/chat_controller.dart';
import 'package:app_test/services/api_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:get/get.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

class ChatBotPage extends StatefulWidget {
  @override
  _ChatBotPageState createState() => _ChatBotPageState();
}

class _ChatBotPageState extends State<ChatBotPage> {
  final ChatController chatController = Get.put(ChatController());
  late stt.SpeechToText _speech;
  late FlutterTts _flutterTts;
  bool _isListening = false; // STT 활성 상태
  bool _isSpeaking = false; // 챗봇이 말하고 있는 중인지 여부
  String _recognizedText = ""; // STT로 인식된 텍스트

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
    _flutterTts = FlutterTts();
    _initializeTTS();
    _startListening();
  }

  // TTS 초기화
  void _initializeTTS() async {
    await _flutterTts.setLanguage("ko-KR");
    await _flutterTts.setPitch(1.0);

    _flutterTts.setCompletionHandler(() {
      print("TTS 완료. STT 재시작");
      setState(() {
        _isSpeaking = false;
      });
      _startListening(); // TTS가 끝나면 STT 자동 시작
    });
  }

  // 챗봇 응답을 음성으로 출력하는 메소드
  Future<void> _speak(String text) async {
    if (text.isNotEmpty) {
      setState(() {
        _isSpeaking = true;
        // _isListening = false; // TTS가 말하는 동안 STT 비활성화
      });
      await _flutterTts.speak(text);
    }
  }

  // 음성 인식(STT) 시작
  void _startListening() async {
    bool available = await _speech.initialize(
      onError: (error) {
        print("STT error: $error");
        Get.snackbar("Error", "음성 인식 오류 발생");
      },
      onStatus: (status) {
        print("STT status: $status");
        if (status == "notListening") {
          if (_recognizedText.trim().isNotEmpty) {
            print("STT 종료 후 서버로 전송: $_recognizedText");
            _sendVoiceMessage(_recognizedText);
          } else {
            print("STT 종료: 인식된 텍스트 없음");
            _startListening(); // STT 자동 재시작
          }
        }
      },
    );

    if (!available) {
      Get.snackbar("Error", "음성 인식을 사용할 수 없습니다.");
      return;
    }

    setState(() {
      _isListening = true;
      _recognizedText = "";
    });

    _speech.listen(
      onResult: (result) {
        setState(() {
          _recognizedText = result.recognizedWords;
        });
        print("STT 인식된 텍스트: $_recognizedText");

        // // 사용자가 말을 하면 TTS 중단
        // if (_isSpeaking && _recognizedText.isNotEmpty) {
        //   print("사용자 음성 감지: TTS 중단");
        //   _flutterTts.stop();
        //   setState(() {
        //     _isSpeaking = false;
        //   });
        // }
      },
      listenFor: Duration(seconds: 10),
      pauseFor: Duration(seconds: 5),
      partialResults: true,
    );
  }

  // 음성 인식(STT) 중단
  void _stopListening() async {
    await _speech.stop();
    setState(() {
      _isListening = false;
    });
  }

  // 인식된 음성을 서버로 전송한 후 응답을 받아 처리하는 메소드
  Future<void> _sendVoiceMessage(String message) async {
    _stopListening();
    chatController.addMessage("You: $message");

    try {
      String response = await ApiService.sendMessageToServer(message);
      if (response.isNotEmpty && response != "Error") {
        chatController.addMessage(response); // "Bot: " 제거
        await _speak(response);
      } else {
        chatController.addMessage("서버 응답 오류");
      }
    } catch (e) {
      print("서버 오류: $e");
      Get.snackbar("Error", "서버에서 응답을 받을 수 없습니다.");
    }
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
          // 인식된 텍스트 미리보기 (실시간 디버깅 및 참고용)
          Container(
            padding: const EdgeInsets.all(10),
            child: Text(
              _recognizedText,
              style: const TextStyle(color: Colors.yellow, fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }
}
