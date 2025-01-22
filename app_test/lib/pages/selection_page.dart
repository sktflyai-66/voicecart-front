 
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/chat_controller.dart';
import '../services/api_service.dart';
import '../dto/selection_dto.dart';
import 'chat_bot_page.dart';

class SelectionPage extends StatelessWidget {
  final chatController = Get.put(ChatController());

  void handleSelection(String option) async {
    await ApiService.sendSelection(SelectionDTO(option));
    Get.to(() => ChatBotPage());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Choose an Option')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () => handleSelection('전맹'),
              child: Text('전맹'),
            ),
            ElevatedButton(
              onPressed: () => handleSelection('약시'),
              child: Text('약시'),
            ),
            ElevatedButton(
              onPressed: () => handleSelection('일반인'),
              child: Text('일반인'),
            ),
          ],
        ),
      ),
    );
  }
}
