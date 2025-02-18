import 'package:shared_preferences/shared_preferences.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'dart:io';

class SessionManager {
  static Future<String> getSessionId() async {
    final prefs = await SharedPreferences.getInstance();
    String? sessionId = prefs.getString('session_id');

    if (sessionId == null) {
      sessionId = await _generateSessionId(); // 처음 실행 시 고유 ID 생성
      await prefs.setString('session_id', sessionId);
    }

    return sessionId;
  }

  static Future<String> _generateSessionId() async {
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    
    if (Platform.isAndroid) {
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      return androidInfo.id; // Android의 고유 ID (ANDROID_ID)
    } else if (Platform.isIOS) {
      IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
      return iosInfo.identifierForVendor!; // iOS의 고유 ID
    } else {
      return DateTime.now().millisecondsSinceEpoch.toString(); // 기본값
    }
  }
}
