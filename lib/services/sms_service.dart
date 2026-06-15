import 'package:telephony/telephony.dart';

class SmsService {
  static final Telephony _telephony = Telephony.instance;

  static Future<bool> sendSms(String phoneNumber, String message) async {
    try {
      final bool? granted = await _telephony.requestSmsPermissions;
      if (!(granted ?? false)) {
        print('❌ SMS permission denied');
        return false;
      }

      await _telephony.sendSms(to: phoneNumber, message: message);
      print('✅ SMS sent successfully to $phoneNumber');
      return true;
    } catch (e) {
      print('❌ Error sending SMS: $e');
      return false;
    }
  }
}
