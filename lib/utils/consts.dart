import 'package:shared_preferences/shared_preferences.dart';

class Consts
{
  static const String localUTCOffsetLSName = "localUTCOffset";
  static const String formatLSName = "format";
}
enum Format{
  f12h,
  f24h
}