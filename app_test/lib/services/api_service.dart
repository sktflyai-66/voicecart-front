import 'package:app_test/controllers/chat_controller.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:get/get.dart';
import 'dart:math';
import 'package:flutter/material.dart';

Random random = Random();

late int randomInt;

class ApiService {
  
  static const String baseUrl = 'https://voicecart-server.azurewebsites.net'; //http://3.107.238.79:8000';  

  // 1번 API : /chat  
  static Future<Map<String, dynamic>> sendMessageToServer_chat(String message) async {
    final url = Uri.parse('$baseUrl/api/v1/chat');
    
    print("post 메서드 사용해서 /api/v1/chat서버로 전송");
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'session_id': randomInt.toString(),
          'user_message': message,
        }),
      );

      if (response.statusCode == 200) {
        final utf8DecodedResponse = utf8.decode(response.bodyBytes);
        final data = jsonDecode(utf8DecodedResponse);
        return data;
      } else {
        Get.snackbar('Error', 'Failed to send message: ${response.statusCode}', backgroundColor: Colors.white, colorText: Colors.black,);
        throw Exception('Failed to send message: ${response.statusCode}');
      }
    } catch (e) {
      Get.snackbar('Error', 'Error sending message: $e', backgroundColor: Colors.white, colorText: Colors.black,);
      ChatController().addMessage('Error: $e');
      print("Error: $e");
      throw Exception('Error sending message: $e');
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
        Get.snackbar('Error', 'Failed to fetch initial text: ${response.statusCode}', backgroundColor: Colors.white, colorText: Colors.black,);
        return "Error";
      }
    } catch (e) {
      Get.snackbar('Error', 'Error fetching initial text: $e', backgroundColor: Colors.white, colorText: Colors.black,);
      return "Error";
    }
  }
}
