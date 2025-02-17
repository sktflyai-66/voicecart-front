import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:app_test/services/speech_service.dart';
import 'package:app_test/style/style.dart';

class SignUpStep extends StatefulWidget {
  final int stepNumber;
  final int totalSteps;
  final String title;
  final String content;
  final Function(String) onNext;
  final bool isTextFieldVisible;

  SignUpStep({
    required this.stepNumber,
    required this.totalSteps,
    required this.title,
    required this.content,
    required this.onNext,
    this.isTextFieldVisible = false,
  });

  @override
  _SignUpStepState createState() => _SignUpStepState();
}

class _SignUpStepState extends State<SignUpStep> {
  final TextEditingController _controller = TextEditingController();
  final SpeechService speechService = Get.find<SpeechService>();

  // @override
  // void initState() {
  //   super.initState();
  //   _speakInstruction();
  //   _startListening();
  // }

  // // 회원가입 안내 음성 실행
  // void _speakInstruction() {
  //   String instruction = "${widget.title} ${widget.content} 음성으로 대답해 주세요.";
  //   speechService.speakSignupInstruction(instruction);
  // }

  // // 음성 입력 받기
  // void _startListening() {
  //   speechService.listenForSignup((result) {
  //     _controller.text = result; // 입력 필드에도 반영
  //     widget.onNext(result); // 다음 단계로 이동
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Align(
              alignment: Alignment.topRight,
              child: Text("${widget.stepNumber}/${widget.totalSteps}",
                  style: AppTextStyles.highlightText),
            ),
            SizedBox(height: 40),
            Text(widget.title, style: AppTextStyles.mainTitle, textAlign: TextAlign.center),
            SizedBox(height: 10),
            Text(widget.content, style: AppTextStyles.subtitle, textAlign: TextAlign.center),
            SizedBox(height: 30),

            GestureDetector(
              // onTap: _startListening,
              child: Icon(Icons.mic, size: 80, color: AppColors.textColor),
            ),
            SizedBox(height: 20),

            if (widget.isTextFieldVisible)
              TextField(
                controller: _controller,
                decoration: InputDecoration(
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  hintText: "입력하세요",
                  filled: true,
                  fillColor: Colors.white,
                ),
                style: TextStyle(fontSize: 18),
              ),
            SizedBox(height: 20),

            ElevatedButton(
              onPressed: () => widget.onNext(_controller.text),
              style: AppButtonStyles.elevatedButtonStyle,
              child: Text("다음", style: AppTextStyles.buttonText),
            ),
          ],
        ),
      ),
    );
  }
}
