import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:get/get.dart';
import '../dto/selection_dto.dart';

class ApiService {
  static const String baseUrl = 'http://127.0.0.1:5000';

  static Future<void> sendMessageToFlask(String message) async {
    final url = Uri.parse('$baseUrl/send');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'message': message}),
      );

      if (response.statusCode == 200) {
        print('Message sent successfully: ${response.body}');
      } else {
        Get.snackbar('Error', 'Failed to send message: ${response.statusCode}');
      }
    } catch (e) {
      Get.snackbar('Error', 'Error sending message: $e');
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

  static Future<List<String>> getMessagesFromFlask() async {
    final url = Uri.parse('$baseUrl/messages');
    try {
      final response = await http.get(
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
 
