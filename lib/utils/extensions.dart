import 'package:flutter/material.dart';

extension TimeFormatting on int {
  String getFormatForTimeDisplay(){
    return toString().padLeft(2, '0');
  }

  int rollOver({int min = 0, required int max}) {
    int value = this;
    if (value >= max) {
      value = value - max;
    } else if (value < min) {
      value += max;
    }
    return value;
  }
}

extension DateTimeExtension on DateTime {
  DateTime setTimeOfDay(int hour, int minute) {
    return DateTime(year, month, day, hour, minute);
  }

  TimeOfDay toTimeOfDay(){
    return TimeOfDay(hour: hour, minute: minute);
  }
}