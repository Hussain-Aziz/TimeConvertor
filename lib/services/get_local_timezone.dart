import 'package:flutter_native_timezone/flutter_native_timezone.dart';

class GetLocalTimeZone {
  static Future<String> get() async{
    return await FlutterNativeTimezone.getLocalTimezone();
  }
}