import 'package:app_test/controllers/chat_controller.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:get/get.dart';
import 'dart:math';


Random random = Random();

late int randomInt;



class ApiService {
  
  static const String baseUrl = 'https://voicecart-server.azurewebsites.net'; //http://3.107.238.79:8000';  

  // 1번 API : /chat  
  static Future<Map<String, dynamic>> sendMessageToServer_chat(String message) async {
    final url = Uri.parse('$baseUrl/api/chat');
    print("post 메서드 사용해서 서버로 전송");
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'user_message': message,
          'session_id': randomInt.toString()
        }),
      );

      if (response.statusCode == 200) {
        final utf8DecodedResponse = utf8.decode(response.bodyBytes);
        final data = jsonDecode(utf8DecodedResponse);
        return data;
      } else {
        Get.snackbar('Error', 'Failed to send message: ${response.statusCode}');
        throw Exception('Failed to send message: ${response.statusCode}');
      }
    } catch (e) {
      Get.snackbar('Error', 'Error sending message: $e');
      ChatController().addMessage('Error: $e');
      print("Error: $e");
      throw Exception('Error sending message: $e');
    }
  }

// 2번 API : /product
  static Future<Map<String, dynamic>> getProductReport(String message) async {
    final url = Uri.parse('$baseUrl/api/product');
    print("post 메서드 사용해서 제품 리포트 요청");
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'user_message': message,
          'session_id': randomInt.toString()
        }),
      );
      if (response.statusCode == 200) {
        final decoded = utf8.decode(response.bodyBytes);
        final data = jsonDecode(decoded);
        return data;
      } else {
        Get.snackbar('Error', '제품 리포트 요청 실패: ${response.statusCode}');
        throw Exception('제품 리포트 요청 실패');
      }
    } catch (e) {
      Get.snackbar('Error', '제품 리포트 요청 중 오류: $e');
      throw e;
    }
  }

  // // 3번 API : /product/detail
  // static Future<Map<String, dynamic>> getProductDetail(String productId, String keyword, String session) async {
  //   final url = Uri.parse('$baseUrl/product/detail');
  //   print("post 메서드 사용해서 제품 선택 요청");
  //   try {
  //     final response = await http.post(
  //       url,
  //       headers: {'Content-Type': 'application/json'},
  //       body: jsonEncode({
  //         'product_id': productId,
  //         'keyword': keyword,
  //         'session': session,
  //       }),
  //     );
  //     if (response.statusCode == 200) {
  //       final decoded = utf8.decode(response.bodyBytes);
  //       final data = jsonDecode(decoded);
  //       return data;
  //     } else {
  //       Get.snackbar('Error', '제품 선택 요청 실패: ${response.statusCode}');
  //       throw Exception('제품 선택 요청 실패');
  //     }
  //   } catch (e) {
  //     Get.snackbar('Error', '제품 선택 요청 중 오류: $e');
  //     throw e;
  //   }
  // }

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

  // 회원가입 데이터를 전송하는 함수
  static Future<String> sendSingupToServer(Map<String, String> temp) async {
    return "test";
      // final url = Uri.parse('$baseUrl/initial');
  //   try {
  //     final response = await http.post(url,
  //     headers: {'ngrok-skip-browser-warning': 'true'} //ngrox 경고 페이지 우회
  //     ); 
  //     if (response.statusCode == 200) {
  //       final utf8DecodedResponse = utf8.decode(response.bodyBytes);
  //       final data = jsonDecode(utf8DecodedResponse);
  //       return data['text'];
  //     } else {
  //       Get.snackbar('Error', 'Failed to fetch initial text: ${response.statusCode}');
  //       return "Error";
  //     }
  //   } catch (e) {
  //     Get.snackbar('Error', 'Error fetching initial text: $e');
  //     return "Error";
  //   }
  // }
  }
}