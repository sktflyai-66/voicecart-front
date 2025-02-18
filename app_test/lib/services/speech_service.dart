import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:get/get.dart';
import 'package:app_test/controllers/chat_controller.dart';
import 'package:app_test/services/chat_service.dart';
import 'package:app_test/services/api_service.dart';

enum ApiMode {chat, product}

class SpeechService extends GetxService {
  final ChatController chatController = Get.find<ChatController>(); // ChatController 가져오기


  ApiMode mode = ApiMode.chat;    // Api 모드 초기 값은 /chat
  double _speechRate = 0.8; // TTS 기본 속도

  late stt.SpeechToText _speech;
  late FlutterTts _flutterTts;

  // 서버 응답을 저장할 Rx 변수 추가
  final RxString serverResponse = ''.obs;

  // 상태 변수
  bool _isListening = false;   // STT 활성 상태
  bool _isSpeaking = false;    // TTS 실행 여부
  // bool _sttErrorOccurred = false; // STT 오류 발생 여부

  // STT 결과 저장
  final RxString recognizedText = ''.obs;

  // 외부 접근을 위한 getter
  bool get isListening => _isListening;
  bool get isSpeaking => _isSpeaking;


  /// 초기화 메서드 (GetX의 onInit)
  @override
  void onInit() {
    super.onInit();
    print("[SpeechService] 초기화 완료");
    _speech = stt.SpeechToText();
    _flutterTts = FlutterTts();
    _initializeTTS();
    _initializeSTT();
  }

  // TTS 초기화
  Future<void> _initializeTTS() async {
    await _flutterTts.setLanguage("ko-KR");
    await _flutterTts.setPitch(1.0);
    await _flutterTts.setSpeechRate(_speechRate);

    _flutterTts.setStartHandler(() {    // TTS가 음성 합성 시작 시 호출
      _isSpeaking = true;
      print("음성 합성 시장 : setStartHandler() ");
    });

    _flutterTts.setCompletionHandler(() {   // TTS 음성 출력 완료 시 호출 (음성 합성 종료 완료되었을 때가 아님)
      print("음성 [합성] 완료 ");
      _isSpeaking = false;
      // startSTT(); // TTS가 끝나면 자동으로 STT 시작
    });

    _flutterTts.setCancelHandler(() {   // TTS 중단 시 호출
      print("TTS 중단!!");
      _isSpeaking = false;
    });
  }

  // STT 초기화
  Future<void> _initializeSTT() async {

    bool available = await _speech.initialize(
      onError: (error) {
          print("[SpeechService] STT 오류 발생: $error");
          startSTT();
      },

      onStatus: (status) {
        print("[SpeechService] STT 상태: $status");
      },
    );

    if (!available) {
      print("[SpeechService] STT를 사용할 수 없음 (권한 문제)");
    }
  }

  
  // STT 시작 (사용자 음성 듣기)
  void startSTT() {

    _isListening = true;
    recognizedText.value = ""; 
    _speech.listen(
      onResult: (result) {

        stopTTS();  // onResult 콜백함수는 음성이 인식되면 실행되므로 사용자가 말해서 인식이 시작되면 TTS stop

        recognizedText.value = result.recognizedWords;
        print("[SpeechService] 인식 중: ${recognizedText.value}");
        if (result.finalResult == true)
        {
          if(recognizedText.value.contains("빠르게") || recognizedText.value.contains("느리게")){  // TTS 속도 조절 명령어일 경우
              adjustTTSRate(recognizedText.value);
              startSTT();
          }
          else{   // 일반 STT 결과일 경우
            sendToServer(recognizedText.value);
            startSTT();
          }
        }
      },
      listenFor: const Duration(minutes: 1),  // 최대 60초 유지
      pauseFor: const Duration(seconds: 5),  // Duration 최대는 5초임(10초해도 5초임)
      partialResults: true,
    );
  }
  
  // TTS 실행 (음성 출력)
  Future<void> ttsspeak(String text) async {

    if (text.isEmpty) return;

    _isSpeaking = true;
    print("[SpeechService] TTS 발화: $text");
    await _flutterTts.speak(text);
  }

  
  // TTS 중단
  Future<void> stopTTS() async {
    if (!_isSpeaking) return;
    await _flutterTts.stop();
    _isSpeaking = false;
    print("[SpeechService] TTS 중단");
  }

  // void moveToChatPage() {
  //   if (Get.currentRoute != "/ChatBotPage") {
  //     Future.delayed(Duration.zero, () {
  //       chatController.clearMessages(); // 기존 메시지 삭제
  //       Get.off(() => ChatBotPage());
  //     });
  //   }
  // }
  
  // TTS 속도 조절 함수
  void adjustTTSRate(String command) {
    if (command.contains("빠르게")) {
      _speechRate = double.parse((_speechRate + 0.2).toStringAsFixed(1)).clamp(0.5, 2.0);   // 부동 소수점 정밀도 해결
    } else if (command.contains("느리게")) {
      _speechRate = double.parse((_speechRate - 0.2).toStringAsFixed(1)).clamp(0.5, 2.0);
    }
    int percentage = (_speechRate * 100).toInt(); // 퍼센트 변환
    _flutterTts.setSpeechRate(_speechRate);
    ttsspeak("현재 속도는 $percentage 퍼센트 입니다.");
  }
  
  
  Future<void> sendToServer(String userMessage) async {

    try {
      switch (mode) {
        // 1. /chat 엔드포인트
        case ApiMode.chat:
          chatController.addMessage("You: $userMessage");

          final response = await ApiService.sendChatMessage(userMessage);
          print("[ChatService] 서버 응답: ${response['response']}");

          serverResponse.value = response['response'];
          chatController.addMessage(response['response']);
          await ttsspeak(response['response']);

          if (response['is_done'] == true) {
            mode = ApiMode.product;
          }
          break;

        // 2. /product 엔드포인트
        case ApiMode.product:
          final reportResponse = await ApiService.sendProductRequest(userMessage);
          print("[ChatService] 제품 리포트 응답: ${reportResponse['product_describe']}");

          chatController.addMessage(reportResponse["response"]);
          await ttsspeak(reportResponse["product_describe"]);
          break;

      }
    } catch (e) {
      Get.snackbar("Error", "서버 응답을 받을 수 없습니다. 에러: $e");
      print("[ChatService] 서버 요청 중 에러: $e");
    }
  }

  // // 회원가입 전용 함수
  // Future<void> sendSignupRequest(Map<String, String> userData) async {

  //   try {
  //     final signupResponse = await ApiService.sendSignupData(userData);
  //     print("[ChatService] 회원가입 응답: ${signupResponse['response']}");

  //     chatController.addMessage(signupResponse["response"]);
  //     await ttsspeak(signupResponse["response"]);
  //   } catch (e) {
  //     Get.snackbar("Error", "회원가입 요청 중 오류 발생: $e");
  //     print("[ChatService] 회원가입 요청 중 에러: $e");
  //   }
  // }
}
