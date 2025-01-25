import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

void main() {
  runApp(MyApp());
}

// 앱의 최상위 위젯
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Accessibility App',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: SelectionPage(),
    );
  }
}

// 서버와 통신하는 기능
class ApiService {
  static const String baseUrl = 'http://127.0.0.1:5000';

  static Future<void> sendMessageToServer(String message) async {
    final url = Uri.parse('$baseUrl/send');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'message': message}),
      );

      if (response.statusCode == 200) {
        print('Message sent successfully: ${response.body}');
      } else {
        Get.snackbar('Error', 'Failed to send message: ${response.statusCode}');
      }
    } catch (e) {
      Get.snackbar('Error', 'Error sending message: $e');
    }
  }

  static Future<List<String>> getMessagesFromServer() async {
    final url = Uri.parse('$baseUrl/messages');
    try {
      final response = await http.get(
        url,
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return List<String>.from(data['messages']);
      } else {
        throw Exception('Failed to fetch messages');
      }
    } catch (e) {
      Get.snackbar('Error', 'Error fetching messages: $e');
      return [];
    }
  }
}

// TTS 기능
class TTSService {
  final FlutterTts _flutterTts = FlutterTts();

  TTSService() {
    _flutterTts.setLanguage('en-US'); // 한국어: 'ko-KR'
    _flutterTts.setPitch(1.0);
    _flutterTts.setSpeechRate(0.5);
  }

  Future<void> speak(String text) async {
    await _flutterTts.speak(text);
  }

  Future<void> stop() async {
    await _flutterTts.stop();
  }
}

// STT 기능
class STTService {
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool isAvailable = false;

  Future<void> initSTT() async {
    isAvailable = await _speech.initialize(
      onError: (error) => print("STT Error: $error"),
      onStatus: (status) => print("STT Status: $status"),
    );
  }

  Future<String> startListening() async {
    if (isAvailable) {
      String recognizedText = "";
      await _speech.listen(
        onResult: (result) {
          recognizedText = result.recognizedWords;
        },
      );
      return recognizedText;
    } else {
      print("STT not available");
      return "";
    }
  }

  Future<void> stopListening() async {
    await _speech.stop();
  }
}

// 채팅 화면 위젯
class ChatBotPage extends StatelessWidget {
  final chatController = Get.find<ChatController>();
  final TextEditingController _controller = TextEditingController();
  final TTSService ttsService = TTSService();
  final STTService sttService = STTService();

  ChatBotPage() {
    sttService.initSTT(); // STT 초기화
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('ChatBot')),
      body: Column(
        children: [
          Expanded(
            child: Obx(() => ListView.builder(
                  itemCount: chatController.messages.length,
                  itemBuilder: (context, index) {
                    final message = chatController.messages[index];
                    final isUserMessage = message.startsWith('You:');
                    return Align(
                      alignment: isUserMessage
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.symmetric(
                            vertical: 5, horizontal: 10),
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: isUserMessage
                              ? Colors.blue[100]
                              : Colors.grey[300],
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          message.replaceFirst('You: ', ''),
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                    );
                  },
                )),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            child: Row(
              children: [
                IconButton(
                  icon: Icon(Icons.mic),
                  onPressed: () async {
                    // STT 시작
                    final recognizedText = await sttService.startListening();
                    _controller.text = recognizedText; // 인식된 텍스트를 입력 필드에 추가
                  },
                ),
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      hintText: 'Type a message',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: () async {
                    final message = _controller.text.trim();
                    if (message.isNotEmpty) {
                      _controller.clear();
                      chatController.handleMessage(message);
                      ttsService.speak(message); // TTS로 메시지 출력
                    } else {
                      Get.snackbar('Error', 'Message cannot be empty');
                    }
                  },
                  child: const Text('Send'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// 음성 챗봇 페이지
class VoiceBotPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Voice Bot')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.volume_up, size: 100, color: Colors.blue),
            SizedBox(height: 20),
            Text(
              'Listening... Your voice will appear here!',
              style: TextStyle(fontSize: 18),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

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
              onPressed: () => Get.to(() => ChatBotPage()),
              child: Text('텍스트 챗봇'),
            ),
            ElevatedButton(
              onPressed: () => Get.to(() => VoiceBotPage()),
              child: Text('음성 챗봇'),
            ),
          ],
        ),
      ),
    );
  }
}

// ChatController
class ChatController extends GetxController {
  var messages = <String>[].obs;

  void addMessage(String message) {
    messages.add(message);
  }

  Future<void> handleMessage(String message) async {
    addMessage('You: $message');
    await ApiService.sendMessageToFlask(message);
    final messagesFromServer = await ApiService.getMessagesFromFlask();
    messages.addAll(messagesFromServer);
  }
}
