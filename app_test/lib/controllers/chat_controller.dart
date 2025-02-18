import 'package:get/get.dart';
import '../services/api_service.dart';

class ChatController extends GetxController {
  var messages = <String>[].obs;

  void addMessage(String message) {
    messages.add(message);
  }
  
  void clearMessages() {
    messages.clear(); // 🔥 메시지 리스트 초기화
  }
  
  Future<void> handleMessage(String message) async {
    addMessage('You: $message');

    // 메시지를 서버로 보내고, 응답을 받아 직접 추가
    final responseFromServer = await ApiService.sendMessageToServer_chat(message);
    messages.add('Bot: ${responseFromServer}');  // 응답을 바로 UI에 추가
  }
}
