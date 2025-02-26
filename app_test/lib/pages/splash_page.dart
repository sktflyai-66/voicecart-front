import 'package:app_test/pages/mic_page.dart';
import 'package:app_test/style/style.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:app_test/pages/chatbot_page.dart';
import 'package:app_test/services/speech_service.dart';
import 'package:app_test/controllers/chat_controller.dart';
import 'package:app_test/style/style.dart';
import 'package:app_test/widgets/gesture_feedback.dart';
import 'package:app_test/pages/guide_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
    debugPrint("splash page initState !!");
  }

  Future<void> _requestPermissions() async {
    var status = await Permission.microphone.status;
    
    if (status.isGranted) {
      Get.put<SpeechService>(SpeechService(), permanent: true);
      debugPrint("권한 있음 -> 3초 후 다음 페이지로 이동");
      Future.delayed(const Duration(seconds: 3), () {
        _navigateNext();
      });
    } else {
      var newStatus = await Permission.microphone.request();
      if (newStatus.isGranted) {
        Get.put<SpeechService>(SpeechService(), permanent: true);
        debugPrint("권한 허용 -> 3초 후 다음 페이지로 이동");
        Future.delayed(const Duration(seconds: 3), () {
          _navigateNext();
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

  Future<void> _navigateNext() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isFirstTime = prefs.getBool('is_first_time') ?? true;
    
    if (isFirstTime) {
      // 안내 페이지로 이동
      Get.off(() => const GuidePage());
      // 첫 실행 이후에는 false로 저장
      await prefs.setBool('is_first_time', false);
    } else {
      // 바로 메인 페이지(예: ChatBotPage)로 이동
      Get.off(() => GestureControlWidget(child: MicIconPage()));
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
