import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:app_test/controllers/chat_controller.dart';
import 'package:app_test/services/api_service.dart';
import 'package:app_test/services/speech_service.dart';
import 'package:app_test/style/style.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'dart:math';
class ChatBotPage extends StatefulWidget {
  @override
  _ChatBotPageState createState() => _ChatBotPageState();
}

class _ChatBotPageState extends State<ChatBotPage> {
  final ChatController chatController = Get.put(ChatController());
  final SpeechService _speechService = Get.find<SpeechService>();
  final ScrollController _scrollController = ScrollController();

  // 핀치 제스처용 변수 (텍스트 확대/축소)
  double scaleFactor = 1.0;
  double baseScaleFactor = 1.0;
  bool _isScaling = false;

  // TTS 속도 관련 변수 (왼쪽 숨은 제스처 영역)
  double _dragAccumulator = 0.0;
  final double _stepThreshold = 30.0;  // 스크롤할 때 픽셀 이동 수(100픽셀 이동하면 속도 1단위 조절)

  @override
  void initState() {
    super.initState();
    randomInt = Random().nextInt(1000);
    // // 테스트용 메시지 추가
    // chatController.addMessage("You: 안녕하세요");
    // chatController.addMessage("Bot: 반가워요. 무엇을 도와드릴까요?");
    // chatController.addMessage("You: 상품 추천해주세요");
    // chatController.addMessage("Bot: 어떤 종류의 상품을 찾으시나요?");
    // chatController.addMessage("You: 가전제품");
    // chatController.addMessage("Bot: 가전제품 중 어떤 제품을 찾으시나요?");
    // chatController.addMessage("You: 세탁기");
    // chatController.addMessage("Bot: 세탁기 브랜드에는 LG, 삼성 등이 있습니다.");
    // ///////////////////////////////////////////

    // 메시지 변화 시 스크롤 자동 하단 이동
    chatController.messages.listen((_) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        title: Text(
          '상품 추천',
          style: AppTextStyles.mainTitle,
        ),
        backgroundColor: AppColors.backgroundColor,
        centerTitle: true,
        elevation: 10,
      ),
      // Stack을 사용해 채팅 영역과 왼쪽 숨은 제스처 영역을 겹쳐 배치
      body: Stack(
        children: [
          // 채팅 영역 (전체 화면)
          GestureDetector(
            // 핀치 제스처로 채팅 텍스트 크기를 조절
            onScaleStart: (details) {
              baseScaleFactor = scaleFactor;
              _isScaling = true;
              print("핀치 제스처 시작");
            },
            onScaleUpdate: (details) {
              setState(() {
                scaleFactor = (baseScaleFactor * details.scale).clamp(1.0, 3.0);
              });
            },
            onScaleEnd: (details) {
              setState(() {
                _isScaling = false;
                print("핀치 제스처 끝");
              });
            },
            child: Column(
              children: [
                // 채팅 메시지 리스트 영역
                Expanded(
                  child: Obx(
                    () => ListView.builder(
                      controller: _scrollController,
                      physics: _isScaling
                          ? const NeverScrollableScrollPhysics()
                          : const BouncingScrollPhysics(),
                      padding: EdgeInsets.all(10),
                      itemCount: chatController.messages.length,
                      itemBuilder: (context, index) {
                        final message = chatController.messages[index];
                        final isUserMessage = message.startsWith("You:");
                        return Align(
                          alignment: isUserMessage
                              ? Alignment.centerRight
                              : Alignment.centerLeft,
                          child: Container(
                            margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                            padding: EdgeInsets.all(12),
                            decoration: isUserMessage
                                ? ChatBubbleStyles.chatUserBubbleStyle
                                : ChatBubbleStyles.chatBotBubbleStyle,
                            child: Text(
                              message.replaceFirst("You: ", ""),
                              style: AppTextStyles.messageStyle.copyWith(
                                fontSize: (AppTextStyles.messageStyle.fontSize ?? 14) * scaleFactor,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                const Divider(height: 1, color: AppColors.textColor),
                // 실시간 음성 인식 결과 영역
                Container(
                  padding: EdgeInsets.all(12),
                  child: Obx(() {
                    return Text(
                      _speechService.recognizedText.value.isNotEmpty
                          ? _speechService.recognizedText.value
                          : "",
                      style: AppTextStyles.secondaryText,
                      textAlign: TextAlign.center,
                    );
                  }),
                ),
              ],
            ),
          ),
          // TTS 속도 제어 Gesture 영역 (왼쪽 숨은 영역)
          Positioned(
            left: 0,
            top: 0,
            bottom: 0,
            width: 50,
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,

              onVerticalDragStart: (details) {
                _dragAccumulator = 0.0;
                print('TTS 조절 드래그 시작: ${details.globalPosition}');
              },

              onVerticalDragUpdate: (details) {
                _dragAccumulator += details.delta.dy;

                // 위로 드래그 (delta.dy 음수) : 속도 증가
                if (_dragAccumulator <= -_stepThreshold) {
                  _speechService.updateSpeechRate(0.1);
                  HapticFeedback.lightImpact();
                  print('TTS 속도 증가');
                  _dragAccumulator = 0.0;
                }
    
                // 아래로 드래그 (delta.dy 양수) : 속도 감소
                if (_dragAccumulator >= _stepThreshold) {
                  _speechService.updateSpeechRate(-0.1);
                  HapticFeedback.lightImpact();
                  print('TTS 속도 감소');
                  _dragAccumulator = 0.0;
                }
              },

              onVerticalDragEnd: (details) {
                print('TTS 조절 드래그 종료. 최종 TTS 속도: ${(_speechService.currentSpeechRate.value * 100).toStringAsFixed(0)}');
                _speechService.ttsspeak("현재 속도는 ${(_speechService.currentSpeechRate.value).toStringAsFixed(1)}배속입니다.");   // 소수점 1자리까지 배속 안내
                  Fluttertoast.cancel();  // 이전 토스트 취소
                  Fluttertoast.showToast(
                    msg: "현재 속도는 ${(_speechService.currentSpeechRate.value).toStringAsFixed(1)}배속입니다.",
                    toastLength: Toast.LENGTH_SHORT,
                    gravity: ToastGravity.BOTTOM,
                    backgroundColor: Colors.black.withOpacity(0.7),
                    textColor: Colors.white,
                    fontSize: 16.0,
                );
              },
              // 실제로 쓸 때는 Container() 비우기
              child: Container(color: const Color.fromARGB(96, 252, 252, 250).withOpacity(0.3))
            ),
          ),
        ],
      ),
    );
  }
}
