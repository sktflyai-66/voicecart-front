import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:get/get.dart';

class ApiService {
  static const String baseUrl = 'http://3.107.238.79:8000';  //https://strong-sawfish-leading.ngrok-free.app';

  // 메시지를 서버로 보내고, 바로 응답을 받아 반환하는 함수
  static Future<String> sendMessageToServer(String message) async {
    final url = Uri.parse('$baseUrl/chat');
    print("post 메서드 사용해서 서버로 전송");
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'user_message': message,
          'session_id': 'test123'
        }),
      );

      if (response.statusCode == 200) {
        final utf8DecodedResponse = utf8.decode(response.bodyBytes);
        final data = jsonDecode(utf8DecodedResponse);
        return data['response'];
      } else {
        Get.snackbar('Error', 'Failed to send message: ${response.statusCode}');
        return "Error";
      }
    } catch (e) {
      Get.snackbar('Error', 'Error sending message: $e');
      print("Error: $e");
      return "Error";
    }
  }

  // 서버에서 초기 문장을 가져오는 함수
  static Future<String> getServerText() async {
    final url = Uri.parse('$baseUrl/initial');

    try {
      final response = await http.get(url,
      headers: {'ngrok-skip-browser-warning': 'true'} //ngrox 경고 페이지 우회
      ); 
      if (response.statusCode == 200) {
        final utf8DecodedResponse = utf8.decode(response.bodyBytes);
        final data = jsonDecode(utf8DecodedResponse);
        return data['text'];
      } else {
        Get.snackbar('Error', 'Failed to fetch initial text: ${response.statusCode}');
        return "Error";
      }
    } catch (e) {
      Get.snackbar('Error', 'Error fetching initial text: $e');
      return "Error";
    }
  }
}