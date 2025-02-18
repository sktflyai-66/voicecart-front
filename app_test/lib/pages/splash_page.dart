import 'package:app_test/pages/signup_page.dart';
import 'package:app_test/style/style.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:app_test/pages/chatbot_page.dart';
import 'package:app_test/services/speech_service.dart';
import 'package:app_test/controllers/chat_controller.dart';
import 'package:app_test/services/api_service.dart';
import 'package:app_test/services/chat_service.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}


class _SplashScreenState extends State<SplashScreen> {
  late Map<String, dynamic> session_check;
  @override
  void initState() {
    super.initState();
    Get.put<ChatController>(ChatController(), permanent: true);
    _requestPermissions(); 
    _initializeSession(); 

  }

  // 세션 ID 가져오고 서버 확인 후 화면 이동
  Future<void> _initializeSession() async {
    debugPrint("여기여기역");
    // Map<String, dynamic> session_check = await ApiService.checkSession(); // 서버로 세션 확인 요청
    session_check = {"session_check": true};
    debugPrint("여기여기역abdads");

  }


  Future<void> _requestPermissions() async {

    var status = await Permission.microphone.status;
  
    print("status = ${status.isGranted}");
    if (status.isGranted) {
      debugPrint("마이크 권한 허용됨1");
      Get.lazyPut<SpeechService>(() => SpeechService()); // 필요할 때 생성
      debugPrint("여기여기");
      
      Get.offAll(() => session_check['session_check'] == false ? SignUpPage() : ChatBotPage());
    } 

    else {
      // 권한이 없으면 권한을 요청한다.
      var newStatus = await Permission.microphone.request();
      if (newStatus.isGranted) {
        Get.put<SpeechService>(SpeechService(), permanent: true);
        debugPrint("마이크 권한 허용됨");  
        Get.offAll(() => session_check['session_check'] == false ? SignUpPage() : ChatBotPage()); 
      } 
      else if (newStatus.isDenied) {
        Get.snackbar("권한 필요", "마이크 권한을 허용해야 음성 인식이 가능합니다.");
      } 
      else if (newStatus.isPermanentlyDenied) {
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
