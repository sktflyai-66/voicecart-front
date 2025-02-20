// touch.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:app_test/services/speech_service.dart';
import 'package:app_test/controllers/speed_controller.dart';
class TouchControlWidget extends StatelessWidget {
  final Widget child;
  final SpeechService speechService = Get.find<SpeechService>();

  TouchControlWidget({required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        GestureDetector(
          onTap: () {
            print("단일 탭: STT 시작");
            speechService.startSTT();
          },
          onDoubleTap: () {
            print("더블 탭: TTS 중단");
            speechService.stopTTS();
          },
          onVerticalDragUpdate: (details) {
            double sensitivity = 0.05;
            if (details.delta.dy < 0) {
              print("화면을 위로 스크롤: 속도 증가");
              speechService.updateSpeechRate(sensitivity);
            } else if (details.delta.dy > 0) {
              print("화면을 아래로 스크롤: 속도 감소");
              speechService.updateSpeechRate(-sensitivity);
            }
          },
          child: Container(
            color: Colors.transparent, // 터치 감지 영역 확장
            width: double.infinity,
            height: double.infinity,
            child: child, // ChatBotPage가 여기에 렌더링됨
          ),
        ),
        // 현재 속도 정보를 화면에 오버레이로 표시
        Positioned(
          top: 100,
          right: 10,
          child: Obx(() => Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  "속도: ${speechService.currentSpeechRate.value.toStringAsFixed(2)}",
                  style: TextStyle(color: Colors.white, fontSize: 12),
                ),
              )),
        ),
      ],
    );
  }
}
