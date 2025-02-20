import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:app_test/services/speech_service.dart';

class SpeedControlWidget extends StatelessWidget {
  final SpeechService speechService = Get.find<SpeechService>();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Obx(() => Text(
              "TTS 속도: ${speechService.currentSpeechRate.value.toStringAsFixed(2)}",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            )),
        Slider(
          value: speechService.currentSpeechRate.value,
          min: 0.5, // 최소 속도
          max: 5.0, // 최대 속도
          divisions: 20, // 세밀한 조절 가능
          label: speechService.currentSpeechRate.value.toStringAsFixed(2),
          onChanged: (value) {
            speechService.updateSpeechRate(value - speechService.currentSpeechRate.value);
          },
        ),
      ],
    );
  }
}
