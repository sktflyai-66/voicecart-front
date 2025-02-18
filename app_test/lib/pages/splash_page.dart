import 'package:app_test/pages/signup_page.dart';
import 'package:app_test/pages/style_test_page.dart';
import 'package:app_test/style/style.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:app_test/pages/mic_icon_page.dart';
import 'package:app_test/pages/chatbot_page.dart';
import 'package:app_test/services/speech_service.dart';
import 'package:app_test/controllers/chat_controller.dart';
import 'package:app_test/style/style.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Get.put<ChatController>(ChatController(), permanent: true);
    _requestPermissions();
    debugPrint("splash page inistate !!");
  }

  Future<void> _requestPermissions() async {

  var status = await Permission.microphone.status;
  
  if (status.isGranted) {
    // 이미 권한이 있으면 3초 후 다음 페이지로 이동
    Get.put<SpeechService>(SpeechService(), permanent: true);
    debugPrint("============");
    debugPrint("다음 페이지로 넘어갑니다. status = grant");
    debugPrint("============");
    Future.delayed(const Duration(seconds: 3), () {
      Get.off(() => ChatBotPage());
    });
  } 

  else {
    // 권한이 없으면 권한을 요청한다.
    var newStatus = await Permission.microphone.request();
    if (newStatus.isGranted) {

      Get.put<SpeechService>(SpeechService(), permanent: true);
      debugPrint("다음 페이지로 넘어갑니다.");
      Future.delayed(const Duration(seconds: 3), () {
        Get.off(() => ChatBotPage());
      });
    } else if (newStatus.isDenied) {
      debugPrint("🚫 마이크 권한이 거부됨");
      Get.snackbar("권한 필요", "마이크 권한을 허용해야 음성 인식이 가능합니다.");
    } else if (newStatus.isPermanentlyDenied) {
      debugPrint("🚨 마이크 권한이 영구적으로 거부됨");
      openAppSettings(); // 앱 설정으로 이동
    }
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: Center(
        child: Text(
          'VoiceCart',
          style: AppTextStyles.mainTitle,
        ),
      ),
    );
  }
}
