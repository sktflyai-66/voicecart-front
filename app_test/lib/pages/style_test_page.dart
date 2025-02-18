import 'package:flutter/material.dart';
import 'package:app_test/style/style.dart'; 

class StyleTestPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor, // 배경색 테스트
      appBar: AppBar(
        title: const Text('Style Test Page', style: AppTextStyles.mainTitle),
        backgroundColor: AppColors.backgroundColor,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 텍스트 스타일 테스트
            const Text('Main Title', style: AppTextStyles.mainTitle),
            const SizedBox(height: 10),
            const Text('Subtitle Example', style: AppTextStyles.subtitle),
            const SizedBox(height: 10),
            const Text('Highlight Text', style: AppTextStyles.highlightText),
            const SizedBox(height: 10),
            const Text('Secondary Text', style: AppTextStyles.secondaryText),
            const SizedBox(height: 20),

            // 버튼 스타일 테스트
            ElevatedButton(
              onPressed: () {},
              style: AppButtonStyles.elevatedButtonStyle,
              child: const Text('Test Button'),
            ),
            const SizedBox(height: 20),

            // 채팅 말풍선 스타일 테스트
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: ChatBubbleStyles.chatBotBubbleStyle,
                  child: const Text('봇 메시지 스타일', style: AppTextStyles.messageStyle),
                ),
              ],
            ),
            const SizedBox(height: 10),

            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: ChatBubbleStyles.chatUserBubbleStyle,
                  child: const Text('사용자 메시지 스타일', style: AppTextStyles.messageStyle),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
