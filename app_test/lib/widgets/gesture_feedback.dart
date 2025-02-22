import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // HapticFeedback 사용
import 'package:get/get.dart';
import 'package:app_test/services/speech_service.dart';
import 'dart:async';

class GestureControlWidget extends StatefulWidget {
  final Widget child;

  const GestureControlWidget({Key? key, required this.child}) : super(key: key);

  @override
  _GestureControlWidgetState createState() => _GestureControlWidgetState();
}

class _GestureControlWidgetState extends State<GestureControlWidget> {
  final SpeechService speechService = Get.find<SpeechService>();

  bool _isSttActive = false;         // STT가 현재 활성화 여부
  Timer? _sttVibrationTimer;         // STT 진행 중 주기적 진동 Timer

  @override
  void initState() {
    super.initState();
    // SpeechService의 isRecordingRx 상태 변화를 구독합니다.
    speechService.isRecordingRx.listen((isRecording) {
      if (!isRecording && _isSttActive) {
        _stopSTTWithVibration();
      }
    });
  }

  /// STT 시작 + 중간 강도 진동 + 주기적 약한 진동 타이머 가동
  void _startSTTWithVibration() {
    print("[GestureControlWidget] 단일 탭으로 STT 시작");
    setState(() {
      _isSttActive = true;
    });

    HapticFeedback.lightImpact();

    // 2) STT 시작
    speechService.startSTT();

    // 3) 주기적 약한 진동 (가벼운 진동), 예시: 0.5초 간격
    _sttVibrationTimer?.cancel();
    _sttVibrationTimer = Timer.periodic(
      const Duration(milliseconds: 500),
      (timer) {
        if (!_isSttActive) {
          timer.cancel();
        } else {
          HapticFeedback.lightImpact();
        }
      },
    );
  }

  // 진동 종료 및 Timer 해제
  void _stopSTTWithVibration() {
    print("[GestureControlWidget] STT 종료: 진동 타이머 종료");
    setState(() {
      _isSttActive = false;
    });
    _sttVibrationTimer?.cancel();
    }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        GestureDetector(
        
          // 1) 단일 탭 -> STT 토글
          onTap: () {
            if (!_isSttActive) {
              // STT가 꺼져 있으면 STT 시작
              _startSTTWithVibration();
            } 
          },

          // // 3) 가로 드래그 -> TTS 속도 조절
          // onHorizontalDragUpdate : (details) {
          //   double sensitivity = 0.05;    // 속도 변하는 정도
          //   if (details.delta.dx > 0) {
          //     print("화면을 위로 스크롤: 속도 증가");
          //     speechService.updateSpeechRate(sensitivity);
          //   } else if (details.delta.dx < 0) {
          //     print("화면을 아래로 스크롤: 속도 감소");
          //     speechService.updateSpeechRate(-sensitivity);
          //   }
          // },

          child: Container(
            color: Colors.transparent, // 터치 감지 영역 확장
            width: double.infinity,
            height: double.infinity,
            child: widget.child, // 실제 UI
          ),
        ),
      ],
    );
  }
}