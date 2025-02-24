import 'package:flutter_tts/flutter_tts.dart';
import 'package:get/get.dart';
import 'package:app_test/services/api_service.dart';
import 'package:app_test/controllers/chat_controller.dart';
import 'package:record/record.dart';
import 'dart:convert';
import 'dart:io';
import 'package:google_speech/google_speech.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:async';
import 'package:path_provider/path_provider.dart'; // 임시 파일 경로 획득용


enum ApiMode { chat, product }

class SpeechService extends GetxService {
  final ChatController chatController = Get.find<ChatController>();
  // 수정: AudioRecorder() -> Record()
  final record = AudioRecorder();
  
  ApiMode mode = ApiMode.chat;
  double _speechRate = 1.0;
  // 현재 속도를 반응형으로 관리
  final RxDouble currentSpeechRate = 1.0.obs;

  late FlutterTts _flutterTts;
  bool _isSpeaking = false;
  bool _isRecording = false;

  // 기존 bool _isRecording 대신, 다음과 같이 RxBool 추가:
  final RxBool isRecordingRx = false.obs;

  final RxString recognizedText = ''.obs;
  final RxString serverResponse = ''.obs;

  bool get isSpeaking => _isSpeaking;

  /// Google Cloud STT 설정
  late SpeechToText _speechToText;
  late ServiceAccount _serviceAccount;

  @override
  void onInit() {
    super.onInit();
    _initializeGoogleSTT();
    _initializeTTS();
    print("SpeechService 초기화 완료");
    // 앱 시작 시 자동으로 STT 스트리밍을 시작하지 않습니다.
  }

  /// 1) Google STT 초기화
  Future<void> _initializeGoogleSTT() async {
    try {
      final jsonCredentials = await rootBundle.loadString('assets/fly-ai-stt-4aadfc813aec.json');
      _serviceAccount = ServiceAccount.fromString(jsonCredentials);
      _speechToText = SpeechToText.viaServiceAccount(_serviceAccount);
      print("Google STT 초기화 성공");
    } catch (e) {
      print("[Error] Google STT 초기화 실패: $e");
    }
  }

  /// 2) TTS 초기화
  Future<void> _initializeTTS() async {
    _flutterTts = FlutterTts();
    await _flutterTts.setLanguage("ko-KR");
    await _flutterTts.setPitch(1.0);
    await _flutterTts.setSpeechRate(_speechRate);

    _flutterTts.setStartHandler(() {
      _isSpeaking = true;
    });

    _flutterTts.setCompletionHandler(() {
      _isSpeaking = false;
    });

    _flutterTts.setCancelHandler(() {
      _isSpeaking = false;
    });
  }

  /// 3) STT 시작 (실시간 스트리밍 방식)
  Future<void> startSTT() async {
    if (_isRecording) {
      print("[SpeechService] 이미 녹음 중입니다.");
      return;
    }

    if (_isSpeaking) {
      await stopTTS();
    }

    // 마이크 권한 요청
    if (await Permission.microphone.request().isGranted) {
      _isRecording = true;
      recognizedText.value = "";
      isRecordingRx.value = true; 
      print("실시간 스트리밍 STT 시작");

      // record 라이브러리의 스트리밍 모드를 사용하여 오디오 스트림 시작
      final audioStream = await record.startStream(
        const RecordConfig(
          encoder: AudioEncoder.pcm16bits, // PCM 16비트 스트리밍
          sampleRate: 16000,
          numChannels: 1, // 모노 채널
        ),
      );

      // Google STT 스트리밍 인식 설정
      final streamingConfig = StreamingRecognitionConfig(
        config: RecognitionConfig(
          encoding: AudioEncoding.LINEAR16,
          sampleRateHertz: 16000,
          languageCode: 'ko-KR',
          enableAutomaticPunctuation : false,
          useEnhanced : true,
          speechContexts: [
            SpeechContext(['리스트','구매','일번', '이번', '삼번','사번','쿤달']),     /////////////////////////// 브랜드 DB에서 가져오기
          ],
          
        ),
        interimResults: true, // 중간 결과를 실시간으로 받음
        
      );

DateTime lastSpeechTime = DateTime.now();  // 마지막으로 음성이 감지된 시간
Duration silenceTimeout = Duration(seconds: 10); // N초 동안 말이 없으면 종료
_flutterTts.speak("말씀해주세요."); // 사용자에게 음성 안내
_speechToText.streamingRecognize(
  streamingConfig,
  audioStream,
).listen(
  (response) {
    for (var result in response.results) {
      if (result.alternatives.isNotEmpty) {
        recognizedText.value = result.alternatives.first.transcript;
        silenceTimeout = Duration(seconds: 2);
        print("인식된 텍스트: ${recognizedText.value}");
        lastSpeechTime = DateTime.now();  // 새로운 발화가 감지되면 시간 갱신
        if (result.isFinal) {
          print("최종 결과: ${recognizedText.value}");
          sendToServer(recognizedText.value);
          recognizedText.value = "";
        }
      }
    }
  },
onDone: () {
  _isRecording = false;
  isRecordingRx.value = false;
  print("[SpeechService] STT 스트리밍 종료됨");
},
onError: (error) {
  _isRecording = false;
  isRecordingRx.value = false;
  print("[Error] STT 오류 발생: $error");
},
);

// 주기적으로 silenceTimeout을 체크하여 강제 종료
Timer.periodic(Duration(milliseconds: 500), (timer) async{
  if (_isRecording && DateTime.now().difference(lastSpeechTime) > silenceTimeout) {
    print("[SpeechService] 사용자가 말을 멈춘 것으로 판단하여 STT 종료");
  await record.stop(); // 마이크 입력 중지
  _isRecording = false;
  
    _isRecording = false;
    timer.cancel();
  }
});

    }
  }
  /// 5) TTS 실행
  Future<void> ttsspeak(String text) async {
    if (text.isEmpty) return;
    _isSpeaking = true;
    await _flutterTts.speak(text);
  }

  /// 6) TTS 중단
  Future<void> stopTTS() async {
    if (!_isSpeaking) return;
    await _flutterTts.stop();
    _isSpeaking = false;
    print("TTS 중단됨");
  }

  // TTS 속도를 조절하는 메서드 추가
  Future<void> updateSpeechRate(double delta) async {
    _speechRate = (_speechRate + delta).clamp(0.3, 10.0);
    currentSpeechRate.value = _speechRate; // Rx 변수 업데이트
    await _flutterTts.setSpeechRate(_speechRate);
    print("TTS 속도 업데이트: $_speechRate");
  }

  /// 7) 서버 전송 및 응답 처리
  Future<void> sendToServer(String userMessage) async {
    print("[SpeechService] 사용자 입력: $userMessage");
    chatController.addMessage("You: $userMessage");

    try {
      switch (mode) {
        case ApiMode.chat:
          final response = await ApiService.sendMessageToServer_chat(userMessage);
          print(response);
          serverResponse.value = response['response'];
          chatController.addMessage(response['response']);
          await ttsspeak(response['response']);

          // ///////////////////////디버깅 용
          // chatController.addMessage(response.toString());
          // ///////////////////////
          
          if (response['is_done'] == true) {
            print("/product 모드로 전환 : is_done = true");
            mode = ApiMode.product;
            // chatController.addMessage("mode : product 로 바꿉니다.");
          }
          break;
        case ApiMode.product:
          final reportResponse = await ApiService.getProductReport(userMessage);
          chatController.addMessage(reportResponse["response"]);
          //   ///////////////////////디버깅 용
          // chatController.addMessage(reportResponse.toString());
          // ///////////////////////
        
          await ttsspeak(reportResponse["response"]);
          break;
      }
    } catch (e) {
      print("[SpeechService] 서버 요청 중 오류: $e");
    }
  }
}
