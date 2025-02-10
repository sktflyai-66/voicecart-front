import 'dart:convert';
import 'package:app_test/controllers/chat_controller.dart';
import 'package:app_test/services/api_service.dart';
import 'package:app_test/style/style.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:get/get.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

class ChatBotPage extends StatefulWidget {
  @override
  _ChatBotPageState createState() => _ChatBotPageState();
}

class _ChatBotPageState extends State<ChatBotPage> {
  final chatController = Get.find<ChatController>();
  late stt.SpeechToText _speech;
  late FlutterTts _flutterTts;
  bool _isListening = false;       // STT가 활성화되어 있는지 여부
  bool _isSpeaking = false;        // 챗봇이 TTS로 말하고 있는 중인지 여부
  String _recognizedText = "";     // STT로 인식된 텍스트

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
    _flutterTts = FlutterTts();
    _initializeTTS();
    _startListening();  // 앱 시작 시 음성 인식 시작
  }

  // TTS 초기화
  void _initializeTTS() async {
    await _flutterTts.setLanguage("ko-KR");
    await _flutterTts.setPitch(1.0);

    _flutterTts.setCompletionHandler(() {
      print("TTS 완료.");
      setState(() {
        _isSpeaking = false;
      });
      _startListening();  // TTS가 끝나면 다시 음성 인식 시작
    });
  }

  // 챗봇 응답을 음성으로 출력
  Future<void> _speak(String text) async {
    if (text.isNotEmpty) {
      setState(() {
        _isSpeaking = true;
      });
      await _flutterTts.speak(text);
    }
  }

  // 음성 인식 시작
  void _startListening() async {
    bool available = await _speech.initialize(
      onError: (error) => print("STT error: $error"),
      onStatus: (status) {
        print("STT status: $status");
        if (status == "notListening" && _recognizedText.isNotEmpty) {
          _sendVoiceMessage(_recognizedText); // 음성을 서버로 전송
        }
      },
    );

    if (available) {
      setState(() {
        _isListening = true;
        _recognizedText = "";
      });

      _speech.listen(
        onResult: (result) {
          setState(() {
            _recognizedText = result.recognizedWords;
          });

          // 사용자가 말을 하면 채팅창에 바로 표시
          if (_recognizedText.isNotEmpty) {
            chatController.addMessage("You: $_recognizedText");
          }
        },
        listenFor: Duration(seconds: 10),
        pauseFor: Duration(seconds: 2), // 2초 동안 말이 없으면 stop 상태
        partialResults: true,  // 실시간으로 텍스트 업데이트
      );
    } else {
      Get.snackbar("Error", "음성 인식이 불가능합니다.");
    }
  }

  // 음성 인식을 중단
  void _stopListening() async {
    await _speech.stop();
    setState(() {
      _isListening = false;
    });
  }

  // 인식된 음성을 서버로 전송
  Future<void> _sendVoiceMessage(String message) async {
    _stopListening(); // 현재 음성 인식을 중단

    // 사용자의 입력을 즉시 채팅창에 표시 (이미 처리됨)
    print("사용자 입력: $message");

    // 서버에 메시지 전송
    String response = await ApiService.sendMessageToServer(message);

    // 서버 응답을 채팅창에 추가
    chatController.addMessage(response);

    // 응답을 음성으로 출력 후 다시 음성 인식 시작
    await _speak(response);
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

          // 실시간 음성 인식된 텍스트 미리보기
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

