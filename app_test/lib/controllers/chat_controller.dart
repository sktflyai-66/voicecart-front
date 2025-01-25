import 'package:get/get.dart';
import '../services/api_service.dart';

class ChatController extends GetxController {
  var messages = <String>[].obs;

  void addMessage(String message) {
    messages.add(message);
  }

  Future<void> handleMessage(String message) async {
    addMessage('You: $message');

    // 메시지를 서버로 전송
    await ApiService.sendMessageToServer(message);

    // 서버로부터 메시지 가져오기
    final messagesFromServer = await ApiService.getMessagesFromServer();
    messages.addAll(messagesFromServer);
  }
}
