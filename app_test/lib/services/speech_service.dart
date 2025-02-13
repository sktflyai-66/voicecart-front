import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:get/get.dart';
import 'package:app_test/services/api_service.dart';
import 'package:app_test/pages/chatbot_page.dart';
import 'package:app_test/controllers/chat_controller.dart';

class SpeechService extends GetxService {
  final ChatController chatController = Get.find<ChatController>(); // 🔥 ChatController 가져오기
  late stt.SpeechToText _speech;
  late FlutterTts _flutterTts;

  // 서버 응답을 저장할 Rx 변수 추가
  final RxString serverResponse = ''.obs;

  // 상태 변수
  bool _isListening = false;   // STT 활성 상태
  bool _isSpeaking = false;    // TTS 실행 여부
  bool _sttErrorOccurred = false; // STT 오류 발생 여부

  // STT 결과 저장
  final RxString recognizedText = ''.obs;

  // 외부 접근을 위한 getter
  bool get isListening => _isListening;
  bool get isSpeaking => _isSpeaking;


  /// 초기화 메서드 (GetX의 onInit)
  @override
  void onInit() {
    super.onInit();

    _speech = stt.SpeechToText();
    _flutterTts = FlutterTts();

    
    _initializeTTS();
    _initializeSTT();
    print("=============");
    print("Speech_service 초기화완료, stt 시작");
    print("=============");

  }

  // 1) TTS 초기화
  Future<void> _initializeTTS() async {
    await _flutterTts.setLanguage("ko-KR");
    await _flutterTts.setPitch(1.0);

    // _flutterTts.setStartHandler(() {
    //   _isSpeaking = true;
    //   print("끝 setStartHandler ");
    // });

    // _flutterTts.setCompletionHandler(() {
    //   print("[setCompltionHandler 끝");
    //   _isSpeaking = false;
    //   startSTT(); // TTS가 끝나면 자동으로 STT 시작
    // });

    // _flutterTts.setCancelHandler(() {
    //   print("[setCancelHandler 끝");
    //   _isSpeaking = false;
    // });
  }

  // ----------------------
  // 2) STT 초기화
  // ----------------------
  Future<void> _initializeSTT() async {
    bool available = await _speech.initialize(
      onError: (error) {
        print("[SpeechService] STT 오류 발생: $error");
        _sttErrorOccurred = true;
        Future.delayed(const Duration(seconds: 2), startSTT);
      },
      onStatus: (status) {
        print("[SpeechService] STT 상태: $status");
        if (status == "notListening" && !_sttErrorOccurred) {
          if (recognizedText.value.trim().isNotEmpty) {
            sendToServer(recognizedText.value);
          } else {
            startSTT();
          }
        }
        _sttErrorOccurred = false; // 오류가 해결되면 초기화
      },
    );

    if (!available) {
      print("[SpeechService] STT를 사용할 수 없음 (권한 문제)");
    }
  }

  // ----------------------
  // 3) STT 시작 (사용자 음성 듣기)
  // ----------------------
  void startSTT() {
    // if (_isListening) {
    //   print("[SpeechService] STT 이미 실행 중");
    //   return;
    // }

    if (_isSpeaking) {
      stopTTS();
    }

    _isListening = true;
    recognizedText.value = ""; 
    print("==================");
    print("STT Listen 시작 ");
    print("================");
    _speech.listen(
      onResult: (result) {
        recognizedText.value = result.recognizedWords;
        print("[SpeechService] 인식 중: ${recognizedText.value}");
      },
      listenFor: const Duration(seconds: 60),  // 최대 60초 유지
      pauseFor: const Duration(seconds: 2),
      partialResults: true,
      onSoundLevelChange: (level) {
        if (level < 0.1) {
          print("[SpeechService] 조용한 상태 감지 -> STT 재시작");
          Future.delayed(const Duration(seconds: 1), startSTT);
        }
      },
    );
  }

  // ----------------------
  // 4) STT 중단
  // ----------------------
  // Future<void> stopSTT() async {
  //   if (!_isListening) return;
  //   await _speech.stop();
  //   _isListening = false;
  //   print("[SpeechService] STT 중단");
  // }

  
  // 5) TTS 실행 (음성 출력)
  Future<void> ttsspeak(String text) async {
    print("============");
    print("TTS 시작 !!");
    print("===========");
    if (text.isEmpty) return;

    // if (_isListening) {
    //   await stopSTT();
    // }

    _isSpeaking = true;
    print("[SpeechService] TTS 발화: $text");
    await _flutterTts.speak(text);
    startSTT();
  }

  // ----------------------
  // 6) TTS 중단
  // ----------------------
  Future<void> stopTTS() async {
    if (!_isSpeaking) return;
    await _flutterTts.stop();
    _isSpeaking = false;
    print("[SpeechService] TTS 중단");
  }

void moveToChatPage() {
  if (Get.currentRoute != "/ChatBotPage") {
    Future.delayed(Duration.zero, () {
      chatController.clearMessages(); // 🔥 기존 메시지 삭제
      Get.off(() => ChatBotPage());
    });
  }
}
  // ----------------------
  // 7) 서버 전송 및 응답 처리
  // ----------------------
  Future<void> sendToServer(String userMessage) async {
    print("[SpeechService] 사용자 입력: $userMessage");

    // 🔥 사용자 입력을 채팅 목록에 추가
    chatController.addMessage("You: $userMessage");
    int retryCount = 0;
    const int maxRetries = 3;

    while (retryCount < maxRetries) {
      try {
        final response = await ApiService.sendMessageToServer(userMessage);
        print("[SpeechService] 서버 응답: $response");
        // 🔥 서버 응답을 RxString 변수에 저장
        serverResponse.value = response;

        // 🔥 서버 응답을 채팅 목록에 추가
        chatController.addMessage(response);

        await ttsspeak(response);

      // 🔥 "시작" 감지 후 자동으로 페이지 이동
      if (userMessage.contains("시작")) {
        moveToChatPage();
      }

        return;
      } catch (e) {
        retryCount++;
        print("[SpeechService] 서버 요청 실패 ($retryCount/$maxRetries): $e");
        await Future.delayed(const Duration(seconds: 2));
      }
    }

    Get.snackbar("Error", "서버 응답을 받을 수 없습니다.");
  }
}
