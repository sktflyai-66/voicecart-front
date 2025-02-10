import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:get/get.dart';
import '../dto/selection_dto.dart';

class ApiService {
  static const String baseUrl = 'http://127.0.0.1:8000';

  // 메시지를 서버로 보내고, 바로 응답을 받아 반환하는 함수
  static Future<String> sendMessageToServer(String message) async {
    final url = Uri.parse('$baseUrl/message');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'user_input': message}),
      );

      if (response.statusCode == 200) {
        final utf8DecodedResponse = utf8.decode(response.bodyBytes);  // UTF-8 디코딩
        final data = jsonDecode(utf8DecodedResponse);
        return data['response'];  // GPT 응답 반환
      } 
      else {
        Get.snackbar('Error', 'Failed to send message: ${response.statusCode}');
        return "Error";  // 오류 발생 시 기본값 반환
      }
    } catch (e) {
      Get.snackbar('Error', 'Error sending message: $e');
      return "Error";  // 네트워크 오류 시 기본값 반환
    }
  }

  static Future<void> sendSelection(SelectionDTO selectionDTO) async {
    final url = Uri.parse('$baseUrl/selection');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(selectionDTO.toJson()),
      );

      if (response.statusCode == 200) {
        print('Selection sent successfully: ${response.body}');
      } else {
        Get.snackbar('Error', 'Failed to send selection: ${response.statusCode}');
      }
    } catch (e) {
      Get.snackbar('Error', 'Error sending selection: $e');
    }
  }

// 서버에서 메세지 받는 함수인데 필요없는 듯?
  static Future<List<String>> getMessagesFromServer() async {
    final url = Uri.parse('$baseUrl/message');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return List<String>.from(data['messages']);
      } else {
        throw Exception('Failed to fetch messages');
      }
    } catch (e) {
      Get.snackbar('Error', 'Error fetching messages: $e');
      return [];
    }
  }
}
 
