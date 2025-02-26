import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter/services.dart';
import 'package:app_test/services/speech_service.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:app_test/services/api_service.dart';
import 'dart:math';
import 'package:vibration/vibration.dart';
class MicIconPage extends StatefulWidget {
  @override
  _MicIconPageState createState() => _MicIconPageState();
}

class _MicIconPageState extends State<MicIconPage> with SingleTickerProviderStateMixin {
  final SpeechService speechService = Get.find<SpeechService>();

  // TTS 속도 조절용
  double _dragAccumulator = 0.0;
  final double _stepThreshold = 30.0;

  // 그라데이션 애니메이션 컨트롤러 및 보간
  late AnimationController _animationController;
  late Animation<double> _gradientRadius;

  @override
  void initState() {
    super.initState();
    randomInt = Random().nextInt(1000);

    // 1) AnimationController 설정 (1200ms 주기로 반경이 0.7 ~ 1.5 사이를 오르내림)
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    // 2) radius 값을 0.7에서 1.5까지 천천히 오르내리는 Tween
    _gradientRadius = Tween<double>(begin: 0.7, end: 1.5).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );

    // 3) isRecordingRx가 true -> 애니메이션 반복, false -> 중지
    speechService.isRecordingRx.listen((isRecording) {
      if (isRecording) {
        _animationController.repeat(reverse: true);
      } else {
        _animationController.stop();
        _animationController.value = 1.0;
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // 중앙 영역: 인식된 텍스트와 마이크 아이콘을 세로로 배치
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 인식된 텍스트 출력 (마이크 아이콘 위쪽)
                Obx(() {
                  String recognized = speechService.recognizedText.value;
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    child: Text(
                      recognized,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 28,                // 폰트 크기도 약간 키웠습니다.
                        fontWeight: FontWeight.bold, // 굵은 폰트 적용
                      ),
                      textAlign: TextAlign.center,
                    ),
                  );
                }),
                // 마이크 아이콘 및 그라데이션 애니메이션
                Obx(() {
                  bool isRecording = speechService.isRecordingRx.value;
                  return AnimatedBuilder(
                    animation: _gradientRadius,
                    builder: (context, child) {
                      return Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: isRecording
                              ? RadialGradient(
                                  colors: [
                                    const Color.fromARGB(255, 91, 148, 248).withOpacity(0.9),
                                    const Color.fromARGB(255, 238, 216, 216),
                                  ],
                                  stops: const [0.4, 1.0],
                                  radius: _gradientRadius.value,
                                )
                              : null,
                        ),
                        child: Image.asset(
                          'assets/image.png',
                          width: 150,
                          height: 150,
                        ),
                      );
                    },
                  );
                }),
                    // 하단에 TTS 내용 출력 (예: SizedBox로 간격 조정)
                // SizedBox(height: 20),
                // Obx(() {
                //   return Container(
                //     padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                //     color: Colors.black.withOpacity(0.7),
                //     child: Text(
                //       speechService.serverResponse.value,
                //       style: TextStyle(
                //         color: Colors.white,
                //         fontSize: 20,
                //         fontWeight: FontWeight.bold,
                //       ),
                //       textAlign: TextAlign.center,
                //     ),
                //   );
                // }),
              ],
            ),
          ),
          // 왼쪽 50픽셀 영역: 위/아래 드래그로 TTS 속도 조절 기능
          Positioned(
            left: 0,
            top: 100,
            bottom: 0,
            width: 50,
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onVerticalDragStart: (details) {
                _dragAccumulator = 0.0;
              },
              onVerticalDragUpdate: (details) {
                _dragAccumulator += details.delta.dy;

                // 위로 드래그 (delta.dy < 0): 속도 증가
                if (_dragAccumulator <= -_stepThreshold) {
                  speechService.updateSpeechRate(0.1);
                  Vibration.vibrate(duration: 10); // haptic 대신 vibration 사용(50ms 진동)
                  _dragAccumulator = 0.0;
                }

                // 아래로 드래그 (delta.dy > 0): 속도 감소
                if (_dragAccumulator >= _stepThreshold) {
                  speechService.updateSpeechRate(-0.1);
                  Vibration.vibrate(duration: 10); // haptic 대신 vibration 사용(50ms 진동)
                  _dragAccumulator = 0.0;
                }
              },
              onVerticalDragEnd: (details) {
                speechService.ttsspeak(
                    "현재 속도는 ${speechService.currentSpeechRate.value.toStringAsFixed(1)}배속입니다.");
                Fluttertoast.cancel();
                Fluttertoast.showToast(
                  msg: "현재 속도는 ${speechService.currentSpeechRate.value.toStringAsFixed(1)}배속입니다.",
                  toastLength: Toast.LENGTH_SHORT,
                  gravity: ToastGravity.BOTTOM,
                  backgroundColor: Colors.white,
                  textColor: Colors.black,
                  fontSize: 16.0,
                );
              },
              child: Container(color: const Color.fromARGB(83, 255, 254, 254).withOpacity(0)),
            ),
          ),
        ],
      ),
    );
  }
}
