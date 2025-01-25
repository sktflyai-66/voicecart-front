import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import '../controllers/chat_controller.dart';

// 음성 챗봇 페이지
class VoiceBotPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Voice Bot')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.volume_up, size: 100, color: Colors.blue),
            SizedBox(height: 20),
            Text(
              '음성 채팅 중... 텍스트 넣을지는 ㅁㄹ',
              style: TextStyle(fontSize: 18),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}