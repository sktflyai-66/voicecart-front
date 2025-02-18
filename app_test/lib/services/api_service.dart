import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:app_test/utils/session_manager.dart';

// 모든 메서드가 static으로 선언되어 있어서 인스턴스 생성 불필요
class ApiService {
  static const String baseUrl = 'https://strong-sawfish-leading.ngrok-free.app';

  // 채팅 API
  static Future<Map<String, dynamic>> sendChatMessage(String message) async {
    final sessionId = await SessionManager.getSessionId();
    return _postRequest('$baseUrl/chat', {'user_message': message, 'session_id': sessionId});
  }

  // 제품 리포트 API
  static Future<Map<String, dynamic>> sendProductRequest(String message) async {
    final sessionId = await SessionManager.getSessionId();
    return _postRequest('$baseUrl/product', {'user_message': message, 'session_id': sessionId});
  }

  // 세션 확인 API
  static Future<Map<String, dynamic>> checkSession() async {
    final sessionId = await SessionManager.getSessionId();
    return _postRequest('$baseUrl/session/init', {'session_id': sessionId});
  }

  // 회원가입 API
  static Future<Map<String, dynamic>> sendSignupData(Map<String, String> userData) async {
    final sessionId = await SessionManager.getSessionId();
    return _postRequest('$baseUrl/signup', {'user_data' : userData, 'session_id': sessionId});
  }

  // 공통 POST 요청 함수
  static Future<Map<String, dynamic>> _postRequest(String url, Map<String, dynamic> body) async {
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        return jsonDecode(utf8.decode(response.bodyBytes));
      } else {
        throw Exception('Server Error: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network Error: $e');
    }
  }
}
