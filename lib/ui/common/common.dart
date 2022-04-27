import 'dart:io';
import 'dart:ui';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class Utils {
  static const animationDuration = Duration(milliseconds: 200);
  static const bool USER_STATUS_ENABLE = true;
  static const bool USER_MESSAGE_SENT_STATUS = true;
  static const bool UPLOAD_IMAGE = true;

  static final date_format_dd_mm_yyyy = DateFormat('dd-MM-yyyy');
  static final date_format_mmmm_dd_yyyy  = DateFormat("MMM dd, yyyy");
  static final date_format_yyyy_mm_dd_hh_mm_ss = DateFormat("yyyy-MM-dd'T'HH:mm:ss.SSS'Z'");
  static final date_format_hh_mm_a = DateFormat('hh:mm a');

  static showSnackBar(String? message) {
    GetSnackBar(message: message, duration: Duration(seconds: 2),backgroundColor: Color(0xFF93C01F),).show();
  }

  static showErrorSnackBar(String? message) {
    GetSnackBar(message: message, duration: Duration(seconds: 8), backgroundColor: Color(0xFFD9534F)).show();
  }

  static Future<String?> getDeviceId() async {
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    if (Platform.isIOS) {
      IosDeviceInfo iosDeviceInfo = await deviceInfo.iosInfo;
      return iosDeviceInfo.identifierForVendor; // unique ID on iOS
    } else {
      AndroidDeviceInfo androidDeviceInfo = await deviceInfo.androidInfo;
      return androidDeviceInfo.androidId; // unique ID on Android
    }
  }

  static String getOSType() {
    return Platform.operatingSystem;
  }

}
