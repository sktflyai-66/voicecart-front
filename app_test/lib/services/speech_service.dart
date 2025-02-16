import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:get/get.dart';
import 'package:app_test/services/api_service.dart';
import 'package:app_test/pages/chatbot_page.dart';
import 'package:app_test/controllers/chat_controller.dart';


enum ApiMode {chat, product, product_detail}

class SpeechService extends GetxService {
  final ChatController chatController = Get.find<ChatController>(); // 🔥 ChatController 가져오기

  ApiMode mode = ApiMode.chat;    // Api 모드 초기 값은 /chat

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
    await _flutterTts.setSpeechRate(1.0);

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

  // 2) STT 초기화
  Future<void> _initializeSTT() async {

    bool available = await _speech.initialize(
      onError: (error) {
          // final errorTime = DateTime.now();
          // final elapsed = errorTime.difference(_sttStartTime!);
          // print("STT 총 실행 시간 (오류 발생): ${elapsed.inSeconds}초");
          // _sttStartTime = null;
          // _stopSTT();
          print("[SpeechService] STT 오류 발생: $error");
          startSTT();
      },

      onStatus: (status) {
        print("[SpeechService] STT 상태: $status");
        if (status == "done") {  // 원래는 notlistening인데 바꿈
          // if (recognizedText.value.trim().isNotEmpty) {
          //   sendToServer(recognizedText.value);
          // } 
          // else {
          //   // startSTT();
          // }
        }
        // _sttErrorOccurred = false; // 오류가 해결되면 초기화
      },
    );

    if (!available) {
      print("[SpeechService] STT를 사용할 수 없음 (권한 문제)");
    }
  }

  
  // 3) STT 시작 (사용자 음성 듣기)
  void startSTT() {
    // if (_speech.isListening == true) {
    //   print("[SpeechService] STT 이미 실행 중");
    //   return;
    // }

    // if (_isSpeaking) {
    //   stopTTS();
    // }

    _isListening = true;
    recognizedText.value = ""; 
    print("==================");
    print("STT Listen 시작 ");
    print("================");
    _speech.listen(
      onResult: (result) {
        // 테스트할때는 여기서 setState((){ })로 recognizedText에 할당했는데, getX써서 안해도 되나?

        stopTTS();  // onResult 콜백함수는 음성이 인식되면 실행되므로 TTS stop

        recognizedText.value = result.recognizedWords;
        print("[SpeechService] 인식 중: ${recognizedText.value}");
        if (result.finalResult == true)
        {
          print("STT 인식 최종 결과 뜸");
          sendToServer(recognizedText.value);
          print("서버에 전송 함!!");
          startSTT();
        }
      },
      listenFor: const Duration(minutes: 5),  // 최대 60초 유지
      pauseFor: const Duration(seconds: 5),  // Duration 최대는 5초임(10초해도 5초임)
      partialResults: true,
      // onSoundLevelChange: (level) {
      //   if (level < 0.1) {
      //     print("[SpeechService] 조용한 상태 감지 -> STT 재시작");
      //     Future.delayed(const Duration(seconds: 1), startSTT);
      //   }
      // },
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
    // startSTT();
  }

  
  // 6) TTS 중단
  Future<void> stopTTS() async {
    if (!_isSpeaking) return;
    await _flutterTts.stop();
    _isSpeaking = false;
    print("[SpeechService] TTS 중단");
  }

  void moveToChatPage() {
    if (Get.currentRoute != "/ChatBotPage") {
      Future.delayed(Duration.zero, () {
        chatController.clearMessages(); // 기존 메시지 삭제
        Get.off(() => ChatBotPage());
      });
    }
  }


  // 7) 서버 전송 및 응답 처리
Future<void> sendToServer(String userMessage) async {
  print("[SpeechService] 사용자 입력: $userMessage");
  chatController.addMessage("You: $userMessage");

  try {
    switch (mode) {
      case ApiMode.chat:
        // 1번 API: 채팅 메시지 전송
        final response = await ApiService.sendMessageToServer_chat(userMessage);
        print("[SpeechService] 서버 응답: ${response['response']}");
        print("서버 응답(키워드) : ${response['keyword']}");

        // 응답을 RxString 변수에 저장 및 채팅 목록에 추가
        serverResponse.value = response['response'];
        chatController.addMessage(response['response']);
        await ttsspeak(response['response']);

        // "시작" 메시지 감지 시 페이지 이동
        if (userMessage.contains("시작")) {
          moveToChatPage();
        }
        // is_done == true 일 때 2번 APi로 
        if (response['is_done'] == true) {
          mode = ApiMode.product;
        }
        break;

      case ApiMode.product:
        // 2번 API: 제품 리포트 요청 
        final reportResponse = await ApiService.getProductReport(userMessage);
        print("[SpeechService] 제품 리포트 응답: ${reportResponse['product_describe']}");

        // 응답 JSON의 "product_describe" 값을 채팅 목록에 추가 및 TTS 실행
        chatController.addMessage(reportResponse["product_describe"]);
        List<dynamic> productIds = reportResponse["product_id"] ;
        
        // 제품 리포트 내용 TTS 실행
        await ttsspeak(reportResponse["product_describe"]);

        bool validInput = false;    // 사용자가 상품 번호를 말했을 때만 true
        int selectedIndex = -1;   // 사용자가 선택한 상품 번호 인덱스

        // 반복해서 사용자에게 안내 메시지를 전달(수정 해야함 로직 이상한듯?)==============
        while (!validInput) {
          
          await ttsspeak("""
아래는 원하시는 키워드에 따른 상품 리스트에 관련한 내용입니다.
더 자세하게 알고 싶은 상품이 있으시면, 해당 상품의 번호를 말해주세요.
이전으로 돌아가고 싶으시면, “돌아가기”로 말씀해주세요.
""".trim());

          String spokenText = recognizedText.value.trim();
          print("[SpeechService] 사용자가 말한 내용: $spokenText");

          // "돌아가기"가 포함되어 있으면 이전 모드로 전환
          if (spokenText.contains("돌아가기")) {
            await ttsspeak("이전으로 돌아갑니다.");
            mode = ApiMode.chat; 
            return;
          }

          // 숫자를 말했는지 확인
          int? number = int.tryParse(spokenText);
          if (number != null) {
            int index = number - 1; // 사용자가 말하는 숫자 범위는 1이상을 가정함
            if (index >= 0 && index < productIds.length) {
              selectedIndex = index;
              validInput = true;
            } else {
              await ttsspeak("잘못된 번호입니다. 다시 말씀해주세요.");
            }
          } else {
            await ttsspeak("유효한 번호를 인식하지 못했습니다. 다시 말씀해주세요.");
          }
          recognizedText.value = "";
        }
        // 유효한 제품 번호가 입력되면 모드를 제품 상세 모드로 전환
        mode = ApiMode.product_detail;
        String selectedProductId = productIds[selectedIndex];

        final productDetail = await ApiService.getProductDetail(
          selectedProductId,
          "keyword",      
          "test123",      
        );

        print("[SpeechService] 제품 상세 응답: ${productDetail["product_describe"]}");
        chatController.addMessage(productDetail["product_describe"]);
        await ttsspeak(productDetail["product_describe"]);
        break;

      case ApiMode.product_detail:
      // 딱히 없어도 되는듯?
        break;

    }
  } catch (e) {
    Get.snackbar("Error", "서버 응답을 받을 수 없습니다. 에러: $e");
    print("[SpeechService] 서버 요청 중 에러: $e");
  }
}
}