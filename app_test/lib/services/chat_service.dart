import 'package:get/get.dart';
import 'package:app_test/services/api_service.dart';
import 'package:app_test/controllers/chat_controller.dart';
import 'package:app_test/services/speech_service.dart';

enum ApiMode { chat, product }

class ChatService extends GetxService {
  final SpeechService speechService = Get.find<SpeechService>();
  final ChatController chatController = Get.find<ChatController>();

  ApiMode mode = ApiMode.chat;

  // 엔드포인트 /chat, /product 모드 
  Future<void> sendToServer(String userMessage) async {

    try {
      switch (mode) {
        // 1. /chat 엔드포인트
        case ApiMode.chat:
          chatController.addMessage("You: $userMessage");

          final response = await ApiService.sendChatMessage(userMessage);
          print("[ChatService] 서버 응답: ${response['response']}");

          speechService.serverResponse.value = response['response'];
          chatController.addMessage(response['response']);
          await speechService.ttsspeak(response['response']);

          if (response['is_done'] == true) {
            mode = ApiMode.product;
          }
          break;

        // 2. /product 엔드포인트
        case ApiMode.product:
          final reportResponse = await ApiService.sendProductRequest(userMessage);
          print("[ChatService] 제품 리포트 응답: ${reportResponse['product_describe']}");

          chatController.addMessage(reportResponse["response"]);
          await speechService.ttsspeak(reportResponse["product_describe"]);
          break;

      }
    } catch (e) {
      Get.snackbar("Error", "서버 응답을 받을 수 없습니다. 에러: $e");
      print("[ChatService] 서버 요청 중 에러: $e");
    }
  }

  // 회원가입 전용 함수
  Future<void> sendSignupRequest(Map<String, String> userData) async {

    try {
      final signupResponse = await ApiService.sendSignupData(userData);
      print("[ChatService] 회원가입 응답: ${signupResponse['response']}");

      chatController.addMessage(signupResponse["response"]);
      await speechService.ttsspeak(signupResponse["response"]);
    } catch (e) {
      Get.snackbar("Error", "회원가입 요청 중 오류 발생: $e");
      print("[ChatService] 회원가입 요청 중 에러: $e");
    }
  }
}
