import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter/services.dart';
import 'package:app_test/services/speech_service.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:app_test/services/api_service.dart';
import 'dart:math';

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

    // 1) AnimationController 설정 (2초 주기로 반경이 1.0 ~ 1.5 사이를 오르내림)
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    // 2) radius 값을 1.0에서 1.5까지 천천히 오르내리는 Tween
    _gradientRadius = Tween<double>(begin: 0.7, end: 1.5).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );

    // 3) isRecordingRx가 true -> 애니메이션 반복, false -> 중지
    speechService.isRecordingRx.listen((isRecording) {
      if (isRecording) {
        // 왕복 애니메이션
        _animationController.repeat(reverse: true);
      } else {
        // 애니메이션 정지 & 초기화
        _animationController.stop();
        _animationController.value = 1.0; 
      }
    });
  }

  @override
  void dispose() {
    // 메모리 누수를 막기 위해 dispose 시 컨트롤러 해제
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // 1) 중앙 마이크 아이콘 + 그라데이션 애니메이션
          Center(
            child: Obx(() {
              bool isRecording = speechService.isRecordingRx.value;

              // AnimatedBuilder로 _gradientRadius.value를 실시간 반영
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
                                const Color.fromARGB(255, 91, 148, 248).withOpacity(0.9),   // 중심 색상
                                const Color.fromARGB(255, 238, 216, 216),  // 외곽 색상
                              ],
                              // radius에 애니메이션 값(_gradientRadius.value) 적용
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
          ),

          // 2) 왼쪽 50픽셀 영역: 위/아래 드래그로 TTS 속도 조절
          Positioned(
            left: 0,
            top: 0,
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
                  HapticFeedback.lightImpact();
                  _dragAccumulator = 0.0;
                }

                // 아래로 드래그 (delta.dy > 0): 속도 감소
                if (_dragAccumulator >= _stepThreshold) {
                  speechService.updateSpeechRate(-0.1);
                  HapticFeedback.lightImpact();
                  _dragAccumulator = 0.0;
                }
              },
              onVerticalDragEnd: (details) {
                // 드래그 종료 시 TTS 속도 안내
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
              child: Container(color: Colors.transparent),
            ),
          ),
        ],
      ),
    );
  }
}
